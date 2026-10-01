import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/shared/providers/community_provider.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';

enum _AdminArea {
  resumen('Resumen', Icons.dashboard_outlined),
  comunidad('Comunidad', Icons.apartment_outlined),
  atencion('Atención', Icons.support_agent_outlined),
  agenda('Espacios y agenda', Icons.calendar_month_outlined),
  comunicacion('Comunicación', Icons.campaign_outlined),
  finanzas('Finanzas', Icons.account_balance_outlined),
  accesos('Accesos', Icons.qr_code_scanner_outlined),
  configuracion('Configuración', Icons.settings_outlined);

  const _AdminArea(this.label, this.icon);
  final String label;
  final IconData icon;
}

class WebAdminScreen extends ConsumerStatefulWidget {
  const WebAdminScreen({super.key});

  @override
  ConsumerState<WebAdminScreen> createState() => _WebAdminScreenState();
}

class _WebAdminScreenState extends ConsumerState<WebAdminScreen> {
  late _AdminArea _area;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    final requestedArea = Uri.base.queryParameters['area'];
    _area = _AdminArea.values.firstWhere(
      (area) => area.name == requestedArea,
      orElse: () => _AdminArea.resumen,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final community = ref.watch(currentCommunityProvider).valueOrNull;
    final user = ref.watch(currentUserProvider).valueOrNull;
    final communityName = community?.name ?? 'Mirador de los Cedros';
    final desktop = MediaQuery.sizeOf(context).width >= 940;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF4F7F6),
      drawer: desktop
          ? null
          : Drawer(
              child: _Sidebar(
                selected: _area,
                onSelect: _selectArea,
                communityName: communityName,
              ),
            ),
      body: SafeArea(
        child: Row(
          children: [
            if (desktop)
              SizedBox(
                width: 260,
                child: _Sidebar(
                  selected: _area,
                  onSelect: _selectArea,
                  communityName: communityName,
                ),
              ),
            Expanded(
              child: Column(
                children: [
                  _TopBar(
                    desktop: desktop,
                    communityName: communityName,
                    displayName: user?.displayName ?? 'Administración',
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(desktop ? 28 : 16),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1440),
                          child: SizedBox(
                            width: double.infinity,
                            child: _buildArea(communityName, community?.id),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectArea(_AdminArea value) {
    setState(() {
      _area = value;
      _query = '';
      _searchController.clear();
    });
    context.go('/admin-web?area=${value.name}');
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
    }
  }

  Widget _buildArea(String communityName, String? communityId) =>
      switch (_area) {
        _AdminArea.resumen => _Overview(
          communityName: communityName,
          onNavigate: _selectArea,
        ),
        _AdminArea.comunidad => _RecordsPage(
          title: 'Personas y viviendas',
          description: 'Residentes, viviendas y solicitudes de acceso.',
          actionLabel: 'Gestionar residentes',
          onAction: () => context.push('/premium/pending'),
          columns: const ['Persona', 'Vivienda', 'Estado', 'Acción'],
          rows: _filter(const [
            ['Valentina Rojas', 'Torre 2 / 301', 'Por revisar', 'Revisar'],
            ['Carlos Méndez', 'Torre 1 / 504', 'Verificado', 'Abrir'],
            ['Ana Torres', 'Torre 3 / 102', 'Verificado', 'Abrir'],
            ['Mateo Gómez', 'Torre 2 / 606', 'Pendiente', 'Revisar'],
          ]),
        ),
        _AdminArea.atencion => _RecordsPage(
          title: 'Solicitudes de la comunidad',
          description: 'PQRS, multas, descargos y conversaciones de atención.',
          actionLabel: 'Registrar solicitud',
          onAction: () => context.push('/premium/pqrs/create'),
          columns: const ['Radicado', 'Asunto', 'Estado', 'Responsable'],
          rows: _filter(const [
            ['PQ-0028', 'Filtración en pasillo', 'En gestión', 'Laura Gómez'],
            ['PQ-0023', 'Uso del salón', 'Por responder', 'Administración'],
            ['M-0012', 'Descargo por ruido', 'En revisión', 'Comité'],
            ['PQ-0020', 'Ruido nocturno', 'En espera', 'Convivencia'],
          ]),
        ),
        _AdminArea.agenda => _AgendaPage(
          query: _query,
          onAction: () => context.push('/premium/amenities'),
        ),
        _AdminArea.comunicacion => _CommunicationPage(
          query: _query,
          onAction: () => context.push('/premium/circulars/create'),
        ),
        _AdminArea.finanzas => _FinancePage(query: _query),
        _AdminArea.accesos => _AccessPage(
          query: _query,
          onAction: () => context.push('/premium/access-management'),
        ),
        _AdminArea.configuracion => _SettingsPage(
          communityId: communityId,
          onOpenSettings: () => context.push('/premium/settings'),
        ),
      };

  List<List<String>> _filter(List<List<String>> rows) {
    if (_query.trim().isEmpty) return rows;
    final query = _query.toLowerCase();
    return rows
        .where((row) => row.any((cell) => cell.toLowerCase().contains(query)))
        .toList();
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.selected,
    required this.onSelect,
    required this.communityName,
  });

  final _AdminArea selected;
  final ValueChanged<_AdminArea> onSelect;
  final String communityName;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF07594F),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.apartment_rounded, color: Colors.white, size: 30),
                  SizedBox(width: 10),
                  Text(
                    'vecindario',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 40, top: 2),
                child: Text(
                  'ADMINISTRACIÓN',
                  style: TextStyle(
                    color: Color(0xFFC4DC72),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              for (final area in _AdminArea.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Material(
                    color: selected == area
                        ? const Color(0xFFE5F1ED)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      dense: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: Icon(
                        area.icon,
                        color: selected == area
                            ? const Color(0xFF07594F)
                            : Colors.white70,
                      ),
                      title: Text(
                        area.label,
                        style: TextStyle(
                          color: selected == area
                              ? const Color(0xFF07594F)
                              : Colors.white,
                          fontWeight: selected == area
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      onTap: () => onSelect(area),
                    ),
                  ),
                ),
              const Spacer(),
              const Text(
                'COMUNIDAD ACTIVA',
                style: TextStyle(
                  color: Color(0xFFC4DC72),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                communityName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.desktop,
    required this.communityName,
    required this.displayName,
    required this.controller,
    required this.onChanged,
  });

  final bool desktop;
  final String communityName;
  final String displayName;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: EdgeInsets.symmetric(horizontal: desktop ? 28 : 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE1E8E5))),
      ),
      child: Row(
        children: [
          if (!desktop)
            Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu),
                tooltip: 'Abrir menú',
              ),
            ),
          Expanded(
            child: Text(
              communityName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
          if (desktop) ...[
            const _EnvironmentBadge(),
            const SizedBox(width: 14),
          ],
          if (desktop)
            SizedBox(
              width: 330,
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: 'Buscar en este espacio',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF2F5F4),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  isDense: true,
                ),
              ),
            ),
          const SizedBox(width: 14),
          CircleAvatar(
            backgroundColor: const Color(0xFFE0F0EA),
            child: Text(
              displayName.isEmpty
                  ? 'AD'
                  : displayName.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF07594F),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (desktop) ...[
            const SizedBox(width: 8),
            Text(
              displayName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}

class _EnvironmentBadge extends StatelessWidget {
  const _EnvironmentBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1D8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'DATOS DEMO',
        style: TextStyle(
          color: Color(0xFF8A5700),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: .5,
        ),
      ),
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({required this.communityName, required this.onNavigate});
  final String communityName;
  final ValueChanged<_AdminArea> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageHeading(
          eyebrow: 'W01 / RESUMEN',
          title: 'Hoy en tu comunidad',
          subtitle: communityName,
          actionLabel: 'Crear circular',
          onAction: () => onNavigate(_AdminArea.comunicacion),
        ),
        const SizedBox(height: 22),
        const _MetricGrid(
          metrics: [
            ('Accesos por revisar', '3'),
            ('Solicitudes abiertas', '8'),
            ('Reservas de hoy', '5'),
            ('Recaudo de septiembre', '85 %'),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 1080;
            final attention = _Panel(
              title: 'Necesita tu atención',
              child: Column(
                children: [
                  _TaskRow(
                    title: 'Alta de Valentina · Torre 2 / 301',
                    subtitle: 'Revisar identidad y vínculo con vivienda',
                    action: 'Revisar',
                    onTap: () => onNavigate(_AdminArea.comunidad),
                  ),
                  _TaskRow(
                    title: 'PQ-0028 · Filtración en pasillo',
                    subtitle: 'Mantenimiento · Actualizada hace 2 h',
                    action: 'Atender',
                    onTap: () => onNavigate(_AdminArea.atencion),
                  ),
                  _TaskRow(
                    title: '3 soportes de pago por verificar',
                    subtitle: 'No están aplicados al saldo',
                    action: 'Revisar',
                    onTap: () => onNavigate(_AdminArea.finanzas),
                  ),
                ],
              ),
            );
            const agenda = _Panel(
              title: 'Agenda del conjunto',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AgendaItem('2:00 p. m. · Zona BBQ', 'Reserva R-0086'),
                  _AgendaItem('3:00 p. m. · Inspección', 'PQ-0028'),
                  _AgendaItem('Mañana · Ascensor Torre 2', 'Mantenimiento'),
                ],
              ),
            );
            if (stacked) {
              return Column(
                children: [attention, const SizedBox(height: 14), agenda],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: attention),
                const SizedBox(width: 14),
                const Expanded(flex: 2, child: agenda),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _RecordsPage extends StatelessWidget {
  const _RecordsPage({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.columns,
    required this.rows,
    this.onAction,
  });
  final String title;
  final String description;
  final String actionLabel;
  final List<String> columns;
  final List<List<String>> rows;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageHeading(
          eyebrow: 'OPERACIÓN',
          title: title,
          subtitle: description,
          actionLabel: actionLabel,
          onAction: onAction,
        ),
        const SizedBox(height: 22),
        _DataTableCard(columns: columns, rows: rows),
      ],
    );
  }
}

class _AgendaPage extends StatelessWidget {
  const _AgendaPage({required this.query, required this.onAction});
  final String query;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    const events = [
      ['Hoy · 2:00 p. m.', 'Zona BBQ', 'Reserva R-0086', 'Confirmada'],
      [
        'Hoy · 3:00 p. m.',
        'Cita administración',
        'Valentina Rojas',
        'Confirmada',
      ],
      ['Mañana · 9:00 a. m.', 'Salón social', 'Reserva R-0089', 'Pendiente'],
      [
        'Viernes · 4:30 p. m.',
        'Cita administración',
        'Carlos Méndez',
        'Solicitada',
      ],
    ];
    final rows = query.isEmpty
        ? events
        : events
              .where(
                (row) =>
                    row.join(' ').toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    return _RecordsPage(
      title: 'Espacios y agenda',
      description: 'Reservas de zonas comunes y citas con administración.',
      actionLabel: 'Configurar disponibilidad',
      onAction: onAction,
      columns: const ['Fecha', 'Tipo', 'Referencia', 'Estado'],
      rows: rows,
    );
  }
}

class _CommunicationPage extends StatelessWidget {
  const _CommunicationPage({required this.query, required this.onAction});
  final String query;
  final VoidCallback onAction;
  @override
  Widget build(BuildContext context) {
    const all = [
      ['C-0041', 'Mantenimiento del ascensor', '25 sep', '82 % leído'],
      ['C-0040', 'Cierre temporal de piscina', '22 sep', '91 % leído'],
      ['A-0018', 'Asamblea extraordinaria', '18 sep', '76 % leído'],
      ['DOC-12', 'Manual de convivencia v3', '10 sep', 'Publicado'],
    ];
    final rows = query.isEmpty
        ? all
        : all
              .where(
                (row) =>
                    row.join(' ').toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    return _RecordsPage(
      title: 'Comunicación oficial',
      description: 'Circulares, biblioteca, versiones y asambleas.',
      actionLabel: 'Nueva circular',
      onAction: onAction,
      columns: const ['ID', 'Publicación', 'Fecha', 'Alcance'],
      rows: rows,
    );
  }
}

class _FinancePage extends StatelessWidget {
  const _FinancePage({required this.query});
  final String query;
  @override
  Widget build(BuildContext context) {
    const all = [
      ['P-0034', 'Soporte Torre 2 / 301', r'$480.000', 'Por verificar'],
      ['MOV-918', 'Mantenimiento ascensor', r'-$3.200.000', 'Publicado'],
      ['MOV-917', 'Cuotas de administración', r'$18.640.000', 'Conciliado'],
    ];
    final rows = query.trim().isEmpty
        ? all
        : all
              .where(
                (row) => row
                    .join(' ')
                    .toLowerCase()
                    .contains(query.trim().toLowerCase()),
              )
              .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageHeading(
          eyebrow: 'W13 / FINANZAS',
          title: 'Finanzas · septiembre 2026',
          subtitle: 'Cartera, movimientos, soportes y presupuesto publicado.',
          actionLabel: 'Registrar movimiento',
          onAction: () => context.push('/premium/finances/create'),
        ),
        const SizedBox(height: 22),
        const _MetricGrid(
          metrics: [
            ('Presupuesto anual', r'$428 M'),
            ('Ejecutado', '67 %'),
            ('Recaudo del mes', r'$54,8 M'),
            ('Cartera vencida', r'$9,2 M'),
          ],
        ),
        const SizedBox(height: 18),
        _DataTableCard(
          columns: const ['Referencia', 'Concepto', 'Valor', 'Estado'],
          rows: rows,
        ),
      ],
    );
  }
}

class _AccessPage extends StatelessWidget {
  const _AccessPage({required this.query, required this.onAction});
  final String query;
  final VoidCallback onAction;
  @override
  Widget build(BuildContext context) {
    const all = [
      ['14:22', 'Piscina', 'Valentina Rojas', 'Permitido'],
      ['14:18', 'Portería', 'Visitante · Andrés P.', 'Permitido'],
      ['13:55', 'Piscina', 'QR vencido', 'Rechazado'],
      ['13:42', 'Gimnasio', 'Carlos Méndez', 'Permitido'],
    ];
    final rows = query.isEmpty
        ? all
        : all
              .where(
                (row) =>
                    row.join(' ').toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    return _RecordsPage(
      title: 'Accesos y operarios',
      description:
          'Operarios autorizados, validaciones QR e historial de ingresos.',
      actionLabel: 'Gestionar operarios',
      onAction: onAction,
      columns: const ['Hora', 'Punto', 'Persona', 'Resultado'],
      rows: rows,
    );
  }
}

class _SettingsPage extends ConsumerStatefulWidget {
  const _SettingsPage({
    required this.communityId,
    required this.onOpenSettings,
  });
  final String? communityId;
  final VoidCallback onOpenSettings;
  @override
  ConsumerState<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<_SettingsPage> {
  bool notifications = true;
  bool qrAccess = true;
  bool appointments = true;
  bool saving = false;

  Future<void> _saveModules() async {
    final id = widget.communityId;
    if (id == null || saving) return;
    setState(() => saving = true);
    try {
      await ref.read(communityRepositoryProvider).updateCommunity(id, {
        'adminModules': {
          'notifications': notifications,
          'qrAccess': qrAccess,
          'appointments': appointments,
        },
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Configuración guardada')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No se pudo guardar: $error')));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageHeading(
          eyebrow: 'CONFIGURACIÓN',
          title: 'Configuración del conjunto',
          subtitle: 'Capacidades, equipo, permisos y plan de la comunidad.',
          actionLabel: 'Editar datos del conjunto',
          onAction: widget.onOpenSettings,
        ),
        const SizedBox(height: 22),
        _Panel(
          title: 'Módulos habilitados',
          child: Column(
            children: [
              SwitchListTile(
                value: notifications,
                onChanged: (v) => setState(() => notifications = v),
                title: const Text('Comunicaciones y notificaciones'),
              ),
              SwitchListTile(
                value: qrAccess,
                onChanged: (v) => setState(() => qrAccess = v),
                title: const Text('Acceso mediante QR'),
              ),
              SwitchListTile(
                value: appointments,
                onChanged: (v) => setState(() => appointments = v),
                title: const Text('Agenda de citas'),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: widget.communityId == null || saving
                      ? null
                      : _saveModules,
                  icon: saving
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(saving ? 'Guardando…' : 'Guardar cambios'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const _DataTableCard(
          columns: ['Miembro', 'Rol', 'Alcance', 'Estado'],
          rows: [
            ['Laura Gómez', 'Administradora', 'Todos los módulos', 'Activo'],
            ['Jairo Rodríguez', 'Operario', 'Accesos', 'Activo'],
            ['Marcela Díaz', 'Contabilidad', 'Finanzas', 'Invitación enviada'],
          ],
        ),
      ],
    );
  }
}

class _PageHeading extends StatelessWidget {
  const _PageHeading({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });
  final String eyebrow;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 14,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: const TextStyle(
                  color: Color(0xFF08786A),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF18332F),
                  fontSize: 30,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Text(subtitle, style: const TextStyle(color: Color(0xFF60736F))),
            ],
          ),
        ),
        if (actionLabel != null)
          FilledButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add, size: 18),
            label: Text(actionLabel!),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF08786A),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF60736F),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF08786A),
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.metrics});

  final List<(String, String)> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1100
            ? 4
            : constraints.maxWidth >= 620
            ? 2
            : 1;
        const gap = 14.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: width,
                child: _Metric(label: metric.$1, value: metric.$2),
              ),
          ],
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF18332F),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final String action;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE7EEEB))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF71827E), fontSize: 13),
          ),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onTap, child: Text(action)),
        ],
      ),
    );
  }
}

class _AgendaItem extends StatelessWidget {
  const _AgendaItem(this.title, this.subtitle);
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF71827E), fontSize: 13),
        ),
      ],
    ),
  );
}

class _DataTableCard extends StatelessWidget {
  const _DataTableCard({required this.columns, required this.rows});
  final List<String> columns;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const _Panel(
        title: 'Sin resultados',
        child: Text('No encontramos registros con esa búsqueda.'),
      );
    }
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columnSpacing: 36,
              horizontalMargin: 22,
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF2F6F4)),
              columns: columns
                  .map(
                    (value) => DataColumn(
                      label: Text(
                        value,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  )
                  .toList(),
              rows: rows
                  .map(
                    (row) => DataRow(
                      cells: row.map((cell) {
                        final isStatus = {
                          'Por revisar',
                          'Pendiente',
                          'En gestión',
                          'En revisión',
                          'Rechazado',
                          'Solicitada',
                          'Por verificar',
                        }.contains(cell);
                        return DataCell(
                          isStatus
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF1D8),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    cell,
                                    style: const TextStyle(
                                      color: Color(0xFF8A5700),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                              : Text(cell),
                        );
                      }).toList(),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
  color: Colors.white,
  border: Border.all(color: const Color(0xFFDDE6E2)),
  borderRadius: BorderRadius.circular(16),
  boxShadow: const [
    BoxShadow(color: Color(0x0A000000), blurRadius: 14, offset: Offset(0, 4)),
  ],
);
