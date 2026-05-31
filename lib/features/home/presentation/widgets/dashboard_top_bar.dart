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
    final colorScheme = Theme.of(context).colorScheme;

    final notificationButton = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surface,
            border: Border.all(
              color: colorScheme.outline,
              width: 1.2,
            ),
          ),
          child: Icon(
            Icons.campaign_outlined,
            color: colorScheme.onSurfaceVariant,
            size: 26,
          ),
        ),
        Positioned(
          top: 9,
          right: 10,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.tertiary.withOpacity(0.9),
              borderRadius: BorderRadius.circular(4),
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
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline,
              width: 1.2,
            ),
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
                sidebarCollapsed
                    ? Icons.density_medium_rounded
                    : Icons.density_small_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 28,
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
