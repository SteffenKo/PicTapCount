// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'PicTapCount';

  @override
  String get noSessions =>
      'Noch keine Zählsitzungen.\nFoto aufnehmen oder importieren, um zu starten.';

  @override
  String get openCamera => 'Kamera';

  @override
  String get importGallery => 'Galerie';

  @override
  String get undo => 'Rückgängig';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get resetConfirmTitle => 'Zählung zurücksetzen?';

  @override
  String get resetConfirmBody =>
      'Alle Punkte werden gelöscht. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get resetConfirm => 'Zurücksetzen';

  @override
  String get deleteConfirmTitle => 'Sitzung löschen?';

  @override
  String get deleteConfirmBody =>
      'Das Foto und alle Zähldaten werden dauerhaft gelöscht.';

  @override
  String get delete => 'Löschen';
}
