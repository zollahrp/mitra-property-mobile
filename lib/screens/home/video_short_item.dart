import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoShortItem extends StatefulWidget {
  final String videoUrl;

  const VideoShortItem({
    super.key,
    required this.videoUrl,
  });

  @override
  State<VideoShortItem> createState() => _VideoShortItemState();
}

class _VideoShortItemState extends State<VideoShortItem> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    final videoId =
        YoutubePlayer.convertUrlToId(widget.videoUrl) ?? "";

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        hideControls: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
        ),
      ),
    );
  }
}
