import 'dart:convert';

import '../models/basic_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadBasicData {
  Future<void> setObjectInSharedPreferences(String key, BasicDataModel value) async {
    print(value.toString());
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> jsonValue = value.toJson();
    print(jsonValue); // Serialize the object to JSON
    await prefs.setString(key, jsonValue.toString());
  }

  Future<BasicDataModel> getObjectFromSharedPreferences<T>(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String jsonValue = prefs.getString(key);

    if (jsonValue != null) {
      print(jsonValue);
      try {
        jsonDecode(jsonEncode(jsonValue));
      } catch (e) {
        print(e);
      }
      final map = jsonDecode(jsonEncode(jsonValue));
      dynamic map1 = json.decode(map);
      print(map);
      BasicDataModel jsonObject = BasicDataModel.fromJson(map);
      print(jsonObject);
      return jsonObject; // Deserialize the JSON into an object
    }
    return null; // If the key doesn't exist
  }
}
