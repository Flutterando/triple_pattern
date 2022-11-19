// ignore_for_file: type_annotate_public_apis

library hydrated_triple;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:triple/triple.dart';

///[SharedPreferencesHydratedDelegate] implements an abstract [HydratedDelegate]
class SharedPreferencesHydratedDelegate implements HydratedDelegate {
  ///The method [clear] it's the type [Future]
  @override
  Future clear() async {
    ///The variable [shared] it's the type [SharedPreferences] and receive
    ///await SharedPreferences.getInstance() and await shared.clear()
    final shared = await SharedPreferences.getInstance();
    await shared.clear();
  }

  ///The method [tryDecode] it's the type Map and receive
  ///the param [json] it's the type String
  Map? tryDecode(String json) {
    ///Try return jsonDecode(json)
    try {
      return jsonDecode(json);

      ///If is error return null
    } catch (e) {
      return null;
    }
  }

  ///The method [get] receive the param [key] it's the type String
  @override
  Future get(String key) async {
    ///The variable [shared] it's the type [SharedPreferences] and receive
    ///await SharedPreferences.getInstance()
    final shared = await SharedPreferences.getInstance();

    ///The variable [value] it's the type Object and
    ///receive shared.get(key)
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
    assert(
      value is num ||
          value is String ||
          value is bool ||
          value is List<String> ||
          value is Map ||
          value is Set ||
          value is Serializable,
      'not valid value',
    );

    final shared = await SharedPreferences.getInstance();
    if (value is int) {
      await shared.setInt(
        key,
        value,
      );
    } else if (value is double) {
      await shared.setDouble(
        key,
        value,
      );
    } else if (value is String) {
      await shared.setString(
        key,
        value,
      );
    } else if (value is bool) {
      await shared.setBool(
        key,
        value,
      );
    } else if (value is List<String>) {
      await shared.setStringList(
        key,
        value,
      );
    } else if (value is Map) {
      await shared.setString(
        key,
        jsonEncode(value),
      );
    } else if (value is Serializable) {
      await shared.setString(
        key,
        jsonEncode(
          value.toMap(),
        ),
      );
    }
  }
}
