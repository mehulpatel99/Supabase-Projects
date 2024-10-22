
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager{
  static Future<void> setString({required String k,required String value}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(k, value);
  }

  static Future<void> setInt({required String k,required int value}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(k, value);
  }

  static Future<String?> getString({required String k}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
   return  await prefs.getString(k);
  }

  static remove()async{
    final  SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}