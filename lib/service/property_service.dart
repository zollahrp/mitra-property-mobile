import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/property_model.dart';

class PropertyService {
  static const baseUrl = "http://api.mitrapropertysentul.com";

  /// GET LIST PROPERTY (paginate)
  static Future<List<PropertyModel>> getApprovedProperties({int page = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final url = Uri.parse("$baseUrl/properties?page=$page");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    // Jika token kosong atau expired
    if (token.isEmpty) {
      print("⚠️ Token kosong!");
      return [];
    }

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      // === Struktur benar: { items: [], total, page, perPage, totalPages }
      if (!body.containsKey("items")) return [];

      final result = PropertyListResponse.fromJson(body);

      return result.items;
    } else {
      print("❌ Error: ${response.statusCode} → ${response.body}");
      return [];
    }
  }
}
