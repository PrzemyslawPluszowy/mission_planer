import 'package:flutter/widgets.dart';
import 'package:mission_planer/l10n/l10n.dart';

extension BuildContextExt on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
