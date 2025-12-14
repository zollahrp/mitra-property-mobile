import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mitra_property/models/property_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedService {
  late Dio dio;

  SavedService() {
    dio = Dio(
      BaseOptions(
        baseUrl: "https://api.mitrapropertysentul.com",
        headers: {"Accept": "application/json"},
      ),
    );
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // =========================
  // SAVE PROPERTY
  // POST /users/saved/{id}
  // =========================
  Future<bool> saveProperty(String propertyId) async {
    try {
      final token = await _getToken();

      final res = await dio.post(
        "/users/saved/$propertyId",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      debugPrint("SAVE → ${res.statusCode}");
      debugPrint("SAVE DATA → ${res.data}");

      return res.statusCode == 200 || res.statusCode == 201;
    } on DioException catch (e) {
      debugPrint("SAVE ERROR → ${e.response?.statusCode}");
      debugPrint("SAVE ERROR DATA → ${e.response?.data}");
      return false;
    }
  }

  // =========================
  // DELETE SAVED PROPERTY
  // DELETE /users/saved/{id}
  // =========================
  Future<bool> removeSavedProperty(String propertyId) async {
    try {
      final token = await _getToken();

      final res = await dio.delete(
        "/users/saved/$propertyId",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      debugPrint("UNSAVE → ${res.statusCode}");
      return res.statusCode == 200;
    } on DioException catch (e) {
      debugPrint("UNSAVE ERROR → ${e.response?.statusCode}");
      debugPrint("UNSAVE ERROR DATA → ${e.response?.data}");
      return false;
    }
  }

  // =========================
  // GET SAVED PROPERTIES
  // GET /users/saved/show  ✅
  // =========================
  Future<List<PropertyModel>> getSavedProperties() async {
    final token = await _getToken();

    final res = await dio.get(
      "/users/saved/show",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    final body = res.data;

    if (body == null) return [];

    List list = [];

    if (body["data"] is List) {
      list = body["data"];
    } else if (body["data"] is Map && body["data"]["data"] is List) {
      list = body["data"]["data"];
    }

    // 🔥 INI KUNCINYA
    return list
        .where((e) => e["property"] != null)
        .map<PropertyModel>((e) => PropertyModel.fromJson(e["property"]))
        .toList();
  }
}
