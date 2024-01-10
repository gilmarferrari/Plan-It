import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static Future<bool> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.setString(key, value);
  }

  static Future<bool> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.setBool(key, value);
  }

  static Future<bool> saveMap(String key, Map<String, dynamic> value) async {
    return saveString(key, jsonEncode(value));
  }

  static Future<String> getString(String key,
      [String defaultValue = '']) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(key) ?? defaultValue;
  }

  static Future<bool> getBool(String key, [bool defaultValue = false]) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(key) ?? defaultValue;
  }

  static Future<Map<String, dynamic>> getMap(String key) async {
    try {
      return jsonDecode(await getString(key));
    } catch (_) {
      return {};
    }
  }

  static Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.remove(key);
  }

  static Future<bool> hasKey(String key) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.containsKey(key);
  }
}
