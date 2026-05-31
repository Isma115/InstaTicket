// #region Dashboard | Funcionalidad | Repositorio mock para metricas y tickets
import 'package:flutter/material.dart';

import '../../../core/models/auth_user.dart';
import '../../../core/models/user_role.dart';
import '../domain/models/dashboard_models.dart';

class MockHomeRepository {
  MockHomeRepository._();

  static final MockHomeRepository instance = MockHomeRepository._();

  DashboardViewData buildDashboard(AuthUser user) {
    return DashboardViewData(
      metrics: _metricsByRole(user.role),
      recentTickets: _ticketsByRole(user.role),
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
      supportGroups: _groupsByRole(user.role),
      floatingActionLabel:
          user.role == UserRole.cliente ? 'Nueva incidencia' : 'Nuevo ticket',
    );
  }

  List<DashboardMetric> _metricsByRole(UserRole role) {
    switch (role) {
      case UserRole.tecnico:
        return const <DashboardMetric>[
          DashboardMetric(
            title: 'Abiertos',
            value: '28',
            icon: Icons.folder_outlined,
            iconColor: Color(0xFF1F6BFF),
            iconBackgroundColor: Color(0xFFEDF4FF),
          ),
          DashboardMetric(
            title: 'En progreso',
            value: '15',
            icon: Icons.access_time_outlined,
            iconColor: Color(0xFFFFAF1A),
            iconBackgroundColor: Color(0xFFFFF7E7),
          ),
          DashboardMetric(
            title: 'Resueltos',
            value: '56',
            icon: Icons.check_outlined,
            iconColor: Color(0xFF20B46A),
            iconBackgroundColor: Color(0xFFEEFBF3),
          ),
          DashboardMetric(
            title: 'Total tickets',
            value: '99',
            icon: Icons.bar_chart_outlined,
            iconColor: Color(0xFF6B5AF3),
            iconBackgroundColor: Color(0xFFF3F0FF),
          ),
        ];
      case UserRole.admin:
        return const <DashboardMetric>[
          DashboardMetric(
            title: 'Abiertos',
            value: '41',
            icon: Icons.folder_outlined,
            iconColor: Color(0xFF1F6BFF),
            iconBackgroundColor: Color(0xFFEDF4FF),
          ),
          DashboardMetric(
            title: 'En progreso',
            value: '19',
            icon: Icons.access_time_outlined,
            iconColor: Color(0xFFFFAF1A),
            iconBackgroundColor: Color(0xFFFFF7E7),
          ),
          DashboardMetric(
            title: 'Resueltos',
            value: '83',
            icon: Icons.check_outlined,
            iconColor: Color(0xFF20B46A),
            iconBackgroundColor: Color(0xFFEEFBF3),
          ),
          DashboardMetric(
            title: 'Total tickets',
            value: '143',
            icon: Icons.bar_chart_outlined,
            iconColor: Color(0xFF6B5AF3),
            iconBackgroundColor: Color(0xFFF3F0FF),
          ),
        ];
      case UserRole.cliente:
        return const <DashboardMetric>[
          DashboardMetric(
            title: 'Abiertos',
            value: '3',
            icon: Icons.folder_outlined,
            iconColor: Color(0xFF1F6BFF),
            iconBackgroundColor: Color(0xFFEDF4FF),
          ),
          DashboardMetric(
            title: 'En progreso',
            value: '1',
            icon: Icons.access_time_outlined,
            iconColor: Color(0xFFFFAF1A),
            iconBackgroundColor: Color(0xFFFFF7E7),
          ),
          DashboardMetric(
            title: 'Resueltos',
            value: '9',
            icon: Icons.check_outlined,
            iconColor: Color(0xFF20B46A),
            iconBackgroundColor: Color(0xFFEEFBF3),
          ),
          DashboardMetric(
            title: 'Total tickets',
            value: '13',
            icon: Icons.bar_chart_outlined,
            iconColor: Color(0xFF6B5AF3),
            iconBackgroundColor: Color(0xFFF3F0FF),
          ),
        ];
    }
  }

  List<DashboardTicket> _ticketsByRole(UserRole role) {
    switch (role) {
      case UserRole.tecnico:
        return const <DashboardTicket>[
          DashboardTicket(
            id: 'inc-1048',
            title: 'Error al iniciar sesión en el portal',
            status: 'Abierto',
            timeLabel: 'Hoy, 09:10',
            reporter: 'Ana Perez',
            priorityLabel: 'Alta',
            statusColor: Color(0xFF1F6BFF),
            statusBackgroundColor: Color(0xFFEEF5FF),
            priorityColor: Color(0xFFC0392B),
            priorityBackgroundColor: Color(0xFFFFE9E6),
            accentColor: Color(0xFF2F80ED),
            chatMessages: <DashboardTicketMessage>[
              DashboardTicketMessage(
                id: 'inc-1048-1',
                authorName: 'Ana Perez',
                authorRoleLabel: 'Cliente',
                body:
                    'El portal devuelve credenciales invalidas aunque la clave es correcta.',
                timeLabel: 'Hoy, 09:12',
              ),
              DashboardTicketMessage(
                id: 'inc-1048-2',
                authorName: 'Equipo Soporte',
                authorRoleLabel: 'Tecnico',
                body:
                    'Estamos revisando logs de autenticacion y bloqueo de sesiones.',
                timeLabel: 'Hoy, 09:18',
              ),
              DashboardTicketMessage(
                id: 'inc-1048-3',
                authorName: 'Ana Perez',
                authorRoleLabel: 'Cliente',
                body: 'Confirmo que tambien falla desde otro navegador.',
                timeLabel: 'Hoy, 09:24',
                parentMessageId: 'inc-1048-2',
              ),
            ],
          ),
          DashboardTicket(
            id: 'inc-1047',
            title: 'Actualizacion de software detenida',
            status: 'En progreso',
            timeLabel: 'Hoy, 08:45',
            reporter: 'Juan Garcia',
            priorityLabel: 'Media',
            statusColor: Color(0xFFFFAF1A),
            statusBackgroundColor: Color(0xFFFFF7E8),
            priorityColor: Color(0xFF9B6B00),
            priorityBackgroundColor: Color(0xFFFFF3D6),
            accentColor: Color(0xFF1273EA),
            chatMessages: <DashboardTicketMessage>[
              DashboardTicketMessage(
                id: 'inc-1047-1',
                authorName: 'Juan Garcia',
                authorRoleLabel: 'Cliente',
                body: 'La barra de actualizacion se queda en 73% y no avanza.',
                timeLabel: 'Hoy, 08:47',
              ),
              DashboardTicketMessage(
                id: 'inc-1047-2',
                authorName: 'Lucia Torres',
                authorRoleLabel: 'Tecnico',
                body:
                    'He relanzado el despliegue y estoy validando espacio en disco.',
                timeLabel: 'Hoy, 09:01',
              ),
            ],
          ),
          DashboardTicket(
            id: 'inc-1046',
            title: 'Solicitud de nuevo periférico',
            status: 'Resuelto',
            timeLabel: 'Ayer, 17:20',
            reporter: 'Laura Sanchez',
            priorityLabel: 'Baja',
            statusColor: Color(0xFF20B46A),
            statusBackgroundColor: Color(0xFFEEFBF3),
            priorityColor: Color(0xFF2D6A4F),
            priorityBackgroundColor: Color(0xFFE6F6EC),
            accentColor: Color(0xFF20B46A),
            chatMessages: <DashboardTicketMessage>[
              DashboardTicketMessage(
                id: 'inc-1046-1',
                authorName: 'Laura Sanchez',
                authorRoleLabel: 'Cliente',
                body:
                    'Necesito un teclado adicional para el puesto de recepcion.',
                timeLabel: 'Ayer, 15:40',
              ),
              DashboardTicketMessage(
                id: 'inc-1046-2',
                authorName: 'Mesa de ayuda',
                authorRoleLabel: 'Tecnico',
                body: 'Pedido registrado y entregado esta misma tarde.',
                timeLabel: 'Ayer, 17:20',
              ),
            ],
          ),
        ];
      case UserRole.admin:
        return const <DashboardTicket>[
          DashboardTicket(
            id: 'adm-209',
            title: 'Escalado SLA sin responsable asignado',
            status: 'Abierto',
            timeLabel: 'Hoy, 10:05',
            reporter: 'Sistema',
            priorityLabel: 'Alta',
            statusColor: Color(0xFF1F6BFF),
            statusBackgroundColor: Color(0xFFEEF5FF),
            priorityColor: Color(0xFFC0392B),
            priorityBackgroundColor: Color(0xFFFFE9E6),
            accentColor: Color(0xFFEB5757),
            chatMessages: <DashboardTicketMessage>[
              DashboardTicketMessage(
                id: 'adm-209-1',
                authorName: 'Sistema',
                authorRoleLabel: 'Monitor',
                body: 'Se ha alcanzado el limite SLA sin tecnico asignado.',
                timeLabel: 'Hoy, 10:05',
              ),
              DashboardTicketMessage(
                id: 'adm-209-2',
                authorName: 'Marta Ruiz',
                authorRoleLabel: 'Admin',
                body:
                    'Reviso disponibilidad del equipo de guardia para reasignar.',
                timeLabel: 'Hoy, 10:11',
              ),
            ],
          ),
          DashboardTicket(
            id: 'adm-208',
            title: 'Revisión de permisos por grupo',
            status: 'En progreso',
            timeLabel: 'Hoy, 08:15',
            reporter: 'Marta Ruiz',
            priorityLabel: 'Media',
            statusColor: Color(0xFFFFAF1A),
            statusBackgroundColor: Color(0xFFFFF7E8),
            priorityColor: Color(0xFF9B6B00),
            priorityBackgroundColor: Color(0xFFFFF3D6),
            accentColor: Color(0xFF1273EA),
            chatMessages: <DashboardTicketMessage>[
              DashboardTicketMessage(
                id: 'adm-208-1',
                authorName: 'Marta Ruiz',
                authorRoleLabel: 'Admin',
                body: 'Hay que validar accesos heredados del grupo comercial.',
                timeLabel: 'Hoy, 08:20',
              ),
              DashboardTicketMessage(
                id: 'adm-208-2',
                authorName: 'Daniel Soto',
                authorRoleLabel: 'Tecnico',
                body: 'He detectado dos usuarios con privilegios redundantes.',
                timeLabel: 'Hoy, 08:41',
                parentMessageId: 'adm-208-1',
              ),
            ],
          ),
          DashboardTicket(
            id: 'adm-207',
            title: 'Consolidado diario de incidencias generado',
            status: 'Resuelto',
            timeLabel: 'Ayer, 18:00',
            reporter: 'Backoffice',
            priorityLabel: 'Baja',
            statusColor: Color(0xFF20B46A),
            statusBackgroundColor: Color(0xFFEEFBF3),
            priorityColor: Color(0xFF2D6A4F),
            priorityBackgroundColor: Color(0xFFE6F6EC),
            accentColor: Color(0xFF20B46A),
            chatMessages: <DashboardTicketMessage>[
              DashboardTicketMessage(
                id: 'adm-207-1',
                authorName: 'Backoffice',
                authorRoleLabel: 'Sistema',
                body: 'Informe diario exportado y publicado en el panel.',
                timeLabel: 'Ayer, 18:00',
              ),
            ],
          ),
        ];
      case UserRole.cliente:
        return const <DashboardTicket>[
          DashboardTicket(
            id: 'cli-731',
            title: 'No puedo adjuntar una factura al ticket',
            status: 'Abierto',
            timeLabel: 'Hoy, 09:30',
            reporter: 'Carlos Romero',
            priorityLabel: 'Alta',
            statusColor: Color(0xFF1F6BFF),
            statusBackgroundColor: Color(0xFFEEF5FF),
            priorityColor: Color(0xFFC0392B),
            priorityBackgroundColor: Color(0xFFFFE9E6),
            accentColor: Color(0xFFEB5757),
            chatMessages: <DashboardTicketMessage>[
              DashboardTicketMessage(
                id: 'cli-731-1',
                authorName: 'Carlos Romero',
                authorRoleLabel: 'Cliente',
                body:
                    'Al adjuntar la factura el formulario se reinicia y pierde el archivo.',
                timeLabel: 'Hoy, 09:31',
              ),
              DashboardTicketMessage(
                id: 'cli-731-2',
                authorName: 'Soporte tecnico',
                authorRoleLabel: 'Tecnico',
                body:
                    'Necesito saber si ocurre con PDF o tambien con imagenes.',
                timeLabel: 'Hoy, 09:37',
              ),
            ],
          ),
          DashboardTicket(
            id: 'cli-728',
            title: 'Error al descargar el informe mensual',
            status: 'En progreso',
            timeLabel: 'Hoy, 08:45',
            reporter: 'Soporte tecnico',
            priorityLabel: 'Media',
            statusColor: Color(0xFFFFAF1A),
            statusBackgroundColor: Color(0xFFFFF7E8),
            priorityColor: Color(0xFF9B6B00),
            priorityBackgroundColor: Color(0xFFFFF3D6),
            accentColor: Color(0xFF1273EA),
            chatMessages: <DashboardTicketMessage>[
              DashboardTicketMessage(
                id: 'cli-728-1',
                authorName: 'Soporte tecnico',
                authorRoleLabel: 'Tecnico',
                body: 'Hemos reproducido el error al generar el PDF de abril.',
                timeLabel: 'Hoy, 08:46',
              ),
              DashboardTicketMessage(
                id: 'cli-728-2',
                authorName: 'Carlos Romero',
                authorRoleLabel: 'Cliente',
                body:
                    'Perfecto, me sirve una exportacion provisional en Excel.',
                timeLabel: 'Hoy, 09:02',
                parentMessageId: 'cli-728-1',
              ),
            ],
          ),
          DashboardTicket(
            id: 'cli-720',
            title: 'Actualizacion de acceso completada',
            status: 'Resuelto',
            timeLabel: 'Ayer, 16:10',
            reporter: 'Laura Sanchez',
            priorityLabel: 'Baja',
            statusColor: Color(0xFF20B46A),
            statusBackgroundColor: Color(0xFFEEFBF3),
            priorityColor: Color(0xFF2D6A4F),
            priorityBackgroundColor: Color(0xFFE6F6EC),
            accentColor: Color(0xFF20B46A),
            chatMessages: <DashboardTicketMessage>[
              DashboardTicketMessage(
                id: 'cli-720-1',
                authorName: 'Laura Sanchez',
                authorRoleLabel: 'Tecnico',
                body: 'El nuevo acceso ya esta activo y probado correctamente.',
                timeLabel: 'Ayer, 16:10',
              ),
            ],
          ),
        ];
    }
  }

  List<DashboardSupportGroup> _groupsByRole(UserRole role) {
    switch (role) {
      case UserRole.tecnico:
        return const <DashboardSupportGroup>[
          DashboardSupportGroup(
            title: 'Mesa de ayuda',
            subtitle: 'Incidencias de primer nivel y acceso',
            membersLabel: '12 tecnicos activos',
            icon: Icons.support_agent_rounded,
            accentColor: Color(0xFF2D9CDB),
          ),
          DashboardSupportGroup(
            title: 'Sistemas',
            subtitle: 'Servidores, redes y equipos internos',
            membersLabel: '8 especialistas',
            icon: Icons.dns_rounded,
            accentColor: Color(0xFF20B46A),
          ),
        ];
      case UserRole.admin:
        return const <DashboardSupportGroup>[
          DashboardSupportGroup(
            title: 'Operaciones',
            subtitle: 'Seguimiento de SLA y coordinacion',
            membersLabel: '5 responsables',
            icon: Icons.query_stats_rounded,
            accentColor: Color(0xFF2457F5),
          ),
          DashboardSupportGroup(
            title: 'Permisos',
            subtitle: 'Accesos, auditorias y compliance',
            membersLabel: '4 administradores',
            icon: Icons.admin_panel_settings_rounded,
            accentColor: Color(0xFFFFAF1A),
          ),
        ];
      case UserRole.cliente:
        return const <DashboardSupportGroup>[
          DashboardSupportGroup(
            title: 'Atencion general',
            subtitle: 'Consultas abiertas y seguimiento diario',
            membersLabel: 'Disponible de 08:00 a 18:00',
            icon: Icons.headset_mic_rounded,
            accentColor: Color(0xFF2457F5),
          ),
          DashboardSupportGroup(
            title: 'Facturacion',
            subtitle: 'Documentacion y validacion de cargos',
            membersLabel: 'Respuesta media: 2 h',
            icon: Icons.receipt_long_rounded,
            accentColor: Color(0xFF20B46A),
          ),
        ];
    }
  }
}
// #endregion
