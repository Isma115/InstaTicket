// region Componentes Dashboard: listado de tickets recientes
import 'package:flutter/material.dart';

import '../../domain/models/dashboard_models.dart';

class DashboardTicketsCard extends StatefulWidget {
  const DashboardTicketsCard({
    required this.tickets,
    required this.onOpenChat,
    required this.onEditTicket,
    required this.canDeleteTicket,
    required this.onDeleteTicket,
    super.key,
  });

  final List<DashboardTicket> tickets;
  final ValueChanged<DashboardTicket> onOpenChat;
  final ValueChanged<DashboardTicket> onEditTicket;
  final bool canDeleteTicket;
  final ValueChanged<DashboardTicket> onDeleteTicket;

  @override
  State<DashboardTicketsCard> createState() => _DashboardTicketsCardState();
}

class _DashboardTicketsCardState extends State<DashboardTicketsCard> {
  final Set<String> _expandedTicketIds = <String>{};
  final Set<String> _collapsedDefaultTicketIds = <String>{};

  @override
  void didUpdateWidget(covariant DashboardTicketsCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    final validTicketIds = widget.tickets.map((ticket) => ticket.id).toSet();
    _expandedTicketIds
        .removeWhere((ticketId) => !validTicketIds.contains(ticketId));
    _collapsedDefaultTicketIds
        .removeWhere((ticketId) => !validTicketIds.contains(ticketId));
  }

  bool _isDefaultExpanded(int index) => index < 3;

  bool _isExpanded({
    required String ticketId,
    required int index,
  }) {
    if (_expandedTicketIds.contains(ticketId)) {
      return true;
    }

    if (_collapsedDefaultTicketIds.contains(ticketId)) {
      return false;
    }

    return _isDefaultExpanded(index);
  }

  void _toggleTicket({
    required String ticketId,
    required int index,
  }) {
    final isExpanded = _isExpanded(ticketId: ticketId, index: index);

    setState(() {
      if (isExpanded) {
        _expandedTicketIds.remove(ticketId);
        if (_isDefaultExpanded(index)) {
          _collapsedDefaultTicketIds.add(ticketId);
        }
        return;
      }

      _collapsedDefaultTicketIds.remove(ticketId);
      _expandedTicketIds.add(ticketId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: widget.tickets
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _TicketRow(
                key: ValueKey<String>(entry.value.id),
                ticket: entry.value,
                theme: theme,
                isExpanded: _isExpanded(
                  ticketId: entry.value.id,
                  index: entry.key,
                ),
                onOpenChat: widget.onOpenChat,
                onEditTicket: widget.onEditTicket,
                canDeleteTicket: widget.canDeleteTicket,
                onDeleteTicket: widget.onDeleteTicket,
                onToggleExpanded: () => _toggleTicket(
                  ticketId: entry.value.id,
                  index: entry.key,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
// endregion

// region Componentes Dashboard: fila individual de ticket
class _TicketRow extends StatelessWidget {
  const _TicketRow({
    required this.ticket,
    required this.theme,
    required this.isExpanded,
    required this.onOpenChat,
    required this.onEditTicket,
    required this.canDeleteTicket,
    required this.onDeleteTicket,
    required this.onToggleExpanded,
    super.key,
  });

  final DashboardTicket ticket;
  final ThemeData theme;
  final bool isExpanded;
  final ValueChanged<DashboardTicket> onOpenChat;
  final ValueChanged<DashboardTicket> onEditTicket;
  final bool canDeleteTicket;
  final ValueChanged<DashboardTicket> onDeleteTicket;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    final isResolved = ticket.status == 'Resuelto';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isResolved ? const Color(0xFFD8F1E5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color:
                isResolved ? const Color(0x2236C978) : const Color(0x1020325B),
            blurRadius: isResolved ? 20 : 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isResolved ? const Color(0xFF4EDAA0) : const Color(0xFFE6EDF4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: onToggleExpanded,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: BoxDecoration(
                color: _headerBackgroundColor(ticket),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: ticket.accentColor.withOpacity(
                      isExpanded ? 0.18 : 0,
                    ),
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (ticket.status == 'Resuelto') ...<Widget>[
                    Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF36C978),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                  Expanded(
                    child: Text(
                      ticket.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        color: const Color(0xFF1E344F),
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.72),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF173B5E),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _TicketMetaLine(
                    label: 'Reportado por',
                    value: ticket.reporter,
                    theme: theme,
                  ),
                  const SizedBox(height: 4),
                  _TicketMetaLine(
                    label: 'Detectado',
                    value: ticket.timeLabel,
                    theme: theme,
                  ),
                  const SizedBox(height: 4),
                  _TicketMetaLine(
                    label: 'Estado',
                    value: ticket.status,
                    theme: theme,
                    textColor: ticket.statusColor,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: <Widget>[
                      _TicketActionIcon(
                        icon: Icons.chat_bubble_outline_rounded,
                        badgeLabel: ticket.messageCount.toString(),
                        onTap: () => onOpenChat(ticket),
                      ),
                      const SizedBox(width: 10),
                      _TicketActionIcon(
                        icon: Icons.edit_outlined,
                        onTap: () => onEditTicket(ticket),
                      ),
                      if (canDeleteTicket) ...<Widget>[
                        const SizedBox(width: 10),
                        _TicketActionIcon(
                          icon: Icons.delete_outline_rounded,
                          iconColor: const Color(0xFFC0392B),
                          backgroundColor: const Color(0xFFFFECE8),
                          onTap: () => onDeleteTicket(ticket),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
            sizeCurve: Curves.easeOutCubic,
            firstCurve: Curves.easeInOut,
            secondCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}
// endregion

Color _headerBackgroundColor(DashboardTicket ticket) {
  if (ticket.status == 'Resuelto') {
    return const Color(0xFFD8F1E5);
  }

  switch (ticket.priorityLabel) {
    case 'Alta':
      return const Color(0xFFFFE1DD);
    case 'Media':
      return const Color(0xFFFFF0C9);
    case 'Baja':
      return const Color(0xFFD8F1E5);
    default:
      return ticket.accentColor.withOpacity(0.16);
  }
}

class _TicketMetaLine extends StatelessWidget {
  const _TicketMetaLine({
    required this.label,
    required this.value,
    required this.theme,
    this.textColor,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodySmall?.copyWith(
          color: const Color(0xFF6A7C92),
          height: 1.4,
        ),
        children: <InlineSpan>[
          TextSpan(text: '$label: '),
          TextSpan(
            text: value,
            style: TextStyle(
              color: textColor ?? const Color(0xFF173B5E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketActionIcon extends StatelessWidget {
  const _TicketActionIcon({
    required this.icon,
    this.badgeLabel,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
  });

  final IconData icon;
  final String? badgeLabel;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: backgroundColor ?? const Color(0xFFF3F7FA),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(
              icon,
              color: iconColor ?? const Color(0xFF6B7C92),
              size: 16,
            ),
          ),
          if (badgeLabel != null)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF1F6BFF),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  badgeLabel!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
