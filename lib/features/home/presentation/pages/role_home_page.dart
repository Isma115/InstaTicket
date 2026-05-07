// region Componentes Dashboard: imports
import 'package:flutter/material.dart';

import '../../../../core/models/auth_user.dart';
import '../../data/mock_home_repository.dart';
import '../../domain/models/dashboard_models.dart';
import '../widgets/create_ticket_dialog.dart';
import '../widgets/dashboard_metrics_grid.dart';
import '../widgets/dashboard_tickets_card.dart';
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
  static const double _bottomNavHeight = 102;

  int _selectedTabIndex = 0;

  void _selectTab(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  Future<void> _openCreateTicketDialog(String actionLabel) async {
    final draft = await showDialog<CreateTicketDraft>(
      context: context,
      barrierDismissible: true,
      builder: (context) => CreateTicketDialog(
        user: widget.user,
        actionLabel: actionLabel,
      ),
    );

    if (!mounted || draft == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${draft.category}: "${draft.title}" listo para conectar con backend (${draft.priority}).',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = MockHomeRepository.instance.buildDashboard(widget.user);
    final tabs = _buildTabs(widget.user);
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
    switch (tabId) {
      case 'inicio':
        return DashboardTicketsCard(tickets: dashboard.recentTickets);
      case 'tickets':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DashboardTicketsCard(tickets: dashboard.recentTickets),
            const SizedBox(height: 4),
            Text(
              'Las acciones de comentario y edicion quedan listas para conectarse con backend.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF65788F),
                  ),
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
          user: widget.user,
          metrics: dashboard.metrics,
          onLogout: () => Navigator.of(context).pop(),
        );
      default:
        return const SizedBox.shrink();
    }
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

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({
    required this.user,
    required this.metrics,
    required this.onLogout,
  });

  final AuthUser user;
  final List<DashboardMetric> metrics;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(
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
              _InitialsAvatar(
                name: user.name,
                size: 60,
                textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 14),
              Text(
                user.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF173B5E),
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                user.email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6C8097),
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Rol activo: ${user.role.label}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF0E4E7B),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FB),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: metrics
                .map(
                  (metric) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${metric.title}: ${metric.value}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF173B5E),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onLogout,
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
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.take(2).map((part) => part[0]).join().toUpperCase();

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
      sectionSubtitle:
          'Lista de trabajo adaptada a la distribucion solicitada.',
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
