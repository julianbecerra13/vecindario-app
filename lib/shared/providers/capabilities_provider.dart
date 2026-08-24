import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/features/services/providers/services_provider.dart';
import 'package:vecindario_app/features/stores/providers/stores_provider.dart';

/// Capacidades del usuario actual que no son roles exclusivos: un residente
/// (o un admin) puede tener una tienda y ofrecer un servicio a la vez, sin
/// dejar de ser residente. Se derivan de datos reales (ownerUid en stores y
/// services), no de un campo de rol.

final hasStoreProvider = Provider<bool>((ref) {
  return ref.watch(ownerStoreProvider).valueOrNull != null;
});

final offersServiceProvider = Provider<bool>((ref) {
  return ref.watch(ownerServiceProvider).valueOrNull != null;
});
