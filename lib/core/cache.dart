import 'package:shared_preferences/shared_preferences.dart';

class ResponseCache {
  ResponseCache._();
  static const _prefix = 'cache_';

  static Future<String?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefix$key');
  }

  static Future<void> write(String key, String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$key', json);
  }
}
