// region Componentes Dashboard: imports del popup de editar ticket
import 'package:flutter/material.dart';

import '../../domain/models/dashboard_models.dart';
// endregion

// region Componentes Dashboard: popup de editar ticket
class EditTicketDialog extends StatefulWidget {
  const EditTicketDialog({
    required this.ticket,
    super.key,
  });

  final DashboardTicket ticket;

  @override
  State<EditTicketDialog> createState() => _EditTicketDialogState();
}
// endregion

// region Lógica Dashboard: estado del popup de editar ticket
class _EditTicketDialogState extends State<EditTicketDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _reporterController = TextEditingController();
  final TextEditingController _timeLabelController = TextEditingController();

  static const List<String> _statusOptions = <String>[
    'Abierto',
    'En progreso',
    'Resuelto',
  ];
  static const List<String> _priorityOptions = <String>[
    'Alta',
    'Media',
    'Baja',
  ];

  late String _selectedStatus;
  late String _selectedPriority;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.ticket.title;
    _reporterController.text = widget.ticket.reporter;
    _timeLabelController.text = widget.ticket.timeLabel;
    _selectedStatus = widget.ticket.status;
    _selectedPriority = widget.ticket.priorityLabel;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _reporterController.dispose();
    _timeLabelController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      widget.ticket.copyWith(
        title: _titleController.text.trim(),
        reporter: _reporterController.text.trim(),
        timeLabel: _timeLabelController.text.trim(),
        status: _selectedStatus,
        priorityLabel: _selectedPriority,
        statusColor: _statusColor(_selectedStatus),
        statusBackgroundColor: _statusBackgroundColor(_selectedStatus),
        priorityColor: _priorityColor(_selectedPriority),
        priorityBackgroundColor: _priorityBackgroundColor(_selectedPriority),
        accentColor: _accentColor(_selectedStatus),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Abierto':
        return const Color(0xFF1F6BFF);
      case 'En progreso':
        return const Color(0xFFFFAF1A);
      case 'Resuelto':
        return const Color(0xFF20B46A);
      default:
        return const Color(0xFF173B5E);
    }
  }

  Color _statusBackgroundColor(String status) {
    switch (status) {
      case 'Abierto':
        return const Color(0xFFEEF5FF);
      case 'En progreso':
        return const Color(0xFFFFF7E8);
      case 'Resuelto':
        return const Color(0xFFEEFBF3);
      default:
        return const Color(0xFFF2F6FA);
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'Alta':
        return const Color(0xFFC0392B);
      case 'Media':
        return const Color(0xFF9B6B00);
      case 'Baja':
        return const Color(0xFF2D6A4F);
      default:
        return const Color(0xFF173B5E);
    }
  }

  Color _priorityBackgroundColor(String priority) {
    switch (priority) {
      case 'Alta':
        return const Color(0xFFFFE9E6);
      case 'Media':
        return const Color(0xFFFFF3D6);
      case 'Baja':
        return const Color(0xFFE6F6EC);
      default:
        return const Color(0xFFF2F6FA);
    }
  }

  Color _accentColor(String status) {
    switch (status) {
      case 'Abierto':
        return const Color(0xFF2457F5);
      case 'En progreso':
        return const Color(0xFF1273EA);
      case 'Resuelto':
        return const Color(0xFF20B46A);
      default:
        return const Color(0xFF173B5E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final compactLayout = MediaQuery.of(context).size.width < 430;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: compactLayout ? 12 : 20,
        vertical: 20,
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540),
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surfaceContainerHigh
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colorScheme.shadow.withOpacity(isDark ? 0.65 : 0.18),
              blurRadius: 28,
              offset: Offset(0, 18),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const _EditDialogHeader(),
                  const SizedBox(height: 20),
                  _EditResponsiveFields(
                    compactLayout: compactLayout,
                    leftChild: TextFormField(
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Titulo',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 4) {
                          return 'Introduce un titulo valido.';
                        }

                        return null;
                      },
                    ),
                    rightChild: TextFormField(
                      controller: _reporterController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Reportado por',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Este campo es obligatorio.';
                        }

                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  _EditResponsiveFields(
                    compactLayout: compactLayout,
                    leftChild: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                      ),
                      items: _statusOptions
                          .map(
                            (status) => DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _selectedStatus = value;
                        });
                      },
                    ),
                    rightChild: TextFormField(
                      controller: _timeLabelController,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Detectado',
                        hintText: 'Ej. Hoy, 10:35',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Este campo es obligatorio.';
                        }

                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  _EditPrioritySelector(
                    priorities: _priorityOptions,
                    selectedPriority: _selectedPriority,
                    onSelected: (value) {
                      setState(() {
                        _selectedPriority = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.info_outline_rounded,
                          color: _accentColor(_selectedStatus),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Los cambios se guardan en backend y mantienen el chat del ticket.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      height: 1.4,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text('Guardar cambios'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// endregion

// region Componentes Dashboard: cabecera del popup de editar ticket
class _EditDialogHeader extends StatelessWidget {
  const _EditDialogHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 14),
              Text(
                'Editar ticket',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.surfaceContainerHighest,
            foregroundColor: colorScheme.onSurface,
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Cerrar',
        ),
      ],
    );
  }
}
// endregion

// region Componentes Dashboard: distribucion adaptable del popup de editar ticket
class _EditResponsiveFields extends StatelessWidget {
  const _EditResponsiveFields({
    required this.compactLayout,
    required this.leftChild,
    required this.rightChild,
  });

  final bool compactLayout;
  final Widget leftChild;
  final Widget rightChild;

  @override
  Widget build(BuildContext context) {
    if (compactLayout) {
      return Column(
        children: <Widget>[
          leftChild,
          const SizedBox(height: 14),
          rightChild,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: leftChild),
        const SizedBox(width: 14),
        Expanded(child: rightChild),
      ],
    );
  }
}
// endregion

// region Componentes Dashboard: selector de prioridad del popup de editar ticket
class _EditPrioritySelector extends StatelessWidget {
  const _EditPrioritySelector({
    required this.priorities,
    required this.selectedPriority,
    required this.onSelected,
  });

  final List<String> priorities;
  final String selectedPriority;
  final ValueChanged<String> onSelected;

  Color _backgroundColor(String priority, {required bool isDark}) {
    switch (priority) {
      case 'Alta':
        return isDark ? const Color(0xFF41311F) : const Color(0xFFFFF1E2);
      case 'Media':
        return isDark ? const Color(0xFF45361C) : const Color(0xFFFFF3D6);
      case 'Baja':
        return isDark ? const Color(0xFF1C3A2C) : const Color(0xFFEDF9F2);
      default:
        return isDark ? const Color(0xFF223247) : const Color(0xFFF1F5F9);
    }
  }

  Color _foregroundColor(String priority) {
    switch (priority) {
      case 'Alta':
        return const Color(0xFFC0392B);
      case 'Media':
        return const Color(0xFF9B6B00);
      case 'Baja':
        return const Color(0xFF23915C);
      default:
        return const Color(0xFF173B5E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Prioridad',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: priorities
              .map(
                (priority) => ChoiceChip(
                  label: Text(priority),
                  selected: priority == selectedPriority,
                  backgroundColor: _backgroundColor(priority, isDark: isDark),
                  selectedColor: _foregroundColor(priority).withOpacity(0.14),
                  labelStyle: TextStyle(
                    color: _foregroundColor(priority),
                    fontWeight: FontWeight.w700,
                  ),
                  side: BorderSide(
                    color: priority == selectedPriority
                        ? _foregroundColor(priority)
                        : Colors.transparent,
                  ),
                  onSelected: (_) => onSelected(priority),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
// endregion
