import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _config;

  RemoteConfigService(this._config);

  Future<void> initialize() async {
    await _config.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await _config.setDefaults({
      // Tarifas de servicio por estrato (COP)
      'fee_estrato_1': 200,
      'fee_estrato_2': 200,
      'fee_estrato_3': 300,
      'fee_estrato_4': 350,
      'fee_estrato_5': 450,
      'fee_estrato_6': 500,
      // Features premium por plan
      'starter_features': 'circulars,pqrs,manual,fines',
      'professional_features': 'circulars,pqrs,manual,fines,amenities,finances,payments',
      'enterprise_features': 'circulars,pqrs,manual,fines,amenities,finances,payments,assemblies,reports,api',
    });

    try {
      await _config.fetchAndActivate();
    } catch (_) {
      // Usa defaults si falla el fetch
    }
  }

  int getServiceFee(int estrato) {
    final clamped = estrato.clamp(1, 6);
    return _config.getInt('fee_estrato_$clamped');
  }

  List<String> getPlanFeatures(String plan) {
    final raw = _config.getString('${plan}_features');
    if (raw.isEmpty) return [];
    return raw.split(',');
  }

  bool isFeatureInPlan(String plan, String feature) {
    return getPlanFeatures(plan).contains(feature);
  }
}

final remoteConfigProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService(FirebaseRemoteConfig.instance);
});
