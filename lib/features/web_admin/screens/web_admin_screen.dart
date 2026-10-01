import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/shared/providers/community_provider.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';

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
  _AdminArea _area = _AdminArea.resumen;
  final _searchController = TextEditingController();
  String _query = '';

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
                    child: SelectionArea(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(desktop ? 28 : 16),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1440),
                          child: _buildArea(communityName),
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
    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildArea(String communityName) => switch (_area) {
    _AdminArea.resumen => _Overview(
      communityName: communityName,
      onNavigate: _selectArea,
    ),
    _AdminArea.comunidad => _RecordsPage(
      title: 'Personas y viviendas',
      description: 'Residentes, viviendas y solicitudes de acceso.',
      actionLabel: 'Invitar residente',
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
      columns: const ['Radicado', 'Asunto', 'Estado', 'Responsable'],
      rows: _filter(const [
        ['PQ-0028', 'Filtración en pasillo', 'En gestión', 'Laura Gómez'],
        ['PQ-0023', 'Uso del salón', 'Por responder', 'Administración'],
        ['M-0012', 'Descargo por ruido', 'En revisión', 'Comité'],
        ['PQ-0020', 'Ruido nocturno', 'En espera', 'Convivencia'],
      ]),
    ),
    _AdminArea.agenda => _AgendaPage(query: _query),
    _AdminArea.comunicacion => _CommunicationPage(query: _query),
    _AdminArea.finanzas => _FinancePage(query: _query),
    _AdminArea.accesos => _AccessPage(query: _query),
    _AdminArea.configuracion => const _SettingsPage(),
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
        const Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _Metric(label: 'Accesos por revisar', value: '3'),
            _Metric(label: 'Solicitudes abiertas', value: '8'),
            _Metric(label: 'Reservas de hoy', value: '5'),
            _Metric(label: 'Recaudo de septiembre', value: '85 %'),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 900;
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
  });
  final String title;
  final String description;
  final String actionLabel;
  final List<String> columns;
  final List<List<String>> rows;

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
          onAction: () => _showActionDialog(context, actionLabel),
        ),
        const SizedBox(height: 22),
        _DataTableCard(columns: columns, rows: rows),
      ],
    );
  }
}

class _AgendaPage extends StatelessWidget {
  const _AgendaPage({required this.query});
  final String query;

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
      columns: const ['Fecha', 'Tipo', 'Referencia', 'Estado'],
      rows: rows,
    );
  }
}

class _CommunicationPage extends StatelessWidget {
  const _CommunicationPage({required this.query});
  final String query;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageHeading(
          eyebrow: 'W13 / FINANZAS',
          title: 'Finanzas · septiembre 2026',
          subtitle: 'Cartera, movimientos, soportes y presupuesto publicado.',
          actionLabel: 'Registrar movimiento',
          onAction: () => _showActionDialog(context, 'Registrar movimiento'),
        ),
        const SizedBox(height: 22),
        const Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _Metric(label: 'Presupuesto anual', value: r'$428 M'),
            _Metric(label: 'Ejecutado', value: '67 %'),
            _Metric(label: 'Recaudo del mes', value: r'$54,8 M'),
            _Metric(label: 'Cartera vencida', value: r'$9,2 M'),
          ],
        ),
        const SizedBox(height: 18),
        const _DataTableCard(
          columns: ['Referencia', 'Concepto', 'Valor', 'Estado'],
          rows: [
            ['P-0034', 'Soporte Torre 2 / 301', r'$480.000', 'Por verificar'],
            ['MOV-918', 'Mantenimiento ascensor', r'-$3.200.000', 'Publicado'],
            [
              'MOV-917',
              'Cuotas de administración',
              r'$18.640.000',
              'Conciliado',
            ],
          ],
        ),
      ],
    );
  }
}

class _AccessPage extends StatelessWidget {
  const _AccessPage({required this.query});
  final String query;
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
      columns: const ['Hora', 'Punto', 'Persona', 'Resultado'],
      rows: rows,
    );
  }
}

class _SettingsPage extends StatefulWidget {
  const _SettingsPage();
  @override
  State<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  bool notifications = true;
  bool qrAccess = true;
  bool appointments = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PageHeading(
          eyebrow: 'CONFIGURACIÓN',
          title: 'Configuración del conjunto',
          subtitle: 'Capacidades, equipo, permisos y plan de la comunidad.',
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
      width: 245,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF71827E),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
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

Future<void> _showActionDialog(BuildContext context, String title) async {
  final controller = TextEditingController();
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'Detalle',
          hintText: 'Escribe la información necesaria',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Borrador guardado')));
          },
          child: const Text('Guardar borrador'),
        ),
      ],
    ),
  );
  controller.dispose();
}
