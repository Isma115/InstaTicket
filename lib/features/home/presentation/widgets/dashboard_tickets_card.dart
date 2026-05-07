// region Componentes Dashboard: listado de tickets recientes
import 'package:flutter/material.dart';

import '../../domain/models/dashboard_models.dart';

class DashboardTicketsCard extends StatelessWidget {
  const DashboardTicketsCard({
    required this.tickets,
    required this.onOpenChat,
    super.key,
  });

  final List<DashboardTicket> tickets;
  final ValueChanged<DashboardTicket> onOpenChat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: tickets
          .map(
            (ticket) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _TicketRow(
                ticket: ticket,
                theme: theme,
                onOpenChat: onOpenChat,
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
    required this.onOpenChat,
  });

  final DashboardTicket ticket;
  final ThemeData theme;
  final ValueChanged<DashboardTicket> onOpenChat;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6EDF4)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1020325B),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compactLayout = constraints.maxWidth < 330;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                decoration: BoxDecoration(
                  color: ticket.accentColor.withOpacity(0.10),
                  border: Border(
                    bottom: BorderSide(
                      color: ticket.accentColor.withOpacity(0.08),
                    ),
                  ),
                ),
                child: compactLayout
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            ticket.title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 16,
                              color: const Color(0xFF1E344F),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            ticket.title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 16,
                              color: const Color(0xFF1E344F),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
              Padding(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Prioridad',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF6A7C92),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _TicketPriorityChip(ticket: ticket, theme: theme),
                          ],
                        ),
                        const Spacer(),
                        _TicketActionIcon(
                          icon: Icons.chat_bubble_outline_rounded,
                          badgeLabel: ticket.messageCount.toString(),
                          onTap: () => onOpenChat(ticket),
                        ),
                        const SizedBox(width: 10),
                        const _TicketActionIcon(icon: Icons.edit_outlined),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
// endregion

class _TicketPriorityChip extends StatelessWidget {
  const _TicketPriorityChip({
    required this.ticket,
    required this.theme,
  });

  final DashboardTicket ticket;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: ticket.priorityBackgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        ticket.priorityLabel,
        style: theme.textTheme.bodySmall?.copyWith(
          color: ticket.priorityColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
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
  });

  final IconData icon;
  final String? badgeLabel;
  final VoidCallback? onTap;

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
              color: const Color(0xFFF3F7FA),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6B7C92),
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
