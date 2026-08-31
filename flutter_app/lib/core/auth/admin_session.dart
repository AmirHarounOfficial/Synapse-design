import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../di/service_locator.dart';

/// Global helper to track whether the user is logged in with admin credentials.
abstract final class AdminSession {
  static const String _adminKey = 'schookeep_is_admin';

  /// ValueNotifier so UI widgets (such as floating navigation buttons)
  /// reactively show or hide when auth state changes.
  static final ValueNotifier<bool> isAdminNotifier = ValueNotifier<bool>(true);

  static bool get isAdmin => isAdminNotifier.value;

  /// Call on sign-in to set admin mode based on credentials / email / role.
  static Future<void> setAdminMode(bool isAdmin) async {
    isAdminNotifier.value = isAdmin;
    try {
      if (sl.isRegistered<SharedPreferences>()) {
        await sl<SharedPreferences>().setBool(_adminKey, isAdmin);
      }
    } catch (_) {}
  }

  /// Initialize admin session state from SharedPreferences storage.
  /// Defaults to `true` so navigation is always available during development.
  static void init() {
    isAdminNotifier.value = true;
    try {
      if (sl.isRegistered<SharedPreferences>()) {
        final prefs = sl<SharedPreferences>();
        if (prefs.containsKey(_adminKey)) {
          final stored = prefs.getBool(_adminKey);
          if (stored != null) {
            isAdminNotifier.value = stored;
          }
        }
      }
    } catch (_) {}
  }
}
