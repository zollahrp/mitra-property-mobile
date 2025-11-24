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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildDetailInfo(), // ⬅️ TAMBAH INI
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
              return Image.asset(images[index], fit: BoxFit.cover);
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
          child: _circleButton(icon: Icons.bookmark_border, onTap: () {}),
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

  Widget _buildDetailInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TAGS
          Row(
            children: [
              _tagGrey("Rumah"),
              const SizedBox(width: 10),
              _tagBlue("Disewa"),
            ],
          ),

          const SizedBox(height: 12),

          // PRICE
          const Text(
            "Rp. 650 Juta",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4A6CF7),
            ),
          ),

          const SizedBox(height: 12),

          // TITLE
          const Text(
            "Lorem ipsum dolor sit amet\nLorem ipsum dolor sit",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 8),

          // LOCATION
          const Text(
            "Kota Bogor, Jawa Barat",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),

          const SizedBox(height: 20),

          // TYPE - FURNISH - CERTIFICATE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _detailItem("Type", "Exclusive"),
              _detailItem("Furnish", "Semi Furnish"),
              _detailItem("Certificate", "SHM"),
            ],
          ),

          const SizedBox(height: 20),

          // LAST UPDATED
          Row(
            children: const [
              Icon(Icons.access_time, size: 18, color: Colors.black87),
              SizedBox(width: 6),
              Text(
                "Diperbarui 13 September 2025 oleh Marketing 1",
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ===========================
          //  AJUKAN PERHITUNGAN SECTION
          // ===========================
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE3B8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined, // icon pajak / dokumen
                        size: 26,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 8),
                      const Flexible(
                        child: Text(
                          "Ajukan\nPerhitungan Pajak",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A6CF7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.home_outlined, // bebas mau ganti icon
                        size: 26,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      const Flexible(
                        child: Text(
                          "Ajukan\nPerhitungan KPR",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
          const Divider(height: 1),
          const SizedBox(height: 20),

          // ===========================
          //  DESKRIPSI SECTION
          // ===========================
          const Text(
            "Deskripsi",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 10),

          const Text(
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, "
            "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
            "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi "
            "ut aliquip ex ea commodo consequat. Duis aute irure dolor in "
            "reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. "
            "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia "
            "deserunt mollit anim id est laborum",
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.45),
          ),

          const SizedBox(height: 10),

          Row(
            children: const [
              Text(
                "Muat Lebih Banyak",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4A6CF7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 6),
              Icon(Icons.keyboard_arrow_down, color: Color(0xFF4A6CF7)),
            ],
          ),
        ],
      ),
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}

Widget _tagGrey(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFEDEDED),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 12, color: Color(0xFF7A7A7A)),
    ),
  );
}

Widget _tagBlue(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFF4A6CF7),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

Widget _detailItem(String title, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF4A6CF7),
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 13, color: Colors.black)),
    ],
  );
}
