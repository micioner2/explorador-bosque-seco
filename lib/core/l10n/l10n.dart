import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

export '../../l10n/app_localizations.dart';

/// Atajo para leer los textos traducidos: `context.l10n.navExplorar`.
///
/// Los textos viven en `lib/l10n/app_es.arb` (plantilla) y `app_en.arb`.
extension ContextoL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
