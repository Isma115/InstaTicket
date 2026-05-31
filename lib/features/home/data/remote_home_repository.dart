// region Lógica Dashboard: repositorio remoto para métricas, tickets y perfil
import 'package:flutter/material.dart';

import '../../../core/data/api_client.dart';
import '../../../core/models/auth_user.dart';
import '../../../core/models/user_role.dart';
import '../domain/models/dashboard_models.dart';

class RemoteHomeRepository {
  RemoteHomeRepository._();

  static final RemoteHomeRepository instance = RemoteHomeRepository._();

  final ApiClient _client = ApiClient.instance;

  Future<DashboardViewData> loadDashboard(AuthUser user) async {
    final payload = await _client.getJson(
      '/api/dashboard',
      query: <String, String>{
        'email': user.email.trim().toLowerCase(),
      },
    );

    final dashboard = payload['dashboard'];
    if (dashboard is! Map<String, dynamic>) {
      throw const ApiException('Respuesta de dashboard invalida.');
    }

    final metrics = _mapMetrics(dashboard['metrics']);
    final recentTickets = _mapTickets(dashboard['recentTickets']);
    final supportGroups = _mapSupportGroups(
      dashboard['supportGroups'],
      user.role,
    );

    return DashboardViewData(
      metrics: metrics,
      recentTickets: recentTickets,
      menuEntries: const <DashboardMenuEntry>[
        DashboardMenuEntry(
          label: 'Inicio',
          icon: Icons.home_rounded,
          highlighted: true,
        ),
        DashboardMenuEntry(
          label: 'Tickets',
          icon: Icons.inventory_2_outlined,
        ),
        DashboardMenuEntry(
          label: 'Grupos',
          icon: Icons.groups_2_outlined,
        ),
        DashboardMenuEntry(
          label: 'Perfil',
          icon: Icons.person_outline_rounded,
        ),
      ],
      supportGroups: supportGroups,
      floatingActionLabel:
          dashboard['floatingActionLabel']?.toString().trim().isNotEmpty == true
              ? dashboard['floatingActionLabel'].toString().trim()
              : (user.role == UserRole.cliente
                  ? 'Nueva incidencia'
                  : 'Nuevo ticket'),
    );
  }

  Future<DashboardTicket> createTicket({
    required AuthUser user,
    required String title,
    required String description,
    required String category,
    required String priority,
    required String assetReference,
    required bool notifyByEmail,
    required bool needsFollowUp,
  }) async {
    final payload = await _client.postJson(
      '/api/tickets',
      body: <String, dynamic>{
        'userEmail': user.email.trim().toLowerCase(),
        'title': title.trim(),
        'description': description.trim(),
        'category': category.trim(),
        'priority': priority.trim(),
        'assetReference': assetReference.trim(),
        'notifyByEmail': notifyByEmail,
        'needsFollowUp': needsFollowUp,
      },
    );

    final ticketMap = payload['ticket'];
    if (ticketMap is! Map<String, dynamic>) {
      throw const ApiException('Respuesta de creación de ticket invalida.');
    }

    return _mapTicket(ticketMap);
  }

  Future<DashboardTicket> updateTicket({
    required String ticketId,
    required String title,
    required String status,
    required String priority,
  }) async {
    final payload = await _client.putJson(
      '/api/tickets/$ticketId',
      body: <String, dynamic>{
        'title': title.trim(),
        'status': status.trim(),
        'priority': priority.trim(),
      },
    );

    final ticketMap = payload['ticket'];
    if (ticketMap is! Map<String, dynamic>) {
      throw const ApiException('Respuesta de edición de ticket invalida.');
    }

    return _mapTicket(ticketMap);
  }

  Future<void> deleteTicket({
    required String ticketId,
  }) async {
    await _client.deleteJson('/api/tickets/$ticketId');
  }

  Future<List<DashboardTicketMessage>> fetchComments({
    required String ticketId,
    required String currentUserEmail,
  }) async {
    final payload = await _client.getJson(
      '/api/tickets/$ticketId/comments',
      query: <String, String>{
        'currentUserEmail': currentUserEmail.trim().toLowerCase(),
      },
    );

    return _mapMessages(payload['comments']);
  }

  Future<List<DashboardTicketMessage>> createComment({
    required String ticketId,
    required String currentUserEmail,
    required String body,
    String? parentMessageId,
  }) async {
    final payload = await _client.postJson(
      '/api/tickets/$ticketId/comments',
      body: <String, dynamic>{
        'userEmail': currentUserEmail.trim().toLowerCase(),
        'body': body.trim(),
        'parentMessageId': parentMessageId,
      },
    );

    return _mapMessages(payload['comments']);
  }

  Future<AuthUser> updateProfile({
    required AuthUser user,
    required String name,
    required String? lastName,
    required String? photoUrl,
  }) async {
    final payload = await _client.putJson(
      '/api/users/profile',
      body: <String, dynamic>{
        'email': user.email.trim().toLowerCase(),
        'name': name.trim(),
        'lastName': (lastName ?? '').trim(),
        'photoUrl': (photoUrl ?? '').trim(),
        'password': user.password,
      },
    );

    final userMap = payload['user'];
    if (userMap is! Map<String, dynamic>) {
      throw const ApiException('Respuesta de perfil invalida.');
    }

    return _mapAuthUser(userMap);
  }

  Future<AuthUser> updateTwoFactor({
    required AuthUser user,
    required bool enabled,
  }) async {
    final payload = await _client.patchJson(
      '/api/users/two-factor',
      body: <String, dynamic>{
        'email': user.email.trim().toLowerCase(),
        'enabled': enabled,
        'password': user.password,
      },
    );

    final userMap = payload['user'];
    if (userMap is! Map<String, dynamic>) {
      throw const ApiException('Respuesta de doble autenticación invalida.');
    }

    return _mapAuthUser(userMap);
  }

  List<DashboardMetric> _mapMetrics(dynamic rawMetrics) {
    final metrics = rawMetrics is Map<String, dynamic>
        ? rawMetrics
        : const <String, dynamic>{};

    final abiertos = metrics['abiertos']?.toString() ?? '0';
    final enProgreso = metrics['enProgreso']?.toString() ?? '0';
    final resueltos = metrics['resueltos']?.toString() ?? '0';
    final total = metrics['total']?.toString() ?? '0';

    return <DashboardMetric>[
      DashboardMetric(
        title: 'Abiertos',
        value: abiertos,
        icon: Icons.folder_outlined,
        iconColor: const Color(0xFF1F6BFF),
        iconBackgroundColor: const Color(0xFFEDF4FF),
      ),
      DashboardMetric(
        title: 'En progreso',
        value: enProgreso,
        icon: Icons.access_time_outlined,
        iconColor: const Color(0xFFFFAF1A),
        iconBackgroundColor: const Color(0xFFFFF7E7),
      ),
      DashboardMetric(
        title: 'Resueltos',
        value: resueltos,
        icon: Icons.check_outlined,
        iconColor: const Color(0xFF20B46A),
        iconBackgroundColor: const Color(0xFFEEFBF3),
      ),
      DashboardMetric(
        title: 'Total tickets',
        value: total,
        icon: Icons.bar_chart_outlined,
        iconColor: const Color(0xFF6B5AF3),
        iconBackgroundColor: const Color(0xFFF3F0FF),
      ),
    ];
  }

  List<DashboardTicket> _mapTickets(dynamic rawTickets) {
    if (rawTickets is! List) {
      return const <DashboardTicket>[];
    }

    return rawTickets
        .whereType<Map<String, dynamic>>()
        .map(_mapTicket)
        .toList(growable: false);
  }

  DashboardTicket _mapTicket(Map<String, dynamic> json) {
    final status = json['status']?.toString().trim() ?? 'Abierto';
    final priority = json['priority']?.toString().trim() ?? 'Media';
    final statusPalette = _statusPalette(status);
    final priorityPalette = _priorityPalette(priority);

    return DashboardTicket(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString().trim().isNotEmpty == true
          ? json['title'].toString().trim()
          : 'Ticket sin titulo',
      status: status,
      timeLabel: json['timeLabel']?.toString().trim().isNotEmpty == true
          ? json['timeLabel'].toString().trim()
          : 'Sin fecha',
      reporter: json['reporter']?.toString().trim().isNotEmpty == true
          ? json['reporter'].toString().trim()
          : 'Sin solicitante',
      priorityLabel: priority,
      statusColor: statusPalette.foreground,
      statusBackgroundColor: statusPalette.background,
      priorityColor: priorityPalette.foreground,
      priorityBackgroundColor: priorityPalette.background,
      accentColor: statusPalette.accent,
      chatMessages: const <DashboardTicketMessage>[],
      persistedMessageCount: _toInt(json['messageCount']),
    );
  }

  List<DashboardTicketMessage> _mapMessages(dynamic rawMessages) {
    if (rawMessages is! List) {
      return const <DashboardTicketMessage>[];
    }

    return rawMessages
        .whereType<Map<String, dynamic>>()
        .map(
          (json) => DashboardTicketMessage(
            id: json['id']?.toString() ?? '',
            authorName: json['authorName']?.toString().trim().isNotEmpty == true
                ? json['authorName'].toString().trim()
                : 'Usuario',
            authorRoleLabel:
                _roleLabelFromSlug(json['authorRoleLabel']?.toString() ?? ''),
            body: json['body']?.toString() ?? '',
            timeLabel: json['timeLabel']?.toString().trim().isNotEmpty == true
                ? json['timeLabel'].toString().trim()
                : 'Ahora',
            parentMessageId: json['parentMessageId']?.toString(),
            isCurrentUser: json['isCurrentUser'] == true,
          ),
        )
        .toList(growable: false);
  }

  List<DashboardSupportGroup> _mapSupportGroups(
      dynamic rawGroups, UserRole role) {
    if (rawGroups is! List) {
      return _defaultSupportGroups(role);
    }

    final groups = rawGroups.whereType<Map<String, dynamic>>().toList();

    if (groups.isEmpty) {
      return _defaultSupportGroups(role);
    }

    return groups.asMap().entries.map((entry) {
      final index = entry.key;
      final group = entry.value;
      final palette = _groupPalette(index);

      return DashboardSupportGroup(
        title: group['title']?.toString().trim().isNotEmpty == true
            ? group['title'].toString().trim()
            : 'Grupo soporte',
        subtitle: group['subtitle']?.toString().trim().isNotEmpty == true
            ? group['subtitle'].toString().trim()
            : 'Sin descripcion',
        membersLabel: '${_toInt(group['membersCount'])} miembros',
        icon: palette.icon,
        accentColor: palette.color,
      );
    }).toList(growable: false);
  }

  List<DashboardSupportGroup> _defaultSupportGroups(UserRole role) {
    final suffix = role == UserRole.cliente ? 'de soporte' : 'operativos';

    return <DashboardSupportGroup>[
      DashboardSupportGroup(
        title: 'Mesa principal',
        subtitle: 'Cobertura diaria $suffix',
        membersLabel: '0 miembros',
        icon: Icons.support_agent_rounded,
        accentColor: const Color(0xFF2457F5),
      ),
      const DashboardSupportGroup(
        title: 'Incidencias',
        subtitle: 'Escalado de casos críticos',
        membersLabel: '0 miembros',
        icon: Icons.warning_amber_rounded,
        accentColor: Color(0xFFE58B00),
      ),
    ];
  }

  _StatusPalette _statusPalette(String status) {
    switch (normalizeStatus(status)) {
      case 'EN_PROGRESO':
        return const _StatusPalette(
          foreground: Color(0xFFFFAF1A),
          background: Color(0xFFFFF7E8),
          accent: Color(0xFF1273EA),
        );
      case 'RESUELTO':
      case 'CERRADO':
        return const _StatusPalette(
          foreground: Color(0xFF20B46A),
          background: Color(0xFFEEFBF3),
          accent: Color(0xFF20B46A),
        );
      case 'ABIERTO':
      default:
        return const _StatusPalette(
          foreground: Color(0xFF1F6BFF),
          background: Color(0xFFEEF5FF),
          accent: Color(0xFF2F80ED),
        );
    }
  }

  _PriorityPalette _priorityPalette(String priority) {
    switch (normalizeStatus(priority)) {
      case 'URGENTE':
      case 'ALTA':
        return const _PriorityPalette(
          foreground: Color(0xFFC0392B),
          background: Color(0xFFFFE9E6),
        );
      case 'BAJA':
        return const _PriorityPalette(
          foreground: Color(0xFF2D6A4F),
          background: Color(0xFFE6F6EC),
        );
      case 'MEDIA':
      default:
        return const _PriorityPalette(
          foreground: Color(0xFF9B6B00),
          background: Color(0xFFFFF3D6),
        );
    }
  }

  _GroupPalette _groupPalette(int index) {
    const palettes = <_GroupPalette>[
      _GroupPalette(
        icon: Icons.support_agent_rounded,
        color: Color(0xFF2457F5),
      ),
      _GroupPalette(
        icon: Icons.settings_suggest_rounded,
        color: Color(0xFF1273EA),
      ),
      _GroupPalette(
        icon: Icons.security_rounded,
        color: Color(0xFF20B46A),
      ),
      _GroupPalette(
        icon: Icons.inventory_2_outlined,
        color: Color(0xFFE58B00),
      ),
    ];

    return palettes[index % palettes.length];
  }

  String normalizeStatus(String input) {
    return input
        .trim()
        .toUpperCase()
        .replaceAll('Á', 'A')
        .replaceAll('É', 'E')
        .replaceAll('Í', 'I')
        .replaceAll('Ó', 'O')
        .replaceAll('Ú', 'U')
        .replaceAll(' ', '_');
  }

  String _roleLabelFromSlug(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'tecnico':
        return 'Tecnico';
      case 'admin':
        return 'Admin';
      case 'cliente':
      default:
        return 'Cliente';
    }
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  AuthUser _mapAuthUser(Map<String, dynamic> json) {
    return AuthUser(
      name: json['name']?.toString().trim().isNotEmpty == true
          ? json['name'].toString().trim()
          : 'Usuario',
      lastName: json['lastName']?.toString().trim().isNotEmpty == true
          ? json['lastName'].toString().trim()
          : null,
      email: json['email']?.toString().trim().toLowerCase() ?? '',
      password: json['password']?.toString() ?? '',
      role: _roleFromSlug(json['role']?.toString() ?? ''),
      photoUrl: json['photoUrl']?.toString().trim().isNotEmpty == true
          ? json['photoUrl'].toString().trim()
          : null,
      twoFactorEnabled: json['twoFactorEnabled'] == true,
    );
  }

  UserRole _roleFromSlug(String rawRole) {
    switch (rawRole.trim().toLowerCase()) {
      case 'tecnico':
        return UserRole.tecnico;
      case 'admin':
        return UserRole.admin;
      case 'cliente':
      default:
        return UserRole.cliente;
    }
  }
}

class _StatusPalette {
  const _StatusPalette({
    required this.foreground,
    required this.background,
    required this.accent,
  });

  final Color foreground;
  final Color background;
  final Color accent;
}

class _PriorityPalette {
  const _PriorityPalette({
    required this.foreground,
    required this.background,
  });

  final Color foreground;
  final Color background;
}

class _GroupPalette {
  const _GroupPalette({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;
}
// endregion
