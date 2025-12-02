import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/property_model.dart';

class PropertyService {
  static const baseUrl = "https://api.mitrapropertysentul.com";

  /// =====================================================
  /// CREATE PROPERTY
  /// =====================================================
  static Future<CreatePropertyResponse?> createProperty(
      Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    if (token.isEmpty) {
      print("⚠️ Token kosong, tidak bisa create property!");
      return null;
    }

    final url = Uri.parse("$baseUrl/properties");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    // BACKEND biasanya return 200
    if (response.statusCode == 200 || response.statusCode == 201) {
      return CreatePropertyResponse.fromJson(jsonDecode(response.body));
    }

    // tampilkan error backend
    return null;
  }

  /// =====================================================
  /// GET LIST PROPERTY (Paginate)
  /// =====================================================
  static Future<List<PropertyModel>> getApprovedProperties({int page = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    if (token.isEmpty) {
      print("⚠️ Token tidak ditemukan!");
      return [];
    }

    final url = Uri.parse("$baseUrl/properties?page=$page");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("STATUS: ${response.statusCode}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      // backend harus punya key "items"
      if (!body.containsKey("items")) {
        print("⚠️ Key 'items' tidak ditemukan!");
        return [];
      }

      final result = PropertyListResponse.fromJson(body);

      return result.items;
    } else {
      print("❌ Error: ${response.statusCode} → ${response.body}");
      return [];
    }
  }
}
