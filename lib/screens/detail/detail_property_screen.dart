import 'package:flutter/material.dart';

class DetailPropertyScreen extends StatefulWidget {
  const DetailPropertyScreen({super.key});

  @override
  State<DetailPropertyScreen> createState() => _DetailPropertyScreenState();
}

class _DetailPropertyScreenState extends State<DetailPropertyScreen> {
  int currentIndex = 0;

  // List gambar dari assets
  final List<String> images = [
    'assets/images/house.png',
    'assets/images/house.png',
    'assets/images/house.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
          ],
        ),
      ),
    );
  }

  // ===============================
  // HEADER SECTION
  // ===============================
  Widget _buildHeader() {
    return Stack(
      children: [
        // ==== IMAGE CAROUSEL ====
        SizedBox(
          height: 320,
          width: double.infinity,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (i) => setState(() => currentIndex = i),
            itemBuilder: (context, index) {
              return Image.asset(
                images[index],
                fit: BoxFit.cover,
              );
            },
          ),
        ),

        // ==== BACK + BOOKMARK BUTTON ====
        Positioned(
          top: 16,
          left: 16,
          child: _circleButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: _circleButton(
            icon: Icons.bookmark_border,
            onTap: () {},
          ),
        ),

        // ==== THUMBNAIL BAR ====
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 70,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              scrollDirection: Axis.horizontal,
              itemCount: images.length + 1,
              itemBuilder: (context, index) {
                // Last item → "10+"
                if (index == images.length) {
                  return _moreThumbnail();
                }

                return GestureDetector(
                  onTap: () {
                    setState(() => currentIndex = index);
                  },
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: currentIndex == index
                            ? Colors.white
                            : Colors.transparent,
                        width: 2,
                      ),
                      image: DecorationImage(
                        image: AssetImage(images[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // Circle button reusable
  Widget _circleButton({required IconData icon, required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22, color: Colors.black87),
      ),
    );
  }

  // Thumbnail "10+"
  Widget _moreThumbnail() {
    return Container(
      width: 60,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Text(
          "10+",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
