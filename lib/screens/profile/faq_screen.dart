import 'package:flutter/material.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final ScrollController _scrollController = ScrollController();
  int? _expandedIndex;

  final List<Map<String, String>> faqs = [
    {
      "q": "Apa itu aplikasi Mitra Property?",
      "a":
          "Mitra Property adalah aplikasi web dan mobile yang digunakan untuk jual, beli, dan sewa properti seperti rumah, apartemen, dan tanah. Aplikasi ini bisa digunakan oleh agen properti maupun masyarakat umum yang ingin mencari atau memasarkan properti dengan lebih mudah.",
    },
    {
      "q":
          "Apakah masyarakat umum bisa menjual atau menyewakan properti di Mitra Property?",
      "a":
          "Ya, bisa. Mitra Property terbuka untuk semua orang. Pengguna umum dapat langsung memasang iklan properti mereka sendiri tanpa harus menjadi agen atau mitra resmi.",
    },
    {
      "q": "Jenis properti apa saja yang bisa dipasang di Mitra Property?",
      "a":
          "Berbagai jenis properti dapat dipasang di Mitra Property, seperti rumah, apartemen, tanah, maupun properti komersial lainnya, baik untuk dijual maupun disewakan.",
    },
    {
      "q":
          "Apakah Mitra Property hanya untuk jual beli atau juga melayani sewa?",
      "a":
          "Mitra Property melayani dua-duanya, yaitu jual dan sewa properti. Pengguna dapat dengan mudah mencari properti sesuai kebutuhan melalui fitur pencarian dan filter yang tersedia.",
    },
    {
      "q": "Bagaimana cara menghubungi pemilik atau penjual properti?",
      "a":
          "Setiap iklan properti sudah dilengkapi dengan informasi kontak pemilik atau penjual. Pengguna bisa langsung menghubungi mereka melalui fitur kontak yang tersedia di aplikasi.",
    },
  ];

  void _onExpand(int index) async {
    setState(() {
      _expandedIndex = _expandedIndex == index ? null : index;
    });

    await Future.delayed(const Duration(milliseconds: 200));

    // Auto scroll ke item yang dibuka
    _scrollController.animateTo(
      index * 140,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // ==== BACK BUTTON ====
              Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.15),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: Color(0xFF4A6CF7),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==== TITLE ====
              const Text(
                "Frequently Asked\nQuestions",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4A6CF7),
                ),
              ),

              const SizedBox(height: 26),

              // ==== FAQ LIST ====
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  bool isOpen = _expandedIndex == index;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // ==== HEADER ROW ====
                        GestureDetector(
                          onTap: () => _onExpand(index),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  faqs[index]["q"]!,
                                  maxLines: 3, // biar aman di layar kecil
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedRotation(
                                turns: isOpen ? 0.5 : 0,
                                duration: const Duration(milliseconds: 250),
                                child: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 26,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ==== EXPANDED CONTENT ====
                        AnimatedCrossFade(
                          firstChild: const SizedBox.shrink(),
                          secondChild: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              faqs[index]["a"]!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.4,
                              ),
                            ),
                          ),
                          crossFadeState: isOpen
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 250),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
