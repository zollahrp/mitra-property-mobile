import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/property_model.dart';

class PropertyService {
  static const baseUrl = "https://api.mitrapropertysentul.com";

  /// =====================================================
  /// HELPER: Get Auth Token
  /// =====================================================
  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token") ?? "";
  }

  /// =====================================================
  /// HELPER: Common Headers
  /// =====================================================
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  /// =====================================================
  /// HELPER: Parse Paginated Response
  /// =====================================================
  static List<PropertyModel> _parsePaginatedResponse(String body) {
    final data = jsonDecode(body);
    
    if (data is List) {
      return data.map((e) => PropertyModel.fromJson(e)).toList();
    }
    
    if (data.containsKey("items")) {
      final result = PropertyListResponse.fromJson(data);
      return result.items;
    }
    
    return [];
  }

  /// =====================================================
  /// CREATE PROPERTY
  /// =====================================================
  static Future<CreatePropertyResponse?> createProperty(
    Map<String, dynamic> data,
  ) async {
    final token = await _getToken();

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

    if (response.statusCode == 200 || response.statusCode == 201) {
      return CreatePropertyResponse.fromJson(jsonDecode(response.body));
    }

    return null;
  }

  /// =====================================================
  /// GET LIST PROPERTY (Approved Only)
  /// =====================================================
  static Future<List<PropertyModel>> getApprovedProperties() async {
    final token = await _getToken();

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
      return _parsePaginatedResponse(response.body);
    } else {
      print("❌ Error: ${response.statusCode} → ${response.body}");
      return [];
    }
  }

  /// =====================================================
  /// FILTER API ENDPOINTS
  /// =====================================================

  /// Get Property untuk Dijual (Beli)
  static Future<List<PropertyModel>> getPropertiesForSale() async {
    final token = await _getToken();
    if (token.isEmpty) return [];

    final url = Uri.parse("$baseUrl/properties/for-sale");
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return _parsePaginatedResponse(response.body);
    }
    return [];
  }

  /// Get Property untuk Disewa (Rent)
  static Future<List<PropertyModel>> getPropertiesForRent() async {
    final token = await _getToken();
    if (token.isEmpty) return [];

    final url = Uri.parse("$baseUrl/properties/for-rent");
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return _parsePaginatedResponse(response.body);
    }
    return [];
  }

  /// Get Rumah Properties
  static Future<List<PropertyModel>> getRumahProperties() async {
    final token = await _getToken();
    if (token.isEmpty) return [];

    final url = Uri.parse("$baseUrl/properties/rumah");
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return _parsePaginatedResponse(response.body);
    }
    return [];
  }

  /// Get Apartemen Properties
  static Future<List<PropertyModel>> getApartemenProperties() async {
    final token = await _getToken();
    if (token.isEmpty) return [];

    final url = Uri.parse("$baseUrl/properties/apartemen");
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return _parsePaginatedResponse(response.body);
    }
    return [];
  }

  /// Get Furnished Properties
  static Future<List<PropertyModel>> getFurnishedProperties() async {
    final token = await _getToken();
    if (token.isEmpty) return [];

    final url = Uri.parse("$baseUrl/properties/furnished");
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return _parsePaginatedResponse(response.body);
    }
    return [];
  }

  /// Get Semi-Furnished Properties
  static Future<List<PropertyModel>> getSemiFurnishedProperties() async {
    final token = await _getToken();
    if (token.isEmpty) return [];

    final url = Uri.parse("$baseUrl/properties/semi-furnished");
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return _parsePaginatedResponse(response.body);
    }
    return [];
  }

  /// Get Unfurnished Properties
  static Future<List<PropertyModel>> getUnfurnishedProperties() async {
    final token = await _getToken();
    if (token.isEmpty) return [];

    final url = Uri.parse("$baseUrl/properties/unfurnished");
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return _parsePaginatedResponse(response.body);
    }
    return [];
  }

  /// Get SHM Properties
  static Future<List<PropertyModel>> getSHMProperties() async {
    final token = await _getToken();
    if (token.isEmpty) return [];

    final url = Uri.parse("$baseUrl/properties/shm");
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return _parsePaginatedResponse(response.body);
    }
    return [];
  }

  /// Get SHGB Properties
  static Future<List<PropertyModel>> getSHGBProperties() async {
    final token = await _getToken();
    if (token.isEmpty) return [];

    final url = Uri.parse("$baseUrl/properties/shgb");
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return _parsePaginatedResponse(response.body);
    }
    return [];
  }

  /// Get PPJB Properties
  static Future<List<PropertyModel>> getPPJBProperties() async {
    final token = await _getToken();
    if (token.isEmpty) return [];

    final url = Uri.parse("$baseUrl/properties/ppjb");
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return _parsePaginatedResponse(response.body);
    }
    return [];
  }

  /// Get Lowest Price Properties (Harga Terendah ke Tertinggi)
  static Future<List<PropertyModel>> getLowestPriceProperties() async {
    final token = await _getToken();
    if (token.isEmpty) return [];

    final url = Uri.parse("$baseUrl/properties/lowest-price");
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return _parsePaginatedResponse(response.body);
    }
    return [];
  }

  /// Get Highest Price Properties (Harga Tertinggi ke Terendah)
  static Future<List<PropertyModel>> getHighestPriceProperties() async {
    final token = await _getToken();
    if (token.isEmpty) return [];

    final url = Uri.parse("$baseUrl/properties/highest-price");
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return _parsePaginatedResponse(response.body);
    }
    return [];
  }

  /// Get Newest Properties
  static Future<List<PropertyModel>> getNewestProperties() async {
    final token = await _getToken();
    if (token.isEmpty) return [];

    final url = Uri.parse("$baseUrl/properties/newest");
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return _parsePaginatedResponse(response.body);
    }
    return [];
  }
}
