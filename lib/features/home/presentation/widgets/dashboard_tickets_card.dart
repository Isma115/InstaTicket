// region Componentes Dashboard: listado de tickets recientes
import 'package:flutter/material.dart';

import '../../domain/models/dashboard_models.dart';

class DashboardTicketsCard extends StatelessWidget {
  const DashboardTicketsCard({
    required this.tickets,
    super.key,
  });

  final List<DashboardTicket> tickets;

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
  });

  final DashboardTicket ticket;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: ticket.accentColor.withOpacity(0.035),
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

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ticket.accentColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(18),
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
                            const SizedBox(height: 10),
                            _TicketStatusChip(ticket: ticket, theme: theme),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                ticket.title,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: 16,
                                  color: const Color(0xFF1E344F),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: _TicketStatusChip(
                                ticket: ticket,
                                theme: theme,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 14),
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
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                    const _TicketActionIcon(
                      icon: Icons.chat_bubble_outline_rounded,
                    ),
                    const SizedBox(width: 10),
                    const _TicketActionIcon(icon: Icons.edit_outlined),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
// endregion

class _TicketStatusChip extends StatelessWidget {
  const _TicketStatusChip({
    required this.ticket,
    required this.theme,
  });

  final DashboardTicket ticket;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: ticket.statusBackgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        ticket.status,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: ticket.statusColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

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
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7FA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Icon(
        icon,
        color: const Color(0xFF6B7C92),
        size: 16,
      ),
    );
  }
}
