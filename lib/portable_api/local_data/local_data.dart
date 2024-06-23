import 'package:shared_preferences/shared_preferences.dart';

class LocalDataHandler {
  static late final SharedPreferences prefs;

  static Future<void> initDataHandler() async {
    LocalDataHandler.prefs = await SharedPreferences.getInstance();
  }

  static void addData(String key, dynamic data) {
    if (data is bool) {
      prefs.setBool(key, data);
    } else if (data is int) {
      prefs.setInt(key, data);
    } else if (data is double) {
      prefs.setDouble(key, data);
    } else if (data is String) {
      prefs.setString(key, data);
    } else if (data is List<String>) {
      prefs.setStringList(key, data);
    }
  }

  static T readData<T>(String key, T def) {
    Object? value = prefs.get(key);
    return value != null ? (value as T) : def;
  }
}
