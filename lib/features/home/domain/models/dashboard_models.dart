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
    required this.id,
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
    this.persistedMessageCount = 0,
  });

  final String id;
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
  final int persistedMessageCount;

  int get messageCount =>
      chatMessages.isNotEmpty ? chatMessages.length : persistedMessageCount;

  DashboardTicket copyWith({
    String? title,
    String? status,
    String? timeLabel,
    String? reporter,
    String? priorityLabel,
    Color? statusColor,
    Color? statusBackgroundColor,
    Color? priorityColor,
    Color? priorityBackgroundColor,
    Color? accentColor,
    List<DashboardTicketMessage>? chatMessages,
    int? persistedMessageCount,
  }) {
    return DashboardTicket(
      id: id,
      title: title ?? this.title,
      status: status ?? this.status,
      timeLabel: timeLabel ?? this.timeLabel,
      reporter: reporter ?? this.reporter,
      priorityLabel: priorityLabel ?? this.priorityLabel,
      statusColor: statusColor ?? this.statusColor,
      statusBackgroundColor:
          statusBackgroundColor ?? this.statusBackgroundColor,
      priorityColor: priorityColor ?? this.priorityColor,
      priorityBackgroundColor:
          priorityBackgroundColor ?? this.priorityBackgroundColor,
      accentColor: accentColor ?? this.accentColor,
      chatMessages: chatMessages ?? this.chatMessages,
      persistedMessageCount:
          persistedMessageCount ?? this.persistedMessageCount,
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
