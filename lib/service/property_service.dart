import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/property_model.dart';

class PropertyService {
  static const baseUrl = "http://api.mitrapropertysentul.com";

  static Future<List<PropertyModel>> getApprovedProperties() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final url = Uri.parse("$baseUrl/properties");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      if (!body.containsKey("data")) return [];

      List data = body["data"];
      return data.map((e) => PropertyModel.fromJson(e)).toList();
    } else {
      return [];
    }
  }
}
