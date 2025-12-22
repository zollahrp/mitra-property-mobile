import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mitra_property/screens/home/video_short_item.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  final List videos;
  final int initialIndex;

  const VideoPlayerScreen({
    super.key,
    required this.videos,
    required this.initialIndex,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    // 🔒 LOCK PORTRAIT
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // === VIDEO SHORTS ===
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: widget.videos.length,
              itemBuilder: (context, index) {
                return VideoShortItem(videoUrl: widget.videos[index].link);
              },
            ),

            // === BACK BUTTON ===
            Positioned(top: 12, left: 12, child: _BackButton()),
          ],
        ),
      ),
    );
  }
}
