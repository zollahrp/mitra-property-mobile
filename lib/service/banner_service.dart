import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/banner_model.dart';

class BannerService {
  static const _baseUrl =
      'https://api.mitrapropertysentul.com/banner';

  Future<List<BannerModel>> fetchBanners() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      throw Exception("Token belum tersedia");
    }

    final res = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint("STATUS BANNER: ${res.statusCode}");
    debugPrint("BODY BANNER: ${res.body}");

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => BannerModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal load banner (${res.statusCode})');
    }
  }
}
