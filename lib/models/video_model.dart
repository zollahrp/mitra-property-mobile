class VideoModel {
  final int id;
  final String link;

  VideoModel({
    required this.id,
    required this.link,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'],
      link: json['link'],
    );
  }
}
