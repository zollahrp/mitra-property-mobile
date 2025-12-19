import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/property_model.dart';

class SavedService {
  static const baseUrl = "https://api.mitrapropertysentul.com";

  /// =========================
  /// SAVE PROPERTY
  /// =========================
  Future<bool> saveProperty(String propertyId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    if (token.isEmpty) return false;

    final url = Uri.parse("$baseUrl/users/saved/$propertyId");

    final res = await http.post(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    print("SAVE → ${res.statusCode}");
    print("SAVE BODY → ${res.body}");

    return res.statusCode == 200 || res.statusCode == 201;
  }

  /// =========================
  /// REMOVE SAVED
  /// =========================
  Future<bool> removeSavedProperty(String propertyId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    if (token.isEmpty) return false;

    final url = Uri.parse("$baseUrl/users/saved/$propertyId");

    final res = await http.delete(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    print("DELETE → ${res.statusCode}");

    return res.statusCode == 200;
  }

  /// =========================
  /// GET SAVED PROPERTIES
  /// =========================
  Future<List<PropertyModel>> getSavedProperties() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    if (token.isEmpty) return [];

    final url = Uri.parse("$baseUrl/users/saved/show");

    final res = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    print("GET SAVED → ${res.statusCode}");
    print("GET SAVED BODY → ${res.body}");

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);

      final List items = body["items"] ?? [];

      /// 🔥 AMBIL object `property`-nya
      return items.map((e) => PropertyModel.fromJson(e["property"])).toList();
    }

    return [];
  }
}
