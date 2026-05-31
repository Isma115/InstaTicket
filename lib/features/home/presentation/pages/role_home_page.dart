// region Componentes Dashboard: imports
import 'package:flutter/material.dart';

import '../../../../core/models/auth_user.dart';
import '../../../../core/models/user_role.dart';
import '../../data/remote_home_repository.dart';
import '../../domain/models/dashboard_models.dart';
import '../widgets/create_ticket_dialog.dart';
import '../widgets/dashboard_metrics_grid.dart';
import '../widgets/dashboard_tickets_card.dart';
import '../widgets/edit_ticket_dialog.dart';
import '../widgets/ticket_chat_sheet.dart';
// endregion

// region Componentes Dashboard: contenedor principal por rol
class RoleHomePage extends StatefulWidget {
  const RoleHomePage({
    required this.user,
    super.key,
  });

  final AuthUser user;

  @override
  State<RoleHomePage> createState() => _RoleHomePageState();
}

class _RoleHomePageState extends State<RoleHomePage> {
  final RemoteHomeRepository _repository = RemoteHomeRepository.instance;

  static const double _bottomNavHeight = 102;
  static const List<String> _statusFilters = <String>[
    'Todos',
    'Abierto',
    'En progreso',
    'Resuelto',
  ];
  static const List<String> _priorityFilters = <String>[
    'Todas',
    'Alta',
    'Media',
    'Baja',
  ];
  static const List<String> _sortOptions = <String>[
    'Mas recientes',
    'Prioridad',
    'Estado',
  ];

  int _selectedTabIndex = 0;
  String _selectedStatusFilter = 'Todos';
  String _selectedPriorityFilter = 'Todas';
  String _selectedSortOption = 'Mas recientes';
  late AuthUser _currentUser;
  DashboardViewData? _dashboard;
  List<DashboardTicket> _tickets = <DashboardTicket>[];
  bool _isLoadingDashboard = true;
  bool _isMutatingData = false;
  String? _dashboardError;

  bool get _canDeleteTickets =>
      _currentUser.role == UserRole.tecnico ||
      _currentUser.role == UserRole.admin;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _initializeDashboard();
  }

  @override
  void didUpdateWidget(covariant RoleHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.user.email != widget.user.email ||
        oldWidget.user.role != widget.user.role) {
      _currentUser = widget.user;
      _initializeDashboard();
    }
  }

  Future<void> _initializeDashboard() async {
    setState(() {
      _isLoadingDashboard = true;
      _dashboardError = null;
    });

    try {
      final dashboard = await _repository.loadDashboard(_currentUser);

      if (!mounted) {
        return;
      }

      setState(() {
        _dashboard = dashboard;
        _tickets = List<DashboardTicket>.from(dashboard.recentTickets);
        _isLoadingDashboard = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingDashboard = false;
        _dashboardError = error.toString();
      });
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  void _selectTab(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  void _selectStatusFilter(String value) {
    setState(() {
      _selectedStatusFilter = value;
    });
  }

  void _selectPriorityFilter(String value) {
    setState(() {
      _selectedPriorityFilter = value;
    });
  }

  void _selectSortOption(String? value) {
    if (value == null) {
      return;
    }

    setState(() {
      _selectedSortOption = value;
    });
  }

  Future<void> _openTicketFiltersSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _TicketFiltersSheet(
          statusFilters: _statusFilters,
          priorityFilters: _priorityFilters,
          selectedStatus: _selectedStatusFilter,
          selectedPriority: _selectedPriorityFilter,
          onStatusSelected: _selectStatusFilter,
          onPrioritySelected: _selectPriorityFilter,
        );
      },
    );
  }

  Future<void> _openCreateTicketDialog(String actionLabel) async {
    if (_isMutatingData) {
      return;
    }

    final draft = await showDialog<CreateTicketDraft>(
      context: context,
      barrierDismissible: true,
      builder: (context) => CreateTicketDialog(
        user: _currentUser,
        actionLabel: actionLabel,
      ),
    );

    if (!mounted || draft == null) {
      return;
    }

    setState(() {
      _isMutatingData = true;
    });

    try {
      final createdTicket = await _repository.createTicket(
        user: _currentUser,
        title: draft.title,
        description: draft.description,
        category: draft.category,
        priority: draft.priority,
        assetReference: draft.assetReference,
        notifyByEmail: draft.notifyByEmail,
        needsFollowUp: draft.needsFollowUp,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _tickets = <DashboardTicket>[
          createdTicket,
          ..._tickets,
        ];
      });

      _showMessage('Ticket creado correctamente.');
    } catch (error) {
      _showMessage(error.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isMutatingData = false;
        });
      }
    }
  }

  Future<void> _openTicketChat(DashboardTicket ticket) async {
    if (_isMutatingData) {
      return;
    }

    DashboardTicket ticketForChat = ticket;

    try {
      final messages = await _repository.fetchComments(
        ticketId: ticket.id,
        currentUserEmail: _currentUser.email,
      );

      if (!mounted) {
        return;
      }

      _updateTicketMessages(
        ticketId: ticket.id,
        messages: messages,
      );

      ticketForChat = _tickets.firstWhere(
        (currentTicket) => currentTicket.id == ticket.id,
        orElse: () => ticket.copyWith(chatMessages: messages),
      );
    } catch (error) {
      _showMessage(error.toString(), isError: true);
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TicketChatSheet(
        ticket: ticketForChat,
        currentUser: _currentUser,
        onMessagesChanged: (messages) {
          _updateTicketMessages(
            ticketId: ticket.id,
            messages: messages,
          );
        },
        onSendMessage: (body, parentMessageId) async {
          final messages = await _repository.createComment(
            ticketId: ticket.id,
            currentUserEmail: _currentUser.email,
            body: body,
            parentMessageId: parentMessageId,
          );

          if (!mounted) {
            return;
          }

          _updateTicketMessages(
            ticketId: ticket.id,
            messages: messages,
          );
        },
      ),
    );
  }

  Future<void> _openEditTicketDialog(DashboardTicket ticket) async {
    if (_isMutatingData) {
      return;
    }

    final updatedTicket = await showDialog<DashboardTicket>(
      context: context,
      barrierDismissible: true,
      builder: (context) => EditTicketDialog(ticket: ticket),
    );

    if (!mounted || updatedTicket == null) {
      return;
    }

    setState(() {
      _isMutatingData = true;
    });

    try {
      final savedTicket = await _repository.updateTicket(
        ticketId: ticket.id,
        title: updatedTicket.title,
        status: updatedTicket.status,
        priority: updatedTicket.priorityLabel,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _tickets = _tickets
            .map(
              (currentTicket) => currentTicket.id == savedTicket.id
                  ? savedTicket.copyWith(
                      chatMessages: currentTicket.chatMessages)
                  : currentTicket,
            )
            .toList();
      });

      _showMessage('Ticket actualizado correctamente.');
    } catch (error) {
      _showMessage(error.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isMutatingData = false;
        });
      }
    }
  }

  Future<void> _deleteTicket(DashboardTicket ticket) async {
    if (_isMutatingData) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar ticket'),
        content: Text(
          '¿Quieres eliminar "${ticket.title}"?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC0392B),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) {
      return;
    }

    setState(() {
      _isMutatingData = true;
    });

    try {
      await _repository.deleteTicket(ticketId: ticket.id);

      if (!mounted) {
        return;
      }

      setState(() {
        _tickets = _tickets
            .where((currentTicket) => currentTicket.id != ticket.id)
            .toList();
      });

      _showMessage('Ticket eliminado correctamente.');
    } catch (error) {
      _showMessage(error.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isMutatingData = false;
        });
      }
    }
  }

  void _updateTicketMessages({
    required String ticketId,
    required List<DashboardTicketMessage> messages,
  }) {
    setState(() {
      _tickets = _tickets
          .map(
            (ticket) => ticket.id == ticketId
                ? ticket.copyWith(
                    chatMessages: messages,
                    persistedMessageCount: messages.length,
                  )
                : ticket,
          )
          .toList();
    });
  }

  Future<void> _saveProfile(AuthUser updatedUser) async {
    if (_isMutatingData) {
      return;
    }

    setState(() {
      _isMutatingData = true;
    });

    try {
      final savedUser = await _repository.updateProfile(
        user: _currentUser,
        name: updatedUser.name,
        lastName: updatedUser.lastName,
        photoUrl: updatedUser.photoUrl,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _currentUser = savedUser.copyWith(password: _currentUser.password);
      });

      _showMessage('Perfil actualizado correctamente.');
    } catch (error) {
      _showMessage(error.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isMutatingData = false;
        });
      }
    }
  }

  Future<void> _toggleTwoFactor(bool enabled) async {
    if (_isMutatingData) {
      return;
    }

    setState(() {
      _isMutatingData = true;
    });

    try {
      final updatedUser = await _repository.updateTwoFactor(
        user: _currentUser,
        enabled: enabled,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _currentUser = updatedUser.copyWith(password: _currentUser.password);
      });

      _showMessage(
        enabled
            ? 'Doble autenticación activada.'
            : 'Doble autenticación desactivada.',
      );
    } catch (error) {
      _showMessage(error.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isMutatingData = false;
        });
      }
    }
  }

  List<DashboardTicket> _buildVisibleTickets(List<DashboardTicket> tickets) {
    final visibleTickets = tickets.where((ticket) {
      final matchesStatus = _selectedStatusFilter == 'Todos' ||
          ticket.status == _selectedStatusFilter;
      final matchesPriority = _selectedPriorityFilter == 'Todas' ||
          ticket.priorityLabel == _selectedPriorityFilter;

      return matchesStatus && matchesPriority;
    }).toList();

    visibleTickets.sort((first, second) {
      switch (_selectedSortOption) {
        case 'Prioridad':
          final priorityComparison = _priorityRank(first.priorityLabel)
              .compareTo(_priorityRank(second.priorityLabel));
          if (priorityComparison != 0) {
            return priorityComparison;
          }

          return _compareByRecency(first, second);
        case 'Estado':
          final statusComparison =
              _statusRank(first.status).compareTo(_statusRank(second.status));
          if (statusComparison != 0) {
            return statusComparison;
          }

          return _compareByRecency(first, second);
        case 'Mas recientes':
        default:
          return _compareByRecency(first, second);
      }
    });

    return visibleTickets;
  }

  int _compareByRecency(DashboardTicket first, DashboardTicket second) {
    final firstDayRank = _dayRank(first.timeLabel);
    final secondDayRank = _dayRank(second.timeLabel);

    if (firstDayRank != secondDayRank) {
      return firstDayRank.compareTo(secondDayRank);
    }

    return _extractMinutes(second.timeLabel).compareTo(
      _extractMinutes(first.timeLabel),
    );
  }

  int _dayRank(String label) {
    if (label.startsWith('Hoy')) {
      return 0;
    }

    if (label.startsWith('Ayer')) {
      return 1;
    }

    return 2;
  }

  int _extractMinutes(String label) {
    final match = RegExp(r'(\d{2}):(\d{2})').firstMatch(label);

    if (match == null) {
      return 0;
    }

    final hours = int.tryParse(match.group(1) ?? '') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '') ?? 0;
    return (hours * 60) + minutes;
  }

  int _priorityRank(String label) {
    switch (label) {
      case 'Alta':
        return 0;
      case 'Media':
        return 1;
      case 'Baja':
        return 2;
      default:
        return 3;
    }
  }

  int _statusRank(String label) {
    switch (label) {
      case 'Abierto':
        return 0;
      case 'En progreso':
        return 1;
      case 'Resuelto':
        return 2;
      default:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingDashboard) {
      return const Scaffold(
        backgroundColor: Color(0xFFE6EDF2),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_dashboardError != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFE6EDF2),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  _dashboardError!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF173B5E),
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: _initializeDashboard,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final dashboard = _dashboard;
    if (dashboard == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFE6EDF2),
        body: Center(
          child: Text('No se pudo cargar el dashboard.'),
        ),
      );
    }

    final tabs = _buildTabs(_currentUser);
    final currentTab = tabs[_selectedTabIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFE6EDF2),
      body: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: _DashboardBackdrop(),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final fullBleed = constraints.maxWidth < 480;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: fullBleed ? 0 : 14,
                        vertical: fullBleed ? 0 : 12,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(fullBleed ? 0 : 34),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F7FA),
                            boxShadow: fullBleed
                                ? null
                                : const <BoxShadow>[
                                    BoxShadow(
                                      color: Color(0x220F2744),
                                      blurRadius: 30,
                                      offset: Offset(0, 20),
                                    ),
                                  ],
                          ),
                          child: Stack(
                            children: <Widget>[
                              Positioned.fill(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    16,
                                    16,
                                    32 + _bottomNavHeight,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      if (currentTab.id ==
                                          'inicio') ...<Widget>[
                                        Text(
                                          'Estadisticas',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: const Color(0xFF173B5E),
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                        const SizedBox(height: 12),
                                        DashboardMetricsGrid(
                                          metrics: dashboard.metrics,
                                          availableWidth: 360,
                                          singleColumnLayout: false,
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                      _DashboardSection(
                                        title: currentTab.sectionTitle,
                                        subtitle: currentTab.sectionSubtitle,
                                        trailing: currentTab.id == 'inicio' ||
                                                currentTab.id == 'tickets'
                                            ? _CreateTicketButton(
                                                onPressed: () =>
                                                    _openCreateTicketDialog(
                                                  dashboard.floatingActionLabel,
                                                ),
                                                tooltip: dashboard
                                                    .floatingActionLabel,
                                              )
                                            : null,
                                        child: _buildTabContent(
                                          dashboard: dashboard,
                                          tabId: currentTab.id,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: _BottomNavigationBar(
                                  items: tabs,
                                  selectedIndex: _selectedTabIndex,
                                  onSelected: _selectTab,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent({
    required DashboardViewData dashboard,
    required String tabId,
  }) {
    final visibleTickets = _buildVisibleTickets(_tickets);

    switch (tabId) {
      case 'inicio':
        return DashboardTicketsCard(
          tickets: _tickets,
          onOpenChat: _openTicketChat,
          onEditTicket: _openEditTicketDialog,
          canDeleteTicket: _canDeleteTickets,
          onDeleteTicket: _deleteTicket,
        );
      case 'tickets':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _TicketFiltersToolbar(
              selectedStatus: _selectedStatusFilter,
              selectedPriority: _selectedPriorityFilter,
              selectedSort: _selectedSortOption,
              sortOptions: _sortOptions,
              onOpenFilters: _openTicketFiltersSheet,
              onSortSelected: _selectSortOption,
            ),
            const SizedBox(height: 14),
            Text(
              '${visibleTickets.length} tickets visibles',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF65788F),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 10),
            DashboardTicketsCard(
              tickets: visibleTickets,
              onOpenChat: _openTicketChat,
              onEditTicket: _openEditTicketDialog,
              canDeleteTicket: _canDeleteTickets,
              onDeleteTicket: _deleteTicket,
            ),
          ],
        );
      case 'grupos':
        return Column(
          children: dashboard.supportGroups
              .map(
                (group) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _SupportGroupCard(group: group),
                ),
              )
              .toList(),
        );
      case 'perfil':
        return _ProfilePanel(
          user: _currentUser,
          onProfileSaved: _saveProfile,
          onTwoFactorChanged: _toggleTwoFactor,
          onLogout: () => Navigator.of(context).pop(),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
// endregion

// region Componentes Dashboard: filtros de tickets
class _TicketFiltersToolbar extends StatelessWidget {
  const _TicketFiltersToolbar({
    required this.selectedStatus,
    required this.selectedPriority,
    required this.selectedSort,
    required this.sortOptions,
    required this.onOpenFilters,
    required this.onSortSelected,
  });

  final String selectedStatus;
  final String selectedPriority;
  final String selectedSort;
  final List<String> sortOptions;
  final VoidCallback onOpenFilters;
  final ValueChanged<String?> onSortSelected;

  int get _activeFiltersCount {
    var count = 0;

    if (selectedStatus != 'Todos') {
      count += 1;
    }

    if (selectedPriority != 'Todas') {
      count += 1;
    }

    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4EBF3)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOpenFilters,
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: Text(
                    _activeFiltersCount == 0
                        ? 'Filtros'
                        : 'Filtros ($_activeFiltersCount)',
                  ),
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedSort,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                  items: sortOptions
                      .map(
                        (option) => DropdownMenuItem<String>(
                          value: option,
                          child: Text(
                            option,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: onSortSelected,
                ),
              ),
            ],
          ),
          if (_activeFiltersCount > 0) ...<Widget>[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                if (selectedStatus != 'Todos')
                  _ActiveFilterChip(label: 'Estado: $selectedStatus'),
                if (selectedPriority != 'Todas')
                  _ActiveFilterChip(label: 'Prioridad: $selectedPriority'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TicketFiltersSheet extends StatefulWidget {
  const _TicketFiltersSheet({
    required this.statusFilters,
    required this.priorityFilters,
    required this.selectedStatus,
    required this.selectedPriority,
    required this.onStatusSelected,
    required this.onPrioritySelected,
  });

  final List<String> statusFilters;
  final List<String> priorityFilters;
  final String selectedStatus;
  final String selectedPriority;
  final ValueChanged<String> onStatusSelected;
  final ValueChanged<String> onPrioritySelected;

  @override
  State<_TicketFiltersSheet> createState() => _TicketFiltersSheetState();
}

class _TicketFiltersSheetState extends State<_TicketFiltersSheet> {
  late String _localSelectedStatus;
  late String _localSelectedPriority;

  @override
  void initState() {
    super.initState();
    _localSelectedStatus = widget.selectedStatus;
    _localSelectedPriority = widget.selectedPriority;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        decoration: const BoxDecoration(
          color: Color(0xFFF8FBFD),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 54,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD5E0EA),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Filtros de tickets',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF173B5E),
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _FilterGroup(
              label: 'Estado',
              values: widget.statusFilters,
              selectedValue: _localSelectedStatus,
              onSelected: (value) {
                setState(() {
                  _localSelectedStatus = value;
                });
                widget.onStatusSelected(value);
              },
            ),
            const SizedBox(height: 14),
            _FilterGroup(
              label: 'Prioridad',
              values: widget.priorityFilters,
              selectedValue: _localSelectedPriority,
              onSelected: (value) {
                setState(() {
                  _localSelectedPriority = value;
                });
                widget.onPrioritySelected(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterGroup extends StatelessWidget {
  const _FilterGroup({
    required this.label,
    required this.values,
    required this.selectedValue,
    required this.onSelected,
  });

  final String label;
  final List<String> values;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6A7C92),
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values
              .map(
                (value) => ChoiceChip(
                  label: Text(value),
                  selected: value == selectedValue,
                  onSelected: (_) => onSelected(value),
                  backgroundColor: const Color(0xFFF2F6FA),
                  selectedColor: const Color(0xFFE4F0FF),
                  surfaceTintColor: Colors.transparent,
                  pressElevation: 0,
                  shadowColor: Colors.transparent,
                  side: BorderSide(
                    color: value == selectedValue
                        ? const Color(0xFF1F6BFF)
                        : Colors.transparent,
                  ),
                  color: WidgetStateProperty.resolveWith<Color?>(
                    (states) {
                      if (states.contains(WidgetState.selected)) {
                        return const Color(0xFFE4F0FF);
                      }

                      return const Color(0xFFF2F6FA);
                    },
                  ),
                  labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: value == selectedValue
                            ? const Color(0xFF1B4F85)
                            : const Color(0xFF5F738A),
                        fontWeight: FontWeight.w700,
                      ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF1B4F85),
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
// endregion

// region Componentes Dashboard: fondo decorativo exterior
class _DashboardBackdrop extends StatelessWidget {
  const _DashboardBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Color(0xFFF3F6F9),
            Color(0xFFDDE6EC),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -60,
            left: -40,
            child: _BackdropGlow(
              size: 200,
              color: Color(0x33FFFFFF),
            ),
          ),
          Positioned(
            bottom: 110,
            right: -60,
            child: _BackdropGlow(
              size: 220,
              color: Color(0x222457F5),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackdropGlow extends StatelessWidget {
  const _BackdropGlow({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
// endregion

// region Componentes Dashboard: barra inferior de navegacion
class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_DashboardTab> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2EAF2)),
        ),
      ),
      child: Row(
        children: List<Widget>.generate(
          items.length,
          (index) {
            final item = items[index];
            final selected = index == selectedIndex;

            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelected(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFE9F4FF)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.icon,
                          color: selected
                              ? const Color(0xFF0E4E7B)
                              : const Color(0xFF7C8DA4),
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: selected
                                  ? const Color(0xFF173B5E)
                                  : const Color(0xFF7C8DA4),
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
// endregion

// region Componentes Dashboard: boton flotante de nuevo ticket
class _CreateTicketButton extends StatelessWidget {
  const _CreateTicketButton({
    required this.onPressed,
    required this.tooltip,
  });

  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF173B5E),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Tooltip(
              message: tooltip,
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// endregion

// region Componentes Dashboard: bloques de contenido por pestana
class _DashboardSection extends StatelessWidget {
  const _DashboardSection({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF173B5E),
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            if (trailing != null) ...<Widget>[
              const SizedBox(width: 12),
              trailing!,
            ],
          ],
        ),
        if (subtitle.isNotEmpty) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF70839A),
                ),
          ),
          const SizedBox(height: 16),
        ] else ...<Widget>[
          const SizedBox(height: 12),
        ],
        child,
      ],
    );
  }
}

class _SupportGroupCard extends StatelessWidget {
  const _SupportGroupCard({
    required this.group,
  });

  final DashboardSupportGroup group;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5EDF4)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1020325B),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: group.accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              group.icon,
              color: group.accentColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  group.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF173B5E),
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  group.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6C8097),
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  group.membersLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: group.accentColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilePanel extends StatefulWidget {
  const _ProfilePanel({
    required this.user,
    required this.onProfileSaved,
    required this.onTwoFactorChanged,
    required this.onLogout,
  });

  final AuthUser user;
  final ValueChanged<AuthUser> onProfileSaved;
  final ValueChanged<bool> onTwoFactorChanged;
  final VoidCallback onLogout;

  @override
  State<_ProfilePanel> createState() => _ProfilePanelState();
}

class _ProfilePanelState extends State<_ProfilePanel> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  late String _selectedPhotoUrl;

  @override
  void initState() {
    super.initState();
    _syncWithUser();
  }

  @override
  void didUpdateWidget(covariant _ProfilePanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.user.displayName != widget.user.displayName ||
        oldWidget.user.photoUrl != widget.user.photoUrl ||
        oldWidget.user.twoFactorEnabled != widget.user.twoFactorEnabled) {
      _syncWithUser();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _syncWithUser() {
    _nameController.text = widget.user.name;
    _lastNameController.text = widget.user.lastName?.trim() ?? '';
    _selectedPhotoUrl =
        widget.user.photoUrl ?? _profilePhotoOptions.first.photoUrl;
  }

  Future<void> _openPhotoPicker() async {
    final selectedPhotoUrl = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ProfilePhotoPickerSheet(
          selectedPhotoUrl: _selectedPhotoUrl,
        );
      },
    );

    if (selectedPhotoUrl == null) {
      return;
    }

    setState(() {
      _selectedPhotoUrl = selectedPhotoUrl;
    });
  }

  void _saveProfile() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    widget.onProfileSaved(
      widget.user.copyWith(
        name: _nameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        photoUrl: _selectedPhotoUrl,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF7FAFD),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFDCE6F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFDCE6F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFF2457F5),
          width: 1.4,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5EDF4)),
          ),
          child: Column(
            children: <Widget>[
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  _UserProfileAvatar(
                    name: widget.user.displayName,
                    photoUrl: _selectedPhotoUrl,
                    size: 86,
                    textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: FilledButton(
                      onPressed: _openPhotoPicker,
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(12),
                        backgroundColor: const Color(0xFF2457F5),
                      ),
                      child: const Icon(Icons.photo_camera_outlined, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                widget.user.displayName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF173B5E),
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.user.email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6C8097),
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Rol activo: ${widget.user.role.label}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF0E4E7B),
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _openPhotoPicker,
                icon: const Icon(Icons.image_outlined),
                label: const Text('Cambiar foto de perfil'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5EDF4)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Informacion personal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF173B5E),
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Edita nombre, apellido y foto de perfil desde esta vista.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF70839A),
                      ),
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final singleColumn = constraints.maxWidth < 330;

                    if (singleColumn) {
                      return Column(
                        children: <Widget>[
                          TextFormField(
                            controller: _nameController,
                            decoration: _buildInputDecoration(
                              label: 'Nombre',
                              icon: Icons.badge_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Introduce un nombre.';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _lastNameController,
                            decoration: _buildInputDecoration(
                              label: 'Apellido',
                              icon: Icons.person_outline_rounded,
                            ),
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            decoration: _buildInputDecoration(
                              label: 'Nombre',
                              icon: Icons.badge_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Introduce un nombre.';
                              }

                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            decoration: _buildInputDecoration(
                              label: 'Apellido',
                              icon: Icons.person_outline_rounded,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  initialValue: widget.user.email,
                  readOnly: true,
                  decoration: _buildInputDecoration(
                    label: 'Correo electronico',
                    icon: Icons.mail_outline_rounded,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saveProfile,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Guardar cambios del perfil'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF2457F5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5EDF4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Doble autenticacion',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: const Color(0xFF173B5E),
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.user.twoFactorEnabled
                              ? 'Proteccion extra activa para el acceso a la cuenta.'
                              : 'Activa una segunda capa de verificacion para la cuenta.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF70839A),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: widget.user.twoFactorEnabled
                          ? const Color(0xFFE7F7EF)
                          : const Color(0xFFF4F6F9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      widget.user.twoFactorEnabled ? 'Activa' : 'Inactiva',
                      style: TextStyle(
                        color: widget.user.twoFactorEnabled
                            ? const Color(0xFF198754)
                            : const Color(0xFF7A8AA0),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: widget.user.twoFactorEnabled
                    ? OutlinedButton.icon(
                        onPressed: () => widget.onTwoFactorChanged(false),
                        icon: const Icon(Icons.shield_moon_outlined),
                        label: const Text('Desactivar doble autenticacion'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      )
                    : FilledButton.icon(
                        onPressed: () => widget.onTwoFactorChanged(true),
                        icon: const Icon(Icons.verified_user_outlined),
                        label: const Text('Activar doble autenticacion'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF173B5E),
                        ),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Cerrar sesion'),
          ),
        ),
      ],
    );
  }
}
// endregion

// region Componentes Dashboard: utilidades visuales del panel
class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({
    required this.name,
    this.size = 42,
    this.textStyle,
  });

  final String name;
  final double size;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    final initials = parts.isEmpty
        ? 'IT'
        : parts
            .take(2)
            .map((part) => part.substring(0, 1))
            .join()
            .toUpperCase();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF4CC9F0),
            Color(0xFF2457F5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: textStyle ??
            Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
      ),
    );
  }
}

class _UserProfileAvatar extends StatelessWidget {
  const _UserProfileAvatar({
    required this.name,
    required this.photoUrl,
    required this.size,
    this.textStyle,
  });

  final String name;
  final String? photoUrl;
  final double size;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1F2457F5),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipOval(
        child: hasPhoto
            ? Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _InitialsAvatar(
                    name: name,
                    size: size,
                    textStyle: textStyle,
                  );
                },
              )
            : _InitialsAvatar(
                name: name,
                size: size,
                textStyle: textStyle,
              ),
      ),
    );
  }
}

class _ProfilePhotoPickerSheet extends StatelessWidget {
  const _ProfilePhotoPickerSheet({
    required this.selectedPhotoUrl,
  });

  final String selectedPhotoUrl;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        decoration: const BoxDecoration(
          color: Color(0xFFF8FBFD),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 54,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD5E0EA),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Selecciona una foto de perfil',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF173B5E),
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Galeria demo de avatares para la interfaz frontend.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF70839A),
                  ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: _profilePhotoOptions.map((option) {
                final selected = option.photoUrl == selectedPhotoUrl;

                return GestureDetector(
                  onTap: () => Navigator.of(context).pop(option.photoUrl),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF2457F5)
                            : const Color(0xFFDDE6EF),
                        width: selected ? 1.6 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _UserProfileAvatar(
                          name: option.label,
                          photoUrl: option.photoUrl,
                          size: 62,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          option.label,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF173B5E),
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePhotoOption {
  const _ProfilePhotoOption({
    required this.label,
    required this.photoUrl,
  });

  final String label;
  final String photoUrl;
}

const List<_ProfilePhotoOption> _profilePhotoOptions = <_ProfilePhotoOption>[
  _ProfilePhotoOption(
    label: 'Avatar 1',
    photoUrl: 'https://i.pravatar.cc/300?img=12',
  ),
  _ProfilePhotoOption(
    label: 'Avatar 2',
    photoUrl: 'https://i.pravatar.cc/300?img=25',
  ),
  _ProfilePhotoOption(
    label: 'Avatar 3',
    photoUrl: 'https://i.pravatar.cc/300?img=33',
  ),
  _ProfilePhotoOption(
    label: 'Avatar 4',
    photoUrl: 'https://i.pravatar.cc/300?img=47',
  ),
  _ProfilePhotoOption(
    label: 'Avatar 5',
    photoUrl: 'https://i.pravatar.cc/300?img=53',
  ),
];

class _DashboardTab {
  const _DashboardTab({
    required this.id,
    required this.label,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.sectionTitle,
    required this.sectionSubtitle,
  });

  final String id;
  final String label;
  final IconData icon;
  final String title;
  final String subtitle;
  final String sectionTitle;
  final String sectionSubtitle;
}

List<_DashboardTab> _buildTabs(AuthUser user) {
  return <_DashboardTab>[
    _DashboardTab(
      id: 'inicio',
      label: 'Inicio',
      icon: Icons.home_rounded,
      title: 'Inicio - Panel de Control',
      subtitle: user.role.headline,
      sectionTitle: 'Tickets recientes',
      sectionSubtitle: '',
    ),
    _DashboardTab(
      id: 'tickets',
      label: 'Tickets',
      icon: Icons.inventory_2_outlined,
      title: 'Tickets - Seguimiento',
      subtitle: 'Vista compacta de incidencias abiertas y resueltas.',
      sectionTitle: 'Mis tickets',
      sectionSubtitle: '',
    ),
    _DashboardTab(
      id: 'grupos',
      label: 'Grupos',
      icon: Icons.groups_2_outlined,
      title: 'Grupos - Equipos',
      subtitle: 'Accesos rapidos a los equipos de soporte disponibles.',
      sectionTitle: 'Grupos activos',
      sectionSubtitle: 'Capas de soporte y areas coordinadas por rol.',
    ),
    _DashboardTab(
      id: 'perfil',
      label: 'Perfil',
      icon: Icons.person_outline_rounded,
      title: 'Perfil - Cuenta',
      subtitle: 'Datos basicos de la sesion y accesos personales.',
      sectionTitle: 'Perfil de usuario',
      sectionSubtitle:
          'Informacion de la cuenta y resumen rapido de actividad.',
    ),
  ];
}
// endregion
