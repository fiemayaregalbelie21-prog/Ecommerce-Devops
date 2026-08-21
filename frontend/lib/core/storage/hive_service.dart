import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class HiveService {
  HiveService._();

  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<Map>(AppConstants.hiveCartBox),
      Hive.openBox(AppConstants.hiveAuthBox),
      Hive.openBox(AppConstants.hiveWishlistBox),
      Hive.openBox(AppConstants.hiveRecentsBox),
      Hive.openBox(AppConstants.hiveSettingsBox),
      Hive.openBox(AppConstants.hiveSearchBox),
    ]);
  }

  static Box get authBox => Hive.box(AppConstants.hiveAuthBox);
  static Box<Map> get cartBox => Hive.box<Map>(AppConstants.hiveCartBox);
  static Box get wishlistBox => Hive.box(AppConstants.hiveWishlistBox);
  static Box get recentsBox => Hive.box(AppConstants.hiveRecentsBox);
  static Box get settingsBox => Hive.box(AppConstants.hiveSettingsBox);
  static Box get searchBox => Hive.box(AppConstants.hiveSearchBox);
}