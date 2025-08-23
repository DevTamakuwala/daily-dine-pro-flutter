import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveTokenId(value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("TokenId", value);
}

Future<void> saveEmail(value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("Email", value);
}

Future<void> savePassword(value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("Password", value);
}

Future<String?> getTokenId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? value = prefs.getString("TokenId");
  return value;
}

Future<String?> getEmail() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? value = prefs.getString("Email");
  return value;
}

Future<String?> getPassword() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? value = prefs.getString("Password");
  return value;
}