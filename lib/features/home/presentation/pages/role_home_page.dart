// region Componentes Dashboard: imports
import 'package:flutter/material.dart';

import '../../../../core/models/auth_user.dart';
import '../../../../core/models/user_role.dart';
// endregion

// region Componentes Dashboard: contenedor principal por rol
class RoleHomePage extends StatelessWidget {
  const RoleHomePage({
    required this.user,
    super.key,
  });

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(user.role.headline),
        actions: <Widget>[
          IconButton(
            tooltip: 'Cerrar sesion',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildHeader(theme),
                const SizedBox(height: 24),
                _buildSummaryCards(),
                const SizedBox(height: 24),
                _buildActivityList(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// endregion

// region Componentes Dashboard: cabecera de usuario autenticado
extension on RoleHomePage {
  Widget _buildHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9E1EC)),
      ),
      child: Wrap(
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Hola, ${user.name}', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                '${user.email} · ${user.role.label}',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
          Chip(
            label: Text(user.role.label),
            avatar: const Icon(Icons.verified_user_outlined, size: 18),
          ),
        ],
      ),
    );
  }
}
// endregion

// region Componentes Dashboard: tarjetas de resumen por rol
extension on RoleHomePage {
  Widget _buildSummaryCards() {
    final items = switch (user.role) {
      UserRole.tecnico => const <({String title, String value, IconData icon})>[
          (
            title: 'Tickets asignados',
            value: '12',
            icon: Icons.build_circle_outlined,
          ),
          (
            title: 'SLA en riesgo',
            value: '2',
            icon: Icons.timer_outlined,
          ),
          (
            title: 'Resueltos hoy',
            value: '5',
            icon: Icons.task_alt_outlined,
          ),
        ],
      UserRole.admin => const <({String title, String value, IconData icon})>[
          (
            title: 'Usuarios activos',
            value: '148',
            icon: Icons.groups_2_outlined,
          ),
          (
            title: 'Tickets abiertos',
            value: '37',
            icon: Icons.confirmation_number_outlined,
          ),
          (
            title: 'Rendimiento SLA',
            value: '96%',
            icon: Icons.query_stats_outlined,
          ),
        ],
      UserRole.cliente => const <({String title, String value, IconData icon})>[
          (
            title: 'Solicitudes abiertas',
            value: '3',
            icon: Icons.support_agent_outlined,
          ),
          (
            title: 'Ultima respuesta',
            value: '1h',
            icon: Icons.mark_email_read_outlined,
          ),
          (
            title: 'Prioridad actual',
            value: 'Media',
            icon: Icons.flag_outlined,
          ),
        ],
    };

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: items
          .map(
            (item) => SizedBox(
              width: 280,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(item.icon),
                      const SizedBox(height: 16),
                      Text(item.title),
                      const SizedBox(height: 8),
                      Text(
                        item.value,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF152033),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
// endregion

// region Componentes Dashboard: listado de actividad simulada
extension on RoleHomePage {
  Widget _buildActivityList(ThemeData theme) {
    final rows = switch (user.role) {
      UserRole.tecnico => const <String>[
          'Ticket #4821 pendiente de diagnostico.',
          'Ticket #4814 actualizado con nueva nota tecnica.',
          'Intervencion presencial programada para mañana.',
        ],
      UserRole.admin => const <String>[
          'Nuevo usuario cliente registrado desde la app.',
          'Dos tickets han cambiado a prioridad alta.',
          'Exportacion diaria de actividad completada.',
        ],
      UserRole.cliente => const <String>[
          'Solicitud #731 en revision por el equipo tecnico.',
          'Se ha recibido una respuesta en tu ticket #728.',
          'Tu ultimo ticket quedo resuelto y cerrado.',
        ],
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Actividad reciente', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(Icons.circle, size: 10),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(row)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// endregion
