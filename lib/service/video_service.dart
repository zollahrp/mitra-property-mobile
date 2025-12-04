import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';

class VideoService {
  static const baseUrl = "https://api.mitrapropertysentul.com/videos";

  static Future<List<VideoModel>> getVideos(String token) async {
    final res = await http.get(
      Uri.parse(baseUrl),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      List data = jsonDecode(res.body); // langsung list!
      return data.map((e) => VideoModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load videos");
    }
  }

  static Future<bool> createVideo(String token, String link) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {"Authorization": "Bearer $token"},
      body: {"link": link},
    );

    return res.statusCode == 200 || res.statusCode == 201;
  }

  static Future<bool> deleteVideo(String token, int id) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/$id"),
      headers: {"Authorization": "Bearer $token"},
    );

    return res.statusCode == 200;
  }
}
