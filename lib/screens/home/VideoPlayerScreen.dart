import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String youtubeUrl;
  const VideoPlayerScreen({super.key, required this.youtubeUrl});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  late String videoId;

  @override
  void initState() {
    super.initState();

    // 🔒 LOCK PORTRAIT
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl) ?? "";

    if (videoId.isEmpty) {
      debugPrint("❌ INVALID YOUTUBE URL");
      return;
    }

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        disableDragSeek: false,
        hideControls: false,
        controlsVisibleAtStart: true,
        forceHD: true,

        // ❌ JANGAN FULLSCREEN
        enableCaption: false,
        isLive: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    // 🔓 BALIKIN ORIENTATION NORMAL
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (videoId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Video tidak dapat diputar")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // 🎬 VIDEO (CENTER + PORTRAIT)
            Center(
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.redAccent,
                  progressColors: const ProgressBarColors(
                    playedColor: Colors.red,
                    handleColor: Colors.redAccent,
                  ),
                ),
              ),
            ),

            // 🔙 BACK BUTTON (FLOATING)
            Positioned(
              top: 16,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
