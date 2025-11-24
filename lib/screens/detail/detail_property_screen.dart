import 'package:flutter/material.dart';

class DetailPropertyScreen extends StatelessWidget {
  const DetailPropertyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),

      body: SafeArea(
        child: Stack(
          children: [
            // ================================
            // **TOP BACKGROUND IMAGE**
            // ================================
            SizedBox(
              width: double.infinity,
              height: 260,
              child: Image.asset(
                "assets/images/house.jpg", // GANTI sesuai project
                fit: BoxFit.cover,
              ),
            ),

            // ================================
            // **BACK + BOOKMARK ICON**
            // ================================
            Positioned(
              top: 15,
              left: 15,
              child: _iconCircle(
                Icons.arrow_back_rounded,
                () => Navigator.pop(context),
              ),
            ),

            Positioned(
              top: 15,
              right: 15,
              child: _iconCircle(
                Icons.bookmark_border_rounded,
                () {},
              ),
            ),

            // ================================
            // KONTEN UTAMA (PUTIH)
            // ================================
            Positioned(
              top: 220,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(26),
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =====================================
                    // SLIDER THUMBNAIL
                    // =====================================
                    SizedBox(
                      height: 65,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 6,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                Image.asset(
                                  "assets/images/house.jpg",
                                  width: 95,
                                  height: 65,
                                  fit: BoxFit.cover,
                                ),

                                // ITEM TERAKHIR ADA LABEL "10+"
                                if (index == 5)
                                  Container(
                                    width: 95,
                                    height: 65,
                                    color: Colors.black.withOpacity(0.4),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      "10+",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =====================================
                    // CATEGORY TAGS
                    // =====================================
                    Row(
                      children: [
                        _chip("Rumah", Colors.grey.shade200, Colors.black),
                        const SizedBox(width: 10),
                        _chip("Disewa", const Color(0xFF4A6CF7), Colors.white),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // =====================================
                    // HARGA
                    // =====================================
                    const Text(
                      "Rp. 650 Juta",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4A6CF7),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // =====================================
                    // TITLE PROPERTY
                    // =====================================
                    const Text(
                      "Lorem ipsum dolor sit amet\nLorem ipsum dolor sit",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E1E1E),
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // =====================================
                    // LOKASI
                    // =====================================
                    Text(
                      "Kota Bogor, Jawa Barat",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =====================================
                    // TYPE - FURNISH - CERTIFICATE
                    // =====================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        _infoColumn("Type", "Exclusive"),
                        _infoColumn("Furnish", "Semi Furnish"),
                        _infoColumn("Certificate", "SHM"),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // =====================================
                    // UPDATE DATE
                    // =====================================
                    Row(
                      children: const [
                        Icon(Icons.info_outline,
                            size: 16, color: Colors.grey),
                        SizedBox(width: 6),
                        Text(
                          "Diperbarui 13 September 2025 oleh Marketing 1",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ================================
            // BOTTOM BUTTONS
            // ================================
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
                color: Colors.white,
                child: Row(
                  children: [
                    // Button 1
                    Expanded(
                      child: _primaryButton(
                        "Ajukan Perhitungan Pajak",
                        Icons.calculate_rounded,
                        Colors.orange,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Button 2
                    Expanded(
                      child: _primaryButton(
                        "Ajukan Perhitungan KPR",
                        Icons.home_work_outlined,
                        const Color(0xFF4A6CF7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // WIDGET REUSABLE
  // ========================================

  Widget _iconCircle(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: Colors.black),
      ),
    );
  }

  Widget _chip(String text, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _primaryButton(String text, IconData icon, Color bg) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================
// INFO COLUMN
// ===============================
class _infoColumn extends StatelessWidget {
  final String title;
  final String value;

  const _infoColumn(this.title, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E1E1E),
          ),
        ),
      ],
    );
  }
}
