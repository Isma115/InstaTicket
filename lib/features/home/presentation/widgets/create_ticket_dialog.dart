// region Componentes Dashboard: imports del popup de crear ticket
import 'package:flutter/material.dart';

import '../../../../core/models/auth_user.dart';
import '../../../../core/models/user_role.dart';
// endregion

// region Lógica Dashboard: modelo mock del popup de crear ticket
class CreateTicketDraft {
  const CreateTicketDraft({
    required this.title,
    required this.category,
    required this.priority,
  });

  final String title;
  final String category;
  final String priority;
}
// endregion

// region Componentes Dashboard: popup de crear ticket
class CreateTicketDialog extends StatefulWidget {
  const CreateTicketDialog({
    required this.user,
    required this.actionLabel,
    super.key,
  });

  final AuthUser user;
  final String actionLabel;

  @override
  State<CreateTicketDialog> createState() => _CreateTicketDialogState();
}
// endregion

// region Lógica Dashboard: estado del popup de crear ticket
class _CreateTicketDialogState extends State<CreateTicketDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _assetController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late String _selectedCategory;
  late String _selectedPriority;
  bool _notifyByEmail = true;
  bool _needsFollowUp = false;

  List<String> get _categories {
    switch (widget.user.role) {
      case UserRole.tecnico:
        return const <String>[
          'Hardware',
          'Software',
          'Accesos',
          'Red',
        ];
      case UserRole.admin:
        return const <String>[
          'Operaciones',
          'Permisos',
          'SLA',
          'Backoffice',
        ];
      case UserRole.cliente:
        return const <String>[
          'Incidencia',
          'Consulta',
          'Facturacion',
          'Solicitud',
        ];
    }
  }

  List<String> get _priorities => const <String>[
        'Baja',
        'Media',
        'Alta',
        'Urgente',
      ];

  String get _assetLabel {
    switch (widget.user.role) {
      case UserRole.tecnico:
        return 'Equipo o activo';
      case UserRole.admin:
        return 'Area o flujo';
      case UserRole.cliente:
        return 'Ubicacion o producto';
    }
  }

  String get _descriptionHint {
    switch (widget.user.role) {
      case UserRole.tecnico:
        return 'Describe el fallo detectado, pasos previos y estado actual.';
      case UserRole.admin:
        return 'Resume el bloqueo, su impacto y la accion que necesitas.';
      case UserRole.cliente:
        return 'Explica que ha ocurrido y como te afecta la incidencia.';
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first;
    _selectedPriority = 'Media';
    _assetController.text = widget.user.role == UserRole.cliente
        ? 'Portal de cliente'
        : 'Sede central';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _assetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      CreateTicketDraft(
        title: _titleController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final compactLayout = mediaQuery.size.width < 430;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: compactLayout ? 12 : 20,
        vertical: 20,
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAFC),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFDCE5EE)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x1E173B5E),
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
                  _DialogHeader(
                    actionLabel: widget.actionLabel,
                  ),
                  const SizedBox(height: 20),
                  _ResponsiveFields(
                    compactLayout: compactLayout,
                    leftChild: TextFormField(
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Titulo',
                        hintText: 'Ej. Error al acceder al panel',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 4) {
                          return 'Introduce un titulo valido.';
                        }

                        return null;
                      },
                    ),
                    rightChild: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                      ),
                      items: _categories
                          .map(
                            (category) => DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ResponsiveFields(
                    compactLayout: compactLayout,
                    leftChild: TextFormField(
                      initialValue: widget.user.name,
                      decoration: const InputDecoration(
                        labelText: 'Solicitante',
                      ),
                      readOnly: true,
                    ),
                    rightChild: TextFormField(
                      controller: _assetController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: _assetLabel,
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
                  _PrioritySelector(
                    priorities: _priorities,
                    selectedPriority: _selectedPriority,
                    onSelected: (value) {
                      setState(() {
                        _selectedPriority = value;
                      });
                    },
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 5,
                    maxLines: 7,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      labelText: 'Descripcion',
                      hintText: _descriptionHint,
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length < 12) {
                        return 'Describe la solicitud con mas detalle.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  const _AttachmentsPlaceholder(),
                  const SizedBox(height: 10),
                  SwitchListTile.adaptive(
                    value: _notifyByEmail,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Notificar por email al crear el ticket'),
                    subtitle: const Text(
                      'Accion simulada para la demo frontend.',
                    ),
                    activeColor: const Color(0xFF2457F5),
                    onChanged: (value) {
                      setState(() {
                        _notifyByEmail = value;
                      });
                    },
                  ),
                  SwitchListTile.adaptive(
                    value: _needsFollowUp,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Marcar seguimiento prioritario'),
                    subtitle: const Text(
                      'Permite destacar la incidencia dentro del flujo mock.',
                    ),
                    activeColor: const Color(0xFF2457F5),
                    onChanged: (value) {
                      setState(() {
                        _needsFollowUp = value;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
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
                            backgroundColor: const Color(0xFF173B5E),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(widget.actionLabel),
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

// region Componentes Dashboard: cabecera del popup de crear ticket
class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.actionLabel,
  });

  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 14),
              Text(
                actionLabel,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF173B5E),
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
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF173B5E),
            side: const BorderSide(color: Color(0xFFD9E4EE)),
          ),
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Cerrar',
        ),
      ],
    );
  }
}
// endregion

// region Componentes Dashboard: distribucion adaptable del popup de crear ticket
class _ResponsiveFields extends StatelessWidget {
  const _ResponsiveFields({
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

// region Componentes Dashboard: selector de prioridad del popup de crear ticket
class _PrioritySelector extends StatelessWidget {
  const _PrioritySelector({
    required this.priorities,
    required this.selectedPriority,
    required this.onSelected,
  });

  final List<String> priorities;
  final String selectedPriority;
  final ValueChanged<String> onSelected;

  Color _backgroundColor(String priority) {
    switch (priority) {
      case 'Urgente':
        return const Color(0xFFFFEEE9);
      case 'Alta':
        return const Color(0xFFFFF1E2);
      case 'Media':
        return const Color(0xFFEDF4FF);
      case 'Baja':
        return const Color(0xFFEDF9F2);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _foregroundColor(String priority) {
    switch (priority) {
      case 'Urgente':
        return const Color(0xFFC23A2B);
      case 'Alta':
        return const Color(0xFFB26A00);
      case 'Media':
        return const Color(0xFF1F6BFF);
      case 'Baja':
        return const Color(0xFF23915C);
      default:
        return const Color(0xFF173B5E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Prioridad',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF173B5E),
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
                  backgroundColor: _backgroundColor(priority),
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

// region Componentes Dashboard: tarjeta mock de adjuntos del popup de crear ticket
class _AttachmentsPlaceholder extends StatelessWidget {
  const _AttachmentsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD7E2EC)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.attach_file_rounded,
              color: Color(0xFF1F6BFF),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Adjuntos',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF173B5E),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Zona visual preparada para integrar subida de capturas y documentos.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF70839A),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: null,
            child: const Text('Proximamente'),
          ),
        ],
      ),
    );
  }
}
// endregion
