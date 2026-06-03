// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PicTapCount';

  @override
  String get noSessions =>
      'No counting sessions yet.\nTake or import a photo to start.';

  @override
  String get openCamera => 'Camera';

  @override
  String get importGallery => 'Gallery';

  @override
  String get undo => 'Undo';

  @override
  String get reset => 'Reset';

  @override
  String get resetConfirmTitle => 'Reset counting?';

  @override
  String get resetConfirmBody =>
      'All points will be removed. This cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get resetConfirm => 'Reset';

  @override
  String get deleteConfirmTitle => 'Delete session?';

  @override
  String get deleteConfirmBody =>
      'The photo and all count data will be permanently deleted.';

  @override
  String get delete => 'Delete';

  @override
  String get rename => 'Rename';

  @override
  String get renameTitle => 'Rename session';

  @override
  String get photoName => 'Name';
}
