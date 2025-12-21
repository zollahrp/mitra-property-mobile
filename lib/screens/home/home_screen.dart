import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mitra_property/models/banner_model.dart';
import 'package:mitra_property/models/property_model.dart';
import 'package:mitra_property/models/video_model.dart';
import 'package:mitra_property/screens/detail/detail_property_screen.dart';
import 'package:mitra_property/screens/home/VideoPlayerScreen.dart';
import 'package:mitra_property/screens/home/filter_modal.dart';
import 'package:mitra_property/service/banner_service.dart';
import 'package:mitra_property/service/property_service.dart';
import 'package:mitra_property/service/saved_service.dart';
import 'package:mitra_property/service/video_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../routes/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mitra_property/utils/property_helper.dart';

enum BookmarkState { idle, loading }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class BookmarkButton extends StatefulWidget {
  final bool isSaved;
  final Future<bool> Function(bool wasSaved) onToggle;

  const BookmarkButton({
    super.key,
    required this.isSaved,
    required this.onToggle,
  });

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  BookmarkState state = BookmarkState.idle;

  Future<void> _handleTap() async {
    if (state == BookmarkState.loading) return;

    final wasSaved = widget.isSaved;

    setState(() => state = BookmarkState.loading);

    final success = await widget.onToggle(wasSaved);

    if (!mounted) return;

    setState(() => state = BookmarkState.idle);

    if (success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              wasSaved
                  ? "Property berhasil dihapus dari simpanan"
                  : "Property berhasil disimpan",
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text("Gagal memperbarui bookmark"),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: state == BookmarkState.loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation(Color(0xFF4A6CF7)),
                  ),
                )
              : Icon(
                  widget.isSaved ? Icons.bookmark : Icons.bookmark_border,
                  key: ValueKey(widget.isSaved),
                  size: 22,
                  color: widget.isSaved ? const Color(0xFF4A6CF7) : Colors.grey,
                ),
        ),
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  String username = "";
  String role = "";
  List<PropertyModel> properties = [];
  List<VideoModel> videos = [];
  bool isLoading = true;
  bool isLoadingVideos = true;

  Map<String, dynamic> activeFilters = {};
  List<PropertyModel> allProperties = [];

  TextEditingController searchCtrl = TextEditingController();

  final SavedService savedService = SavedService();
  Set<String> savedIds = {};
  bool isLoadingSaved = true;

  final BannerService _bannerService = BannerService();
  List<BannerModel> banners = [];
  bool isLoadingBanner = true;

  PageController _bannerController = PageController();
  int _currentBanner = 0;
  Timer? _bannerTimer;

  String getYoutubeId(String url) {
    try {
      // Hilangkan whitespace, dll
      url = url.trim();

      // Coba langsung extract via package bawaan
      final id = YoutubePlayer.convertUrlToId(url);
      if (id != null) return id;

      // Fallback manual
      Uri? uri = Uri.tryParse(url);
      if (uri == null) return "";

      // https://www.youtube.com/watch?v=abc123
      if (uri.queryParameters.containsKey("v")) {
        return uri.queryParameters["v"] ?? "";
      }

      // https://youtu.be/abc123?si=xxxxx
      if (uri.host.contains("youtu.be")) {
        final path = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : "";
        // Buang query (?si=xxx)
        return path.split("?").first;
      }
    } catch (e) {
      return "";
    }

    return "";
  }

  String getYoutubeThumbnail(String url) {
    final id = getYoutubeId(url);
    return "https://img.youtube.com/vi/$id/hqdefault.jpg";
  }

  @override
  void initState() {
    super.initState();
    fetchVideos();
    loadUsername();
    loadProperties();
    loadSaved();
    _initData();
    loadUserData();
    loadSavedIds();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    try {
      final result = await _bannerService.fetchBanners();

      setState(() {
        banners = result;
        isLoadingBanner = false;
      });

      if (banners.length > 1) {
        _startAutoSlide();
      }
    } catch (e) {
      isLoadingBanner = false;
      debugPrint('Error banner: $e');
    }
  }

  void _startAutoSlide() {
    _bannerTimer?.cancel();

    _bannerTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!mounted || banners.isEmpty) return;

      _currentBanner++;

      if (_currentBanner >= banners.length) {
        _currentBanner = 0;
      }

      _bannerController.animateToPage(
        _currentBanner,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> loadSavedIds() async {
    final ids = await savedService.getSavedIds();

    setState(() {
      savedIds = ids;
      isLoadingSaved = false;
    });
  }

  Future<void> _initData() async {
    await loadSaved(); // 🔥 TUNGGU DULU
    await loadProperties(); // baru load list
    fetchVideos();
    loadUsername();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? "";
      role = prefs.getString("role") ?? "user";
    });
  }

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITLE
              const Text(
                "Filter Pencarian",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Filter 1
              const Text("Tipe Listing"),
              const SizedBox(height: 8),
              Row(
                children: [
                  _filterChip("Dijual"),
                  const SizedBox(width: 8),
                  _filterChip("Disewa"),
                ],
              ),

              const SizedBox(height: 20),

              // Filter 2
              const Text("Jenis Properti"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _filterChip("Rumah"),
                  _filterChip("Apt"),
                  _filterChip("Ruko"),
                  _filterChip("Tanah"),
                ],
              ),

              const SizedBox(height: 30),

              // APPLY BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF4A6CF7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Terapkan Filter",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> fetchVideos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final result = await VideoService.getVideos(token);

      setState(() {
        videos = result;
        isLoadingVideos = false;
      });
    } catch (e) {
      print("Error saat fetch video: $e");
      setState(() {
        isLoadingVideos = false;
      });
    }
  }

  // Future<void> toggleSaved(String id) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   List<String> saved = prefs.getStringList("saved_properties") ?? [];

  //   if (saved.contains(id)) {
  //     saved.remove(id);
  //   } else {
  //     saved.add(id);
  //   }

  //   await prefs.setStringList("saved_properties", saved);

  //   setState(() {
  //     savedIds = saved.toSet(); // update UI
  //   });
  // }

  Future<void> _toggleBookmark(PropertyModel p) async {
    final id = p.id;
    final isSaved = savedIds.contains(id);

    if (savedIds.contains(id)) return;

    setState(() {
      savedIds.add(id);

      // 🔥 optimistic UI
      if (isSaved) {
        savedIds.remove(id);
      } else {
        savedIds.add(id);
      }
    });

    try {
      if (isSaved) {
        await savedService.removeSavedProperty(id);

        _showSnack("Property dihapus dari simpanan");
      } else {
        await savedService.saveProperty(id);

        _showSnack("Property berhasil disimpan");
      }
    } catch (e) {
      // ❌ rollback kalau gagal
      setState(() {
        if (isSaved) {
          savedIds.add(id);
        } else {
          savedIds.remove(id);
        }
      });

      _showSnack("Gagal menyimpan property");
      debugPrint("Bookmark error: $e");
    } finally {
      setState(() {
        savedIds.remove(id);
      });
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> loadSaved() async {
    try {
      final saved = await savedService.getSavedProperties();
      setState(() {
        savedIds = saved.map((e) => e.id).toSet();
      });
    } catch (e) {
      debugPrint("Load saved error: $e");
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
        allProperties = result; // Data mentah
        properties = List.from(allProperties); // Data yang akan difilter
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  void applyFilters(Map<String, dynamic> data) {
    setState(() {
      activeFilters = data;
    });

    filterProperties();
  }

  void filterProperties() {
    List<PropertyModel> filtered = List.from(allProperties);

    // Filter Tipe Listing: Jual / Sewa
    if (activeFilters["type"] != null) {
      filtered = filtered.where((p) {
        final listing = p.listingType?.toLowerCase() ?? "";
        return listing.contains(activeFilters["type"].toLowerCase());
      }).toList();
    }

    // Filter Jenis Properti
    if (activeFilters["propertyType"] != null) {
      filtered = filtered.where((p) {
        final type = p.propertyType?.toLowerCase() ?? "";
        return type.contains(activeFilters["propertyType"].toLowerCase());
      }).toList();
    }

    // Tambahkan filter lainnya nanti
    // uploader, sertifikat, luas tanah, sorting, kamar tidur, dsb

    setState(() {
      properties = filtered;
    });
  }

  String fixYoutubeUrl(String url) {
    if (url.startsWith("http")) return url;

    // Jika hanya "youtube.com"
    if (url.contains("youtube.com")) {
      return "https://$url";
    }

    // Kalau cuma ID video misal "dQw4w9WgXcQ"
    if (!url.contains("/")) {
      return "https://www.youtube.com/watch?v=$url";
    }

    return url;
  }

  void searchProperties(String query) {
    query = query.toLowerCase();

    setState(() {
      properties = allProperties.where((p) {
        final lokasi = (p.lokasi ?? "").toLowerCase();
        final tipe = (p.propertyType ?? "").toLowerCase();
        final jualsewa = (p.listingType ?? "").toLowerCase();
        final harga = (p.harga ?? "").toLowerCase();

        return lokasi.contains(query) ||
            tipe.contains(query) ||
            jualsewa.contains(query) ||
            harga.contains(query);
      }).toList();
    });
  }

  String shortenType(String type) {
    switch (type.toLowerCase()) {
      case "apartemen":
      case "apartment":
        return "Apt";
      case "rumah":
        return "Rumah";
      case "ruko":
        return "Ruko";
      case "kost":
        return "Kost";
      default:
        return type; // fallback biar aman
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
                        GestureDetector(
                          onTap: () async {
                            final result = await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              builder: (_) => const FilterModal(),
                            );

                            if (result != null) {
                              if (result["reset"] == true) {
                                setState(() {
                                  activeFilters = {}; // kosongkan filter
                                  properties = List.from(
                                    allProperties,
                                  ); // tampilkan semua data
                                });
                              } else {
                                applyFilters(result);
                              }
                            }
                          },
                          child: Container(
                            height: 48, // << SAMAIN DENGAN SEARCH BAR
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                14,
                              ), // << SAMAIN JUGA
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: const [
                                Text(
                                  "Filter",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF4A6CF7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.tune, color: Color(0xFF4A6CF7)),
                              ],
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
                                controller: searchCtrl,
                                onChanged: (value) {
                                  if (value.isEmpty) {
                                    setState(() {
                                      properties = List.from(allProperties);
                                    });
                                  } else {
                                    searchProperties(value);
                                  }
                                },
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
              SizedBox(
                height: 180,
                child: isLoadingBanner
                    ? const Center(child: CircularProgressIndicator())
                    : banners.isEmpty
                    ? Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          "Banner belum tersedia",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : PageView.builder(
                        controller: _bannerController,

                        itemCount: banners.length,
                        itemBuilder: (context, index) {
                          final banner = banners[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                banner.imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,

                                // 🔄 loading image
                                loadingBuilder: (c, child, p) {
                                  if (p == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },

                                // ❌ error image
                                errorBuilder: (c, e, s) {
                                  return Container(
                                    color: Colors.grey.shade300,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.broken_image,
                                      size: 40,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
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
                child: isLoadingVideos
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
                              final fixedUrl = fixYoutubeUrl(vid.link);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      VideoPlayerScreen(youtubeUrl: fixedUrl),
                                ),
                              );
                            },
                            child: Container(
                              width: 160,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    getYoutubeThumbnail(vid.link),
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
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio:
                            MediaQuery.of(context).size.width /
                            (MediaQuery.of(context).size.height * 0.85),
                      ),

                      itemBuilder: (context, index) {
                        final p = properties[index];
                        final isSaved = savedIds.contains(p.id);

                        // === FIX harga ===
                        final harga = int.tryParse(p.harga ?? "0") ?? 0;
                        final hargaFormat =
                            "Rp ${NumberFormat('#,###', 'id_ID').format(harga)}";

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailPropertyScreen(
                                  property: p,
                                  role: role,
                                ),
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
                                // ==== IMAGE + BOOKMARK ====
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                      child: _buildPropertyImage(
                                        p.foto.isNotEmpty
                                            ? p.foto.first.photoUrl
                                            : null,
                                      ),
                                    ),

                                    // ===== BOOKMARK ICON =====
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: BookmarkButton(
                                        isSaved: savedIds.contains(p.id),
                                        onToggle: (wasSaved) async {
                                          try {
                                            if (wasSaved) {
                                              await savedService
                                                  .removeSavedProperty(p.id);
                                            } else {
                                              await savedService.saveProperty(
                                                p.id,
                                              );
                                            }

                                            setState(() {
                                              if (wasSaved) {
                                                savedIds.remove(p.id);
                                              } else {
                                                savedIds.add(p.id);
                                              }
                                            });

                                            return true;
                                          } catch (e) {
                                            return false;
                                          }
                                        },
                                      ),
                                    ),
                                  ],
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
                                          _buildTagGrey(getListingLabel(p.listingType)),
                                          _buildTagBlue(
                                            shortenType(p.propertyType ?? ""),
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

  Widget _filterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label),
    );
  }

  Widget _buildPropertyList() {
    return SizedBox(
      height: 365,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : properties.isEmpty
          ? const Center(child: Text("Tidak ada property"))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 7),
              scrollDirection: Axis.horizontal,
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final p = properties[index];
                final isSaved = savedIds.contains(p.id);
                // final isSaving = savedIds.contains(p.id);

                // Convert harga → int → formatted
                final harga = int.tryParse(p.harga ?? "0") ?? 0;
                final hargaFormat =
                    "Rp ${NumberFormat('#,###', 'id_ID').format(harga)}";

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DetailPropertyScreen(property: p, role: role),
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
                              child: _buildPropertyImage(
                                p.foto.isNotEmpty
                                    ? p.foto.first.photoUrl
                                    : null,
                              ),
                            ),

                            // ===== BOOKMARK ICON =====
                            Positioned(
                              top: 12,
                              right: 12,
                              child: BookmarkButton(
                                isSaved: savedIds.contains(p.id),
                                onToggle: (wasSaved) async {
                                  try {
                                    if (wasSaved) {
                                      await savedService.removeSavedProperty(
                                        p.id,
                                      );
                                    } else {
                                      await savedService.saveProperty(p.id);
                                    }

                                    setState(() {
                                      if (wasSaved) {
                                        savedIds.remove(p.id);
                                      } else {
                                        savedIds.add(p.id);
                                      }
                                    });

                                    return true;
                                  } catch (e) {
                                    return false;
                                  }
                                },
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
                                  _buildTagGrey(getListingLabel(p.listingType)),
                                  const SizedBox(width: 6),
                                  _buildTagBlue(
                                    shortenType(p.propertyType ?? ""),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // PRICE (dinamis)
                              Text(
                                hargaFormat,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A6CF7),
                                ),
                              ),

                              const SizedBox(height: 4),

                              // TITLE (lokasi / nama)
                              Text(
                                p.lokasi ?? "-",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 4),

                              // LOCATION
                              Text(
                                p.lokasi ?? "Lokasi tidak tersedia",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
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
                                    child: GestureDetector(
                                      onTap: () async {
                                        final phone = "62811879603";
                                        final url = Uri.parse(
                                          "https://wa.me/$phone",
                                        );

                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(
                                            url,
                                            mode:
                                                LaunchMode.externalApplication,
                                          );
                                        }
                                      },
                                      child: Container(
                                        height: 42,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: Colors.green,
                                            width: 1.3,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(
                                              Icons.chat,
                                              color: Colors.green,
                                            ),
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

  Widget _buildPropertyImage(String? imageUrl) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Image.network(
        imageUrl ?? "",
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,

        // ===== LOADING STATE =====
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return Container(
            height: 150,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },

        // ===== ERROR / EMPTY =====
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/property_placeholder.png',
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
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

  // Widget _buildBanner() {
  //   if (isLoadingBanner) {
  //     return const SizedBox(
  //       height: 180,
  //       child: Center(child: CircularProgressIndicator()),
  //     );
  //   }

  //   if (banners.isEmpty) {
  //     return const SizedBox.shrink();
  //   }

  //   return Container(
  //     width: double.infinity,
  //     height: 180,
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(16),
  //       image: DecorationImage(
  //         image: NetworkImage(banners.first.imageUrl),
  //         fit: BoxFit.cover,
  //       ),
  //     ),
  //   );
  // }
}
