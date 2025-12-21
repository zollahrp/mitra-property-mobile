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
    Map<String, dynamic> data,
  ) async {
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
  /// =====================================================
  /// GET LIST PROPERTY (Approved Only)
  /// =====================================================
  static Future<List<PropertyModel>> getApprovedProperties() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    if (token.isEmpty) {
      print("⚠️ Token tidak ditemukan!");
      return [];
    }

    final url = Uri.parse("$baseUrl/properties/approved");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      // ⚠️ cek struktur response backend
      if (body is List) {
        // kalau backend langsung return array
        return body.map((e) => PropertyModel.fromJson(e)).toList();
      }

      if (body.containsKey("items")) {
        // kalau masih pakai pagination
        final result = PropertyListResponse.fromJson(body);
        return result.items;
      }

      print("⚠️ Format response tidak dikenali");
      return [];
    } else {
      print("❌ Error: ${response.statusCode} → ${response.body}");
      return [];
    }
  }
}
