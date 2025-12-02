import 'package:flutter/material.dart';
import 'package:mitra_property/models/property_model.dart';
import 'package:mitra_property/models/video_model.dart';
import 'package:mitra_property/screens/detail/detail_property_screen.dart';
import 'package:mitra_property/screens/home/VideoPlayerScreen.dart';
import 'package:mitra_property/service/property_service.dart';
import 'package:mitra_property/service/video_service.dart';
import '../../routes/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = "";
  List<PropertyModel> properties = [];
  List<VideoModel> videos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVideos();
    loadUsername();
    loadProperties();
  }

  Future<void> fetchVideos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      videos = await VideoService.getVideos(token);
    } catch (e) {
      print("Error saat fetch video: $e");
    }
  }

  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? "";
    });
  }

  Future<void> loadProperties() async {
    try {
      final result = await PropertyService.getApprovedProperties();
      setState(() {
        properties = result;
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==== HEADER + SEARCH WRAPPER ====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 30),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A6CF7), Color(0xFF6C8CFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(26),
                    bottomRight: Radius.circular(26),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ========== AVATAR + GREETING ==========
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/avatar.png',
                                width: 46,
                                height: 46,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $username',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              DateFormat(
                                'EEEE, d MMMM yyyy',
                              ).format(DateTime.now()),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ========== DROPDOWN + SEARCH ==========
                    Row(
                      children: [
                        // DROPDOWN CARD
                        SizedBox(
                          height: 48,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              // ← MAGIC FIX
                              child: DropdownButton<String>(
                                value: 'Dijual',
                                underline: const SizedBox(),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                ),
                                isExpanded: false,
                                isDense: true,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Dijual',
                                    child: Text('Dijual'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Disewa',
                                    child: Text('Disewa'),
                                  ),
                                ],
                                onChanged: (_) {},
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // SEARCH BAR CARD
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Cari Property...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: Colors.grey.shade600,
                                    size: 22,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==== Banner Promo ====
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/special_property.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ==== Rekomendasi Untukmu ====
              const Text(
                'Rekomendasi Untukmu',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildPropertyList(),

              const SizedBox(height: 30),

              // ==== Video Singkat Property ====
              const Text(
                'Video Singkat Property',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: MediaQuery.of(context).size.width * 0.65,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : videos.isEmpty
                    ? const Center(child: Text("Tidak ada video"))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: videos.length,
                        itemBuilder: (context, index) {
                          final vid = videos[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      VideoPlayerScreen(youtubeUrl: vid.link),
                                ),
                              );
                            },
                            child: Container(
                              width: 160,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: const DecorationImage(
                                  image: AssetImage(
                                    'assets/images/video_thumb.png',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 30),

              // ==== Property ====
              const Text(
                'Property',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: properties.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.6,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemBuilder: (context, index) {
                        final p = properties[index];

                        // === FIX harga ===
                        final harga = int.tryParse(p.harga ?? "0") ?? 0;
                        final hargaFormat =
                            "Rp ${NumberFormat('#,###', 'id_ID').format(harga)}";

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DetailPropertyScreen(property: p),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.07),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ==== IMAGE ====
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                  child: Image.network(
                                    p.foto.isNotEmpty
                                        ? p
                                              .foto
                                              .first
                                              .photoUrl // FIX: URL langsung
                                        : "https://via.placeholder.com/300",
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.network(
                                              "https://via.placeholder.com/300",
                                              height: 120,
                                              fit: BoxFit.cover,
                                            ),
                                  ),
                                ),

                                // ==== CONTENT ====
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    10,
                                    12,
                                    12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // TAGS
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          _buildTagGrey(
                                            (p.listingType ?? "") == "sell"
                                                ? "Jual"
                                                : "Sewa",
                                          ),
                                          _buildTagBlue(
                                            p.propertyType ?? "Properti",
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      // PRICE
                                      Text(
                                        hargaFormat,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4A6CF7),
                                        ),
                                      ),
                                      const SizedBox(height: 6),

                                      // TITLE (lokasi)
                                      Text(
                                        p.lokasi ?? "-",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      // LOCATION
                                      Text(
                                        p.lokasi ?? "Lokasi tidak tersedia",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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

  Widget _buildPropertyList() {
    return SizedBox(
      height: 365,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 7),
        // padding: const EdgeInsets.only(bottom: 0),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      DetailPropertyScreen(property: properties[index]),
                ),
              );
            },
            child: Container(
              width: 250,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==== IMAGE + BOOKMARK ====
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        child: Image.asset(
                          'assets/images/property1.png',
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                      // Bookmark icon
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(
                            Icons.bookmark_border,
                            color: Colors.grey,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ==== CONTENT ====
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TAGS
                        Row(
                          children: [
                            _buildTagGrey('Jual'),
                            const SizedBox(width: 6),
                            _buildTagBlue('Rumah'),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // PRICE
                        const Text(
                          'Rp. 650 Juta',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A6CF7),
                          ),
                        ),

                        const SizedBox(height: 4),

                        // TITLE
                        const Text(
                          'Lorem ipsum dolor sit amet',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // LOCATION
                        const Text(
                          'Kota Bogor, Jawa Barat',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),

                        const SizedBox(height: 14),

                        // ==== CALL + WHATSAPP BUTTONS ====
                        Row(
                          children: [
                            // CALL BUTTON
                            Expanded(
                              child: Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFF4A6CF7),
                                    width: 1.3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.phone,
                                  color: Color(0xFF4A6CF7),
                                  size: 22,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // WHATSAPP BUTTON
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.green,
                                    width: 1.3,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.chat, color: Colors.green),
                                    SizedBox(width: 6),
                                    Text(
                                      'Whatsapp',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTagGrey(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF7A7A7A),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTagBlue(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF4A6CF7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
