import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vecindario_app/features/admin/providers/admin_providers.dart';
import 'package:vecindario_app/features/auth/providers/auth_notifier.dart';
import 'package:vecindario_app/features/premium/providers/premium_providers.dart';
import 'package:vecindario_app/shared/models/community_model.dart';
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
  bool _isLoggingOut = false;

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
    final managedCommunities =
        ref.watch(managedCommunitiesProvider).valueOrNull ?? const [];
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
                    selectedCommunityId: community?.id,
                    managedCommunities: managedCommunities,
                    onCommunitySelected: (communityId) {
                      ref.read(selectedCommunityIdProvider.notifier).state =
                          communityId;
                    },
                    displayName: user?.displayName ?? 'Administración',
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    isLoggingOut: _isLoggingOut,
                    onLogout: _logout,
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
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 280),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                final slide = Tween<Offset>(
                                  begin: const Offset(.025, 0),
                                  end: Offset.zero,
                                ).animate(animation);
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: slide,
                                    child: child,
                                  ),
                                );
                              },
                              child: KeyedSubtree(
                                key: ValueKey(_area),
                                child: _buildArea(communityName, community?.id),
                              ),
                            ),
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

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);
    try {
      await ref.read(authNotifierProvider.notifier).logout();
      if (!mounted) return;
      context.go('/login');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo cerrar la sesión. Intenta nuevamente.'),
        ),
      );
      setState(() => _isLoggingOut = false);
    }
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
        _AdminArea.resumen => _LiveOverview(
          communityName: communityName,
          onNavigate: _selectArea,
        ),
        _AdminArea.comunidad => _PendingResidentsArea(query: _query),
        _AdminArea.atencion => _PqrsArea(query: _query),
        _AdminArea.agenda => _AgendaPage(
          query: _query,
          onAction: () => context.push('/premium/amenities'),
        ),
        _AdminArea.comunicacion => _LiveCommunicationPage(
          query: _query,
          onAction: () => context.push('/premium/circulars/create'),
        ),
        _AdminArea.finanzas => _LiveFinancePage(query: _query),
        _AdminArea.accesos => _LiveAccessPage(
          query: _query,
          onAction: () => context.push('/premium/access-management'),
        ),
        _AdminArea.configuracion => _SettingsPage(
          communityId: communityId,
          onOpenSettings: () => context.push('/premium/settings'),
        ),
      };
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color: selected == area
                          ? const Color(0xFFE5F1ED)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
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
    required this.selectedCommunityId,
    required this.managedCommunities,
    required this.onCommunitySelected,
    required this.displayName,
    required this.controller,
    required this.onChanged,
    required this.onLogout,
    required this.isLoggingOut,
  });

  final bool desktop;
  final String communityName;
  final String? selectedCommunityId;
  final List<CommunityModel> managedCommunities;
  final ValueChanged<String?> onCommunitySelected;
  final String displayName;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onLogout;
  final bool isLoggingOut;

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
            child: managedCommunities.length > 1
                ? DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value:
                          managedCommunities.any(
                            (item) => item.id == selectedCommunityId,
                          )
                          ? selectedCommunityId
                          : managedCommunities.first.id,
                      isExpanded: false,
                      icon: const Icon(Icons.expand_more_rounded),
                      items: managedCommunities
                          .map<DropdownMenuItem<String>>(
                            (item) => DropdownMenuItem<String>(
                              value: item.id,
                              child: Text(
                                item.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: onCommunitySelected,
                    ),
                  )
                : Text(
                    communityName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
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
          PopupMenuButton<String>(
            enabled: !isLoggingOut,
            tooltip: 'Menú de usuario',
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (value) {
              if (value == 'profile') context.push('/profile');
              if (value == 'logout') onLogout();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline_rounded),
                    SizedBox(width: 12),
                    Text('Mi perfil'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded),
                    SizedBox(width: 12),
                    Text('Cerrar sesión'),
                  ],
                ),
              ),
            ],
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFE0F0EA),
                  child: isLoggingOut
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
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
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                ],
              ],
            ),
          ),
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

class _LiveOverview extends ConsumerWidget {
  const _LiveOverview({required this.communityName, required this.onNavigate});
  final String communityName;
  final ValueChanged<_AdminArea> onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingResidentsProvider);
    final pqrs = ref.watch(allPqrsProvider);
    final circulars = ref.watch(circularsProvider);
    final finances = ref.watch(financesProvider);
    final hasError = [
      pending,
      pqrs,
      circulars,
      finances,
    ].any((v) => v.hasError);
    final isLoading = [
      pending,
      pqrs,
      circulars,
      finances,
    ].any((v) => v.isLoading);
    final income =
        finances.valueOrNull
            ?.where((entry) => entry.type.name == 'income')
            .fold<int>(0, (total, entry) => total + entry.amount) ??
        0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageHeading(
          eyebrow: 'RESUMEN EN TIEMPO REAL',
          title: 'Hoy en tu comunidad',
          subtitle: communityName,
          actionLabel: 'Crear circular',
          onAction: () => onNavigate(_AdminArea.comunicacion),
        ),
        const SizedBox(height: 22),
        if (isLoading) const LinearProgressIndicator(),
        if (hasError)
          const _Panel(
            title: 'No pudimos actualizar el resumen',
            child: Text('Revisa la conexión o los permisos de Firebase.'),
          )
        else
          _MetricGrid(
            metrics: [
              ('Accesos por revisar', '${pending.valueOrNull?.length ?? 0}'),
              (
                'Solicitudes abiertas',
                '${pqrs.valueOrNull?.where((item) => item.status.name != 'closed' && item.status.name != 'resolved').length ?? 0}',
              ),
              (
                'Circulares publicadas',
                '${circulars.valueOrNull?.length ?? 0}',
              ),
              ('Ingresos registrados', _money(income)),
            ],
          ),
        const SizedBox(height: 18),
        _Panel(
          title: 'Acciones pendientes',
          child: Column(
            children: [
              _TaskRow(
                title:
                    '${pending.valueOrNull?.length ?? 0} solicitudes de ingreso',
                subtitle: 'Aprobar o rechazar residentes sin salir del panel',
                action: 'Gestionar',
                onTap: () => onNavigate(_AdminArea.comunidad),
              ),
              _TaskRow(
                title:
                    '${pqrs.valueOrNull?.where((item) => item.status.name == 'received').length ?? 0} PQRS nuevas',
                subtitle: 'Solicitudes pendientes de primera respuesta',
                action: 'Atender',
                onTap: () => onNavigate(_AdminArea.atencion),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PendingResidentsArea extends ConsumerStatefulWidget {
  const _PendingResidentsArea({required this.query});
  final String query;

  @override
  ConsumerState<_PendingResidentsArea> createState() =>
      _PendingResidentsAreaState();
}

class _PendingResidentsAreaState extends ConsumerState<_PendingResidentsArea> {
  final Set<String> _selected = {};
  final Set<String> _busy = {};

  Future<void> _decide(String uid, bool approve) async {
    final communityId = ref.read(currentCommunityIdProvider);
    if (communityId == null || _busy.contains(uid)) return;
    setState(() => _busy.add(uid));
    try {
      final reviewer = ref.read(currentUserProvider).valueOrNull;
      if (reviewer == null) return;
      await ref
          .read(userRepositoryProvider)
          .reviewResident(
            uid: uid,
            communityId: communityId,
            reviewerUid: reviewer.id,
            approve: approve,
          );
      if (mounted) {
        setState(() => _selected.remove(uid));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              approve ? 'Residente aprobado' : 'Solicitud rechazada',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo completar la acción: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy.remove(uid));
    }
  }

  Future<void> _decideSelected(bool approve) async {
    for (final uid in _selected.toList()) {
      await _decide(uid, approve);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(pendingResidentsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PageHeading(
          eyebrow: 'OPERACIÓN',
          title: 'Personas y viviendas',
          subtitle:
              'Aprueba o rechaza solicitudes directamente desde la lista.',
        ),
        const SizedBox(height: 16),
        if (_selected.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Wrap(
              spacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: () => _decideSelected(true),
                  icon: const Icon(Icons.check_rounded),
                  label: Text('Aprobar (${_selected.length})'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _decideSelected(false),
                  icon: const Icon(Icons.close_rounded),
                  label: Text('Rechazar (${_selected.length})'),
                ),
              ],
            ),
          ),
        pending.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => _Panel(
            title: 'No se pudieron cargar las solicitudes',
            child: Text('$error'),
          ),
          data: (residents) {
            final query = widget.query.trim().toLowerCase();
            final filtered = residents
                .where(
                  (user) =>
                      query.isEmpty ||
                      '${user.displayName} ${user.email} ${user.unitInfo}'
                          .toLowerCase()
                          .contains(query),
                )
                .toList();
            if (filtered.isEmpty) {
              return const _Panel(
                title: 'Todo al día',
                child: Text(
                  'No hay solicitudes pendientes para esta comunidad.',
                ),
              );
            }
            return Container(
              decoration: _cardDecoration(),
              child: Column(
                children: filtered.map((user) {
                  final busy = _busy.contains(user.id);
                  return CheckboxListTile(
                    value: _selected.contains(user.id),
                    onChanged: busy
                        ? null
                        : (checked) => setState(() {
                            if (checked ?? false) {
                              _selected.add(user.id);
                            } else {
                              _selected.remove(user.id);
                            }
                          }),
                    title: Text(user.displayName),
                    subtitle: Text('${user.unitInfo} · ${user.email}'),
                    secondary: busy
                        ? const SizedBox.square(
                            dimension: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Wrap(
                            spacing: 4,
                            children: [
                              IconButton(
                                tooltip: 'Rechazar',
                                onPressed: () => _decide(user.id, false),
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.red,
                                ),
                              ),
                              IconButton.filledTonal(
                                tooltip: 'Aprobar',
                                onPressed: () => _decide(user.id, true),
                                icon: const Icon(Icons.check_rounded),
                              ),
                            ],
                          ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _PqrsArea extends ConsumerWidget {
  const _PqrsArea({required this.query});
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(allPqrsProvider)
        .when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) =>
              _Panel(title: 'Error al cargar PQRS', child: Text('$error')),
          data: (items) {
            final filtered = items.where((item) {
              final text =
                  '${item.type.label} ${item.category.label} ${item.description} ${item.residentName}'
                      .toLowerCase();
              return query.trim().isEmpty ||
                  text.contains(query.trim().toLowerCase());
            }).toList();
            return _RecordsPage(
              title: 'Solicitudes de la comunidad',
              description:
                  'PQRS reales recibidas desde la aplicación del residente.',
              actionLabel: 'Registrar solicitud',
              onAction: () => context.push('/premium/pqrs/create'),
              onRowTap: (_) => context.push('/premium/pqrs'),
              columns: const ['Residente', 'Tipo', 'Categoría', 'Estado'],
              rows: filtered
                  .map(
                    (item) => [
                      item.residentName,
                      item.type.label,
                      item.category.label,
                      item.status.label,
                    ],
                  )
                  .toList(),
            );
          },
        );
  }
}

class _LiveCommunicationPage extends ConsumerWidget {
  const _LiveCommunicationPage({required this.query, required this.onAction});
  final String query;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(circularsProvider)
        .when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => _Panel(
            title: 'Error al cargar circulares',
            child: Text('$error'),
          ),
          data: (items) {
            final filtered = items
                .where(
                  (item) =>
                      query.trim().isEmpty ||
                      '${item.title} ${item.body}'.toLowerCase().contains(
                        query.trim().toLowerCase(),
                      ),
                )
                .toList();
            return _RecordsPage(
              title: 'Comunicación oficial',
              description: 'Circulares sincronizadas con la aplicación móvil.',
              actionLabel: 'Nueva circular',
              onAction: onAction,
              onRowTap: (_) => context.push('/premium/circulars'),
              columns: const [
                'Publicación',
                'Prioridad',
                'Adjuntos',
                'Lecturas',
              ],
              rows: filtered
                  .map(
                    (item) => [
                      item.title,
                      item.priority.label,
                      '${item.attachmentURLs.length}',
                      '${item.readBy.length}',
                    ],
                  )
                  .toList(),
            );
          },
        );
  }
}

class _LiveFinancePage extends ConsumerWidget {
  const _LiveFinancePage({required this.query});
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(financesProvider)
        .when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) =>
              _Panel(title: 'Error al cargar finanzas', child: Text('$error')),
          data: (entries) {
            final filtered = entries
                .where(
                  (entry) =>
                      query.trim().isEmpty ||
                      '${entry.category} ${entry.description}'
                          .toLowerCase()
                          .contains(query.trim().toLowerCase()),
                )
                .toList();
            return _RecordsPage(
              title: 'Finanzas',
              description: 'Movimientos reales publicados para la comunidad.',
              actionLabel: 'Registrar movimiento',
              onAction: () => context.push('/premium/finances/create'),
              onRowTap: (_) => context.push('/premium/finances'),
              columns: const ['Tipo', 'Categoría', 'Descripción', 'Valor'],
              rows: filtered
                  .map(
                    (entry) => [
                      entry.type.label,
                      entry.category,
                      entry.description,
                      _money(entry.amount),
                    ],
                  )
                  .toList(),
            );
          },
        );
  }
}

class _LiveAccessPage extends ConsumerWidget {
  const _LiveAccessPage({required this.query, required this.onAction});
  final String query;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communityId = ref.watch(currentCommunityIdProvider);
    if (communityId == null) {
      return const _Panel(
        title: 'Sin comunidad',
        child: Text('Selecciona una comunidad.'),
      );
    }
    final stream = ref
        .watch(firestoreProvider)
        .collection('communities')
        .doc(communityId)
        .collection('access_logs')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _Panel(
            title: 'Error al cargar accesos',
            child: Text('${snapshot.error}'),
          );
        }
        if (!snapshot.hasData) return const LinearProgressIndicator();
        final rows = snapshot.data!.docs
            .map((doc) {
              final data = doc.data();
              final date = (data['createdAt'] as Timestamp?)?.toDate();
              return [
                date == null
                    ? 'Pendiente'
                    : '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                data['zone'] as String? ?? 'Sin zona',
                '${data['residents'] ?? 0}',
                '${data['visitors'] ?? 0}',
              ];
            })
            .where(
              (row) =>
                  query.trim().isEmpty ||
                  row
                      .join(' ')
                      .toLowerCase()
                      .contains(query.trim().toLowerCase()),
            )
            .toList();
        return _RecordsPage(
          title: 'Accesos y operarios',
          description: 'Historial real de validaciones QR.',
          actionLabel: 'Gestionar operarios',
          onAction: onAction,
          onRowTap: (_) => context.push('/premium/access-management'),
          columns: const ['Fecha', 'Punto', 'Residentes', 'Visitantes'],
          rows: rows,
        );
      },
    );
  }
}

String _money(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '${value < 0 ? '-' : ''}\$${buffer.toString()}';
}

class _RecordsPage extends StatelessWidget {
  const _RecordsPage({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.columns,
    required this.rows,
    this.onAction,
    this.onRowTap,
  });
  final String title;
  final String description;
  final String actionLabel;
  final List<String> columns;
  final List<List<String>> rows;
  final VoidCallback? onAction;
  final ValueChanged<int>? onRowTap;

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
        _DataTableCard(columns: columns, rows: rows, onRowTap: onRowTap),
      ],
    );
  }
}

class _AgendaPage extends ConsumerWidget {
  const _AgendaPage({required this.query, required this.onAction});
  final String query;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(amenitiesProvider)
        .when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) =>
              _Panel(title: 'Error al cargar espacios', child: Text('$error')),
          data: (amenities) {
            final rows = amenities
                .where(
                  (item) =>
                      query.trim().isEmpty ||
                      '${item.name} ${item.description} ${item.hours}'
                          .toLowerCase()
                          .contains(query.trim().toLowerCase()),
                )
                .map(
                  (item) => [
                    item.name,
                    item.hours,
                    '${item.capacity} personas',
                    _money(item.hourlyRate),
                  ],
                )
                .toList();
            return _RecordsPage(
              title: 'Espacios y agenda',
              description: 'Zonas sociales disponibles para reservas.',
              actionLabel: 'Configurar disponibilidad',
              onAction: onAction,
              onRowTap: (_) => context.push('/premium/amenities'),
              columns: const ['Espacio', 'Horario', 'Capacidad', 'Tarifa'],
              rows: rows,
            );
          },
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
        const _Panel(
          title: 'Equipo y permisos',
          child: Text(
            'La administración de operarios se realiza desde Accesos. No se muestran usuarios simulados.',
          ),
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

class _DataTableCard extends StatelessWidget {
  const _DataTableCard({
    required this.columns,
    required this.rows,
    this.onRowTap,
  });
  final List<String> columns;
  final List<List<String>> rows;
  final ValueChanged<int>? onRowTap;

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
              rows: rows.indexed
                  .map(
                    (entry) => DataRow(
                      onSelectChanged: onRowTap == null
                          ? null
                          : (_) => onRowTap!(entry.$1),
                      cells: entry.$2.map((cell) {
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
