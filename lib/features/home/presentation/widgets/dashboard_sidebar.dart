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
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: const Color(0xFFE9EDF5),
            width: collapsed ? 1 : 1.2,
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
            color: const Color(0xFFE8EDF5),
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
    final logoSize = collapsed ? 52.0 : 60.0;
    final logo = Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFFEFF5FF),
            Color(0xFFDCE9FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Transform.rotate(
            angle: -0.2,
            child: const Icon(
              Icons.receipt_long,
              size: 28,
              color: Color(0xFF1F6BFF),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF9AC0FF)),
              ),
              child: const Icon(
                Icons.priority_high,
                size: 12,
                color: Color(0xFF1F6BFF),
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
    final backgroundColor =
        entry.highlighted ? const Color(0xFF1F6BFF) : Colors.transparent;
    final foregroundColor =
        entry.highlighted ? Colors.white : const Color(0xFF657697);

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
        boxShadow: entry.highlighted
            ? <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF1F6BFF).withOpacity(0.22),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
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
    return Center(
      child: Column(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF0F5FF),
            ),
            child: const Icon(
              Icons.person,
              color: Color(0xFF1F6BFF),
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
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF7C88A1),
            ),
          ),
        ],
      ),
    );
  }
}
