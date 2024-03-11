import 'dart:async';
import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:ihl/new_design/presentation/pages/spalshScreen/splashScreen.dart';
import 'package:ihl/views/dietJournal/models/food_list_tab_model.dart';
import 'package:ihl/views/dietJournal/models/user_bookmarked_activity_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

// SharedPreferences
class SpUtil {
  static SpUtil _singleton;
  static SharedPreferences _prefs;
  static StreamingSharedPreferences _preferences;
  static Lock _lock = Lock();

  static Future<SpUtil> getInstance() async {
    if (_singleton == null) {
      await _lock.synchronized(() async {
        if (_singleton == null) {
          // keep local instance till it is fully initialized.
          var singleton = SpUtil._();
          await singleton._init();
          _singleton = singleton;
        }
      });
    }
    return _singleton;
  }

  SpUtil._();

  Future _init() async {
    _preferences = await StreamingSharedPreferences.instance;
    _prefs = await SharedPreferences.getInstance();
  }

  // put object
  static Future<bool> putObject(String key, Object value) {
    if (_prefs == null) return null;
    return _prefs.setString(key, value == null ? "" : json.encode(value));
  }

  // get obj
  static T getObj<T>(String key, T f(Map v), {T defValue}) {
    Map map = getObject(key);
    return map == null ? defValue : f(map);
  }

  // get object
  static Map getObject(String key) {
    if (_prefs == null) return null;
    String _data = _prefs.getString(key);
    return (_data == null || _data.isEmpty) ? null : json.decode(_data);
  }

  // put object list
  static Future<bool> putObjectList(String key, List<Object> list) {
    if (_prefs == null) return null;
    List<String> _dataList = list?.map((value) {
      return json.encode(value);
    })?.toList();
    return _prefs.setStringList(key, _dataList);
  }

  static Future<bool> putReactiveRecentObjectList(List<Object> list) async {
    if (_preferences == null) return null;
    return _preferences.setCustomValue<List<FoodListTileModel>>(
      'recent_food',
      list,
      adapter: JsonAdapter(
        deserializer: (value) => listFoodDetailListFromJson(value),
        serializer: (value) => listFoodDetailListToJson(value),
      ),
    );
  }

  static Future<bool> putRecentObjectList(String key, List<Object> list) async {
    if (_prefs == null) return null;
    List<String> _dataList = list?.map((value) {
      return listFoodDetailToJson(value);
    })?.toList();
    return _prefs.setStringList(key, _dataList);
  }

  static Future<bool> putRecentActivityObjectList(String key, List<Object> list) async {
    if (_prefs == null) return null;
    List<String> _dataList = list?.map((value) {
      return bookMarkedActivitySPToJson(value);
    })?.toList();
    return _prefs.setStringList(key, _dataList);
  }

  static Preference<FoodListTileModel> getReactiveRecentObjectList() {
    if (_prefs == null) return null;
    return _preferences.getCustomValue<FoodListTileModel>(
      'recent_food',
      defaultValue: FoodListTileModel.empty(),
      adapter: JsonAdapter(
        deserializer: (value) => listFoodDetailFromJson(value),
        serializer: (value) => listFoodDetailToJson(value),
      ),
    );
  }

  static List<FoodListTileModel> getRecentObjectList(String key) {
    if (_prefs == null) return null;
    List<String> dataLis = _prefs.getStringList(key);
    return dataLis?.map((value) {
      FoodListTileModel _dataMap = listFoodDetailFromJson(value);
      String parse2 = _dataMap.subtitle.replaceAll("and", "*");
      String parse3 = parse2.replaceAll("half", "1/2");
      String parse4 = parse3.replaceAll("inches", '")');
      String parse5 = parse4.replaceAll("one", '1');
      String parse6 = parse5.replaceAll("two", '2');
      String parse7 = parse6.replaceAll("three", '3');
      String parse8 = parse7.replaceAll("four", '4');
      String parse9 = parse8.replaceAll("five", '5');
      String parse10 = parse9.replaceAll("six", '6');
      String parse11 = parse10.replaceAll("seven", '7');
      String parse12 = parse11.replaceAll("eight", '8');
      String parse13 = parse12.replaceAll("nine", '9');
      String parse14 = parse13.replaceAll("zero", '0');
      String parse15 = parse14.replaceAll("to", '-');
      String parse16 = parse15.replaceAll("Small ", "Small (");
      String parse17 = parse16.replaceAll("Medium ", "Medium (");
      String parse18 = parse17.replaceAll("Large ", "Large (");
      String parse19 = parse18.replaceAll("by", "/");
      _dataMap.quantity = parse19;
      return _dataMap;
    })?.toList();
  }

  static List<BookMarkedActivity> getRecentActivityObjectList(String key) {
    if (_prefs == null) return null;
    List<String> dataLis = _prefs.getStringList(key);
    return dataLis?.map((value) {
      BookMarkedActivity _dataMap = bookMarkedActivitySPFromJson(value);
      return _dataMap;
    })?.toList();
  }

  // get obj list
  static List<T> getObjList<T>(String key, T f(Map v), {List<T> defValue = const []}) {
    List<Map> dataList = getObjectList(key);
    List<T> list = dataList?.map((value) {
      return f(value);
    })?.toList();
    return list ?? defValue;
  }

  // get object list
  static List<Map> getObjectList(String key) {
    if (_prefs == null) return null;
    List<String> dataLis = _prefs.getStringList(key);
    return dataLis?.map((value) {
      Map _dataMap = json.decode(value);
      return _dataMap;
    })?.toList();
  }

  // get string
  static String getString(String key, {String defValue = ''}) {
    if (_prefs == null) return defValue;
    return _prefs.getString(key) ?? defValue;
  }

  // put string
  static Future<bool> putString(String key, String value) {
    if (_prefs == null) return null;
    return _prefs.setString(key, value);
  }

  // get bool
  static bool getBool(String key, {bool defValue = false}) {
    if (_prefs == null) return defValue;
    return _prefs.getBool(key) ?? defValue;
  }

  // put bool
  static Future<bool> putBool(String key, bool value) {
    if (_prefs == null) return null;
    return _prefs.setBool(key, value);
  }

  // get int
  static int getInt(String key, {int defValue = 0}) {
    if (_prefs == null) return defValue;
    return _prefs.getInt(key) ?? defValue;
  }

  // put int.
  static Future<bool> putInt(String key, int value) {
    if (_prefs == null) return null;
    return _prefs.setInt(key, value);
  }

  // get double
  static double getDouble(String key, {double defValue = 0.0}) {
    if (_prefs == null) return defValue;
    return _prefs.getDouble(key) ?? defValue;
  }

  // put double
  static Future<bool> putDouble(String key, double value) {
    if (_prefs == null) return null;
    return _prefs.setDouble(key, value);
  }

  // get string list
  static List<String> getStringList(String key, {List<String> defValue = const []}) {
    if (_prefs == null) return defValue;
    return _prefs.getStringList(key) ?? defValue;
  }

  // put string list
  static Future<bool> putStringList(String key, List<String> value) {
    if (_prefs == null) return null;
    return _prefs.setStringList(key, value);
  }

  // get dynamic
  static dynamic getDynamic(String key, {Object defValue}) {
    if (_prefs == null) return defValue;
    return _prefs.get(key) ?? defValue;
  }

  // have key
  static bool haveKey(String key) {
    if (_prefs == null) return null;
    return _prefs.getKeys().contains(key);
  }

  // get keys
  static Set<String> getKeys() {
    if (_prefs == null) return null;
    return _prefs.getKeys();
  }

  // remove
  static Future<bool> remove(String key) {
    if (_prefs == null) return null;
    return _prefs.remove(key);
  }

  // clear
  static Future<bool> clear() async{
    if (_prefs == null) return null;
   await localSotrage.erase();
    return _prefs.clear();
  }

  //Sp is initialized
  static bool isInitialized() {
    return _prefs != null;
  }
}
