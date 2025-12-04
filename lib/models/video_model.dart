class VideoModel {
  final String id;
  final String link;

  VideoModel({
    required this.id,
    required this.link,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'].toString(), // <-- penting
      link: json['link'] ?? '',
    );
  }
}
