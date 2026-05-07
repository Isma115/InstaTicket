// region Lógica Dashboard: modelos de datos para el panel principal
import 'package:flutter/material.dart';

class DashboardMetric {
  const DashboardMetric({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
}

class DashboardTicket {
  const DashboardTicket({
    required this.code,
    required this.title,
    required this.status,
    required this.timeLabel,
    required this.reporter,
    required this.priorityLabel,
    required this.statusColor,
    required this.statusBackgroundColor,
    required this.priorityColor,
    required this.priorityBackgroundColor,
    required this.accentColor,
    required this.chatMessages,
  });

  final String code;
  final String title;
  final String status;
  final String timeLabel;
  final String reporter;
  final String priorityLabel;
  final Color statusColor;
  final Color statusBackgroundColor;
  final Color priorityColor;
  final Color priorityBackgroundColor;
  final Color accentColor;
  final List<DashboardTicketMessage> chatMessages;

  int get messageCount => chatMessages.length;

  DashboardTicket copyWith({
    List<DashboardTicketMessage>? chatMessages,
  }) {
    return DashboardTicket(
      code: code,
      title: title,
      status: status,
      timeLabel: timeLabel,
      reporter: reporter,
      priorityLabel: priorityLabel,
      statusColor: statusColor,
      statusBackgroundColor: statusBackgroundColor,
      priorityColor: priorityColor,
      priorityBackgroundColor: priorityBackgroundColor,
      accentColor: accentColor,
      chatMessages: chatMessages ?? this.chatMessages,
    );
  }
}

class DashboardTicketMessage {
  const DashboardTicketMessage({
    required this.id,
    required this.authorName,
    required this.authorRoleLabel,
    required this.body,
    required this.timeLabel,
    this.parentMessageId,
    this.isCurrentUser = false,
  });

  final String id;
  final String authorName;
  final String authorRoleLabel;
  final String body;
  final String timeLabel;
  final String? parentMessageId;
  final bool isCurrentUser;
}

class DashboardMenuEntry {
  const DashboardMenuEntry({
    required this.label,
    required this.icon,
    this.highlighted = false,
  });

  final String label;
  final IconData icon;
  final bool highlighted;
}

class DashboardSupportGroup {
  const DashboardSupportGroup({
    required this.title,
    required this.subtitle,
    required this.membersLabel,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final String membersLabel;
  final IconData icon;
  final Color accentColor;
}

class DashboardViewData {
  const DashboardViewData({
    required this.metrics,
    required this.recentTickets,
    required this.menuEntries,
    required this.supportGroups,
    required this.floatingActionLabel,
  });

  final List<DashboardMetric> metrics;
  final List<DashboardTicket> recentTickets;
  final List<DashboardMenuEntry> menuEntries;
  final List<DashboardSupportGroup> supportGroups;
  final String floatingActionLabel;
}
// endregion
