import 'package:flutter/widgets.dart';
import 'package:vecindario_app/l10n/app_localizations.dart';

/// Acceso corto a las cadenas localizadas: `context.l10n.login`.
extension L10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
