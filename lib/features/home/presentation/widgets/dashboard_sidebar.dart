// region Componentes Dashboard: barra lateral izquierda
import 'package:flutter/material.dart';

import '../../../../core/models/auth_user.dart';
import '../../domain/models/dashboard_models.dart';

class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({
    required this.user,
    required this.entries,
    required this.collapsed,
    required this.width,
    required this.onLogout,
    super.key,
  });

  final AuthUser user;
  final List<DashboardMenuEntry> entries;
  final bool collapsed;
  final double width;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: width,
      padding: EdgeInsets.fromLTRB(
        collapsed ? 10 : 22,
        collapsed ? 20 : 24,
        collapsed ? 10 : 18,
        collapsed ? 20 : 24,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: colorScheme.outline,
            width: collapsed ? 1.2 : 1.4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SidebarBrand(
            collapsed: collapsed,
          ),
          SizedBox(height: collapsed ? 20 : 34),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: entries
                    .map(
                      (entry) => Padding(
                        padding: EdgeInsets.only(bottom: collapsed ? 10 : 14),
                        child: _SidebarEntry(
                          entry: entry,
                          compact: true,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          Divider(
            color: colorScheme.outlineVariant,
            height: 1,
            thickness: 1,
          ),
          SizedBox(height: collapsed ? 14 : 20),
          _CollapsedSidebarFooter(onLogout: onLogout),
        ],
      ),
    );
  }
}
// endregion

// region Componentes Dashboard: cabecera de marca del panel lateral
class _SidebarBrand extends StatelessWidget {
  const _SidebarBrand({
    required this.collapsed,
  });

  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoSize = collapsed ? 52.0 : 60.0;
    final logo = Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        color:
            isDark ? colorScheme.surfaceContainerHigh : const Color(0xFFEAF2EC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outline,
          width: 1.3,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Transform.rotate(
            angle: -0.1,
            child: Icon(
              Icons.widgets_rounded,
              size: 28,
              color: colorScheme.primary,
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Icon(
                Icons.bolt_rounded,
                size: 12,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );

    return Center(child: logo);
  }
}
// endregion

// region Componentes Dashboard: opción de navegación lateral
class _SidebarEntry extends StatelessWidget {
  const _SidebarEntry({
    required this.entry,
    required this.compact,
  });

  final DashboardMenuEntry entry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor =
        entry.highlighted ? colorScheme.primary : Colors.transparent;
    final foregroundColor = entry.highlighted
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 16,
        vertical: compact ? 14 : 16,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(compact ? 16 : 18),
        border: Border.all(
          color: entry.highlighted
              ? colorScheme.primary.withOpacity(0.45)
              : colorScheme.outlineVariant,
        ),
        boxShadow: entry.highlighted
            ? <BoxShadow>[
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.16),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment:
            compact ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: <Widget>[
          Icon(entry.icon, color: foregroundColor, size: 24),
          if (!compact) ...<Widget>[
            const SizedBox(width: 14),
            Flexible(
              child: Text(
                entry.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      entry.highlighted ? FontWeight.w700 : FontWeight.w500,
                  color: foregroundColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
// endregion

class _CollapsedSidebarFooter extends StatelessWidget {
  const _CollapsedSidebarFooter({
    required this.onLogout,
  });

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primaryContainer,
            ),
            child: Icon(
              Icons.account_circle_outlined,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: onLogout,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 30,
              minHeight: 30,
            ),
            icon: Icon(
              Icons.logout_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
