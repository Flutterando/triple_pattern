library hydrated_triple;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:triple/triple.dart';

class SharedPreferencesHydratedDelegate implements HydratedDelegate {
  @override
  Future clear() async {
    final shared = await SharedPreferences.getInstance();
    shared.clear();
  }

  Map? tryDecode(String json) {
    try {
      return jsonDecode(json);
    } catch (e) {
      return null;
    }
  }

  @override
  Future get(String key) async {
    final shared = await SharedPreferences.getInstance();
    final value = shared.get(key);
    if (value is String) {
      final json = tryDecode(value);
      if (json == null) {
        return value;
      } else {
        return json;
      }
    } else {
      return value;
    }
  }

  @override
  Future save(String key, value) async {
    assert(value is num || value is String || value is bool || value is List<String> || value is Map || value is Set || value is Serializable, 'not valid value');

    final shared = await SharedPreferences.getInstance();
    if (value is int) {
      shared.setInt(key, value);
    } else if (value is double) {
      shared.setDouble(key, value);
    } else if (value is String) {
      shared.setString(key, value);
    } else if (value is bool) {
      shared.setBool(key, value);
    } else if (value is List<String>) {
      shared.setStringList(key, value);
    } else if (value is Map) {
      shared.setString(key, jsonEncode(value));
    } else if (value is Serializable) {
      shared.setString(key, jsonEncode(value.toMap()));
    }
  }
}
