import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String youtubeUrl;
  const VideoPlayerScreen({super.key, required this.youtubeUrl});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  YoutubePlayerController? _controller;
  String? videoId;

  @override
  void initState() {
    super.initState();

    videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl);

    if (videoId == null || videoId!.isEmpty) {
      print("❌ VIDEO ID NOT VALID FROM URL: ${widget.youtubeUrl}");
      return;
    }

    _controller = YoutubePlayerController(
      initialVideoId: videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (videoId == null || videoId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Video Player")),
        body: const Center(
          child: Text(
            "Video tidak dapat diputar.\nURL YouTube tidak valid.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Video Player")),
      body: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
      ),
    );
  }
}
