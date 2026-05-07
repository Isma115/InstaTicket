// region Componentes Dashboard: barra superior del contenido
import 'package:flutter/material.dart';

class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({
    required this.sidebarCollapsed,
    required this.onToggleSidebar,
    super.key,
  });

  final bool sidebarCollapsed;
  final VoidCallback? onToggleSidebar;

  @override
  Widget build(BuildContext context) {
    final notificationButton = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE9EDF5)),
          ),
          child: const Icon(
            Icons.notifications_none,
            color: Color(0xFF7E8AA2),
            size: 28,
          ),
        ),
        const Positioned(
          top: 9,
          right: 10,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFF1F6BFF),
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 10,
              height: 10,
            ),
          ),
        ),
      ],
    );

    if (onToggleSidebar == null) {
      return notificationButton;
    }

    return Row(
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE9EDF5)),
          ),
          child: IconButton(
            tooltip: sidebarCollapsed
                ? 'Expandir panel lateral'
                : 'Comprimir panel lateral',
            onPressed: onToggleSidebar,
            icon: AnimatedRotation(
              duration: const Duration(milliseconds: 180),
              turns: sidebarCollapsed ? 0 : 0.5,
              child: Icon(
                sidebarCollapsed ? Icons.menu : Icons.menu_open,
                color: const Color(0xFF8A98B3),
                size: 30,
              ),
            ),
          ),
        ),
        const Spacer(),
        notificationButton,
      ],
    );
  }
}
// endregion
