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
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../routes/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mitra_property/utils/property_helper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  String? photoUrl;
  String token = "";
  bool isLoadingPhoto = true;

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

  String formatTanggalIndo(DateTime date) {
    const hari = [
      "Senin",
      "Selasa",
      "Rabu",
      "Kamis",
      "Jumat",
      "Sabtu",
      "Minggu",
    ];

    const bulan = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];

    final namaHari = hari[date.weekday - 1]; // weekday: 1-7
    final namaBulan = bulan[date.month - 1]; // month: 1-12

    return "$namaHari, ${date.day} $namaBulan ${date.year}";
  }

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
    loadUserPhoto();
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
      isLoadingBanner = true;
      isLoadingVideos = true;
      isLoadingPhoto = true;
    });

    await Future.wait([
      loadProperties(),
      loadSaved(),
      loadSavedIds(),
      fetchVideos(),
      _loadBanners(),
      loadUserPhoto(),
      loadUsername(),
    ]);
  }

  Future<void> loadUserPhoto() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("id");
      final storedToken = prefs.getString("token");

      if (userId == null || storedToken == null) return;

      final response = await http.get(
        Uri.parse("https://api.mitrapropertysentul.com/users/photo/$userId"),
        headers: {
          "Authorization": "Bearer $storedToken",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          photoUrl = data["photo"];
          token = storedToken;
          isLoadingPhoto = false;
        });
      } else {
        isLoadingPhoto = false;
      }
    } catch (e) {
      isLoadingPhoto = false;
    }
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

  void openWhatsAppMarketing({required String phone, String? message}) async {
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nomor WhatsApp tidak tersedia")),
      );
      return;
    }

    final fixedPhone = phone.startsWith("62")
        ? phone
        : phone.startsWith("0")
        ? phone.replaceFirst("0", "62")
        : "62$phone";

    final url = Uri.parse(
      message == null
          ? "https://wa.me/$fixedPhone"
          : "https://wa.me/$fixedPhone?text=${Uri.encodeComponent(message)}",
    );

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void _openFilterSheet(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const FilterModal(),
    );

    if (result != null) {
      if (result["reset"] == true) {
        setState(() {
          activeFilters = {};
          isLoading = true;
        });
        await loadProperties();
      } else {
        await applyFilters(result);
      }
    }
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
        allProperties = result; // Data mentah untuk fallback
        properties = List.from(allProperties); // Data yang akan difilter
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  //Based on Views
  List<PropertyModel> getRecommendedProperties() {
    final List<PropertyModel> sorted = List.from(properties);

    // SORT DESCENDING BY VIEWS
    sorted.sort((a, b) {
      final viewsA = a.views ?? 0;
      final viewsB = b.views ?? 0;
      return viewsB.compareTo(viewsA);
    });

    // MAX 10 ITEM
    return sorted.take(10).toList();
  }

  // Based on Clicks
  // List<PropertyModel> getRecommendedProperties() {
  //   final List<PropertyModel> sorted = List.from(properties);

  //   // SORT DESCENDING BY CLICKS
  //   sorted.sort((a, b) {
  //     final clicksA = a.clicks ?? 0;
  //     final clicksB = b.clicks ?? 0;
  //     return clicksB.compareTo(clicksA);
  //   });

  //   // MAX 10 ITEM
  //   return sorted.take(10).toList();
  // }

  Future<void> applyFilters(Map<String, dynamic> data) async {
    setState(() {
      activeFilters = data;
      isLoading = true;
    });

    await filterProperties();
  }

  Future<void> filterProperties() async {
    try {
      // Ambil semua approved properties sebagai dasar filtering
      List<PropertyModel> filtered = await PropertyService.getApprovedProperties();

      print("📊 TOTAL PROPERTIES: ${filtered.length}");
      
      // DEBUG: Print sample data untuk cek field furnish dan listing_type
      if (filtered.isNotEmpty) {
        print("🔍 SAMPLE DATA (3 pertama):");
        for (var i = 0; i < filtered.length && i < 3; i++) {
          print("   [${i}] ${filtered[i].nama}");
          print("       - listing_type: '${filtered[i].listingType}'");
          print("       - furnish: '${filtered[i].furnish}'");
          print("       - property_type: '${filtered[i].propertyType}'");
        }
      }

      // ============================================
      // FILTER BERDASARKAN FIELD PROPERTY (Manual Filter)
      // ============================================

      // 1. FILTER BY PROPERTY TYPE (Rumah, Apartemen, Kavling)
      if (activeFilters["propertyType"] != null &&
          activeFilters["propertyType"].isNotEmpty) {
        final propertyType = activeFilters["propertyType"].toLowerCase();
        print("🏷️ Filter Property Type: $propertyType");
        filtered = filtered
            .where((p) {
              final type = p.propertyType.toLowerCase();
              print("   - ${p.nama}: type='$type', match=${type.contains(propertyType)}");
              return type.contains(propertyType);
            })
            .toList();
        print("✅ After Property Type filter: ${filtered.length}");
      }

      // 2. FILTER BY LISTING TYPE (Dijual/Disewa)
      if (activeFilters["type"] != null &&
          activeFilters["type"].isNotEmpty) {
        final selectedTypes = activeFilters["type"].toLowerCase().split(",").map((e) => e.trim()).toList();
        print("🏷️ Filter Listing Type: $selectedTypes");

        filtered = filtered
            .where((p) {
              final listingType = p.listingType.toLowerCase();

              // Database menggunakan: 'beli' dan 'sewa'
              bool match = false;

              for (var type in selectedTypes) {
                if (type == "dijual") {
                  if (listingType == "beli") {
                    match = true;
                    break;
                  }
                } else if (type == "disewa") {
                  if (listingType == "sewa") {
                    match = true;
                    break;
                  }
                }
              }

              print("   - ${p.nama}: listingType='$listingType', match=$match");
              return match;
            })
            .toList();
        print("✅ After Listing Type filter: ${filtered.length}");
      }

      // 3. FILTER BY FURNISH CONDITION (Furnished, Semi Furnished, Unfurnished)
      if (activeFilters["condition"] != null &&
          activeFilters["condition"].isNotEmpty) {
        final selectedConditions = activeFilters["condition"].toLowerCase().split(",").map((e) => e.trim()).toList();
        print("🏠 Filter Condition: $selectedConditions");

        filtered = filtered
            .where((p) {
              final furnish = p.furnish.toLowerCase().trim();
              print("   DEBUG: checking property '${p.nama}' - furnish raw='${p.furnish}', furnish processed='$furnish'");

              // Database menggunakan: 'furnish', 'semi_furnish', 'unfurnish'
              // UI mengirim: 'Furnished', 'Semi Furnish', 'Unfurnished'
              bool match = false;

              for (var condition in selectedConditions) {
                print("      - checking condition='$condition' vs furnish='$furnish'");
                // 'furnished' -> match dengan 'furnish'
                if (condition == "furnished") {
                  if (furnish == "furnish") {
                    match = true;
                    print("      - MATCH! furnished == furnish");
                    break;
                  }
                } 
                // 'semi furnish' -> match dengan 'semi_furnish' atau 'semi furnish'
                else if (condition == "semi furnish") {
                  if (furnish == "semi_furnish" || furnish == "semi furnish" || furnish.contains("semi")) {
                    match = true;
                    print("      - MATCH! semi furnish");
                    break;
                  }
                } 
                // 'unfurnished' -> match dengan 'unfurnish'
                else if (condition == "unfurnished") {
                  if (furnish == "unfurnish") {
                    match = true;
                    print("      - MATCH! unfurnished == unfurnish");
                    break;
                  }
                }
              }

              print("   - ${p.nama}: furnish='$furnish', match=$match");
              return match;
            })
            .toList();
        print("✅ After Condition filter: ${filtered.length}");
      }

      // 4. FILTER BY CERTIFICATE (SHM, SHGB, PPJB)
      if (activeFilters["certificate"] != null &&
          activeFilters["certificate"].isNotEmpty) {
        final certificates = activeFilters["certificate"].toUpperCase();
        print("📜 Filter Certificate: $certificates");
        filtered = filtered
            .where((p) {
              final cert = p.sertifikat.toUpperCase();
              bool match = false;
              if (certificates.contains("SHM") && !certificates.contains("SHGB") && !certificates.contains("PPJB")) {
                match = cert.contains("SHM") || cert.contains("HAK MILIK");
              } else if (certificates.contains("SHGB")) {
                match = cert.contains("SHGB") || cert.contains("HAK GUNA BANGUNAN");
              } else if (certificates.contains("PPJB")) {
                match = cert.contains("PPJB");
              }
              print("   - ${p.nama}: cert='$cert', match=$match");
              return match;
            })
            .toList();
        print("✅ After Certificate filter: ${filtered.length}");
      }

      // 5. FILTER BY SORTING
      if (activeFilters["sort"] != null && activeFilters["sort"].isNotEmpty) {
        final sort = activeFilters["sort"].toLowerCase();
        print("📊 Sorting: $sort");

        if (sort.contains("harga terendah")) {
          filtered.sort((a, b) {
            final priceA = double.tryParse(a.harga.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
            final priceB = double.tryParse(b.harga.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
            return priceA.compareTo(priceB);
          });
        } else if (sort.contains("harga tertinggi")) {
          filtered.sort((a, b) {
            final priceA = double.tryParse(a.harga.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
            final priceB = double.tryParse(b.harga.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
            return priceB.compareTo(priceA);
          });
        }
        print("✅ After Sorting: ${filtered.length}");
      }

      // ============================================
      // FILTER MANUAL (untuk kriteria yang tidak ada endpoint API)
      // ============================================

      // Filter by Luas Tanah Min
      if (activeFilters["landMin"] != null &&
          activeFilters["landMin"].isNotEmpty) {
        final minLand = double.tryParse(activeFilters["landMin"]) ?? 0;
        filtered = filtered
            .where((p) {
              final land = double.tryParse(p.luasTanah) ?? 0;
              return land >= minLand;
            })
            .toList();
      }

      // Filter by Luas Tanah Max
      if (activeFilters["landMax"] != null &&
          activeFilters["landMax"].isNotEmpty) {
        final maxLand = double.tryParse(activeFilters["landMax"]) ?? 0;
        filtered = filtered
            .where((p) {
              final land = double.tryParse(p.luasTanah) ?? 0;
              return land <= maxLand;
            })
            .toList();
      }

      // Filter by Luas Bangunan Min
      if (activeFilters["buildingMin"] != null &&
          activeFilters["buildingMin"].isNotEmpty) {
        final minBuild = double.tryParse(activeFilters["buildingMin"]) ?? 0;
        filtered = filtered
            .where((p) {
              final build = double.tryParse(p.luasBangunan) ?? 0;
              return build >= minBuild;
            })
            .toList();
      }

      // Filter by Luas Bangunan Max
      if (activeFilters["buildingMax"] != null &&
          activeFilters["buildingMax"].isNotEmpty) {
        final maxBuild = double.tryParse(activeFilters["buildingMax"]) ?? 0;
        filtered = filtered
            .where((p) {
              final build = double.tryParse(p.luasBangunan) ?? 0;
              return build <= maxBuild;
            })
            .toList();
      }

      // Filter by Kamar Tidur
      if (activeFilters["bedroom"] != null &&
          activeFilters["bedroom"].isNotEmpty) {
        final bedrooms = activeFilters["bedroom"] as String;
        filtered = filtered
            .where((p) {
              for (var bed in bedrooms.split(",")) {
                final bedNum = int.tryParse(bed.trim());
                if (bedNum != null && p.kamarTidur >= bedNum) {
                  return true;
                }
                if (bed.trim() == "5+" && p.kamarTidur >= 5) {
                  return true;
                }
              }
              return false;
            })
            .toList();
      }

      print("🎉 FINAL RESULT: ${filtered.length} properties");

      setState(() {
        properties = filtered;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error filtering properties: $e");
      setState(() async {
        isLoading = false;
        properties = await PropertyService.getApprovedProperties();
      });
    }
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
        final nama = (p.nama ?? "").toLowerCase();
        final lokasi = (p.lokasi ?? "").toLowerCase();

        // Cari berdasarkan nama ATAU lokasi (fallback)
        return nama.contains(query) || lokasi.contains(query);
      }).toList();
    });
    
    debugPrint("Search query: $query, Found: ${properties.length} properties");
  }

  String shortenType(String type) {
    switch (type.toLowerCase()) {
      case "apartemen":
      case "apartment":
        return "Apt";
      case "rumah":
        return "Rumah";
      case "kavling":
      case "tanah":
        return "Kavling";
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
        // top: false,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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
                                child: ClipOval(
                                  child: isLoadingPhoto
                                      ? Shimmer.fromColors(
                                          baseColor: Colors.grey.shade300,
                                          highlightColor: Colors.grey.shade100,
                                          child: Container(
                                            width: 46,
                                            height: 46,
                                            decoration: const BoxDecoration(
                                              color: Colors.grey,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                      : Image.network(
                                          photoUrl ?? "",
                                          width: 46,
                                          height: 46,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Image.asset(
                                                  'assets/images/avatar.png',
                                                  width: 46,
                                                  height: 46,
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                        ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hai, $username',
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                formatTanggalIndo(DateTime.now()),
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
                                builder: (_) => FilterModal(
                                  initialFilters: activeFilters.isEmpty ? null : activeFilters,
                                ),
                              );

                              if (result != null) {
                                if (result["reset"] == true) {
                                  setState(() {
                                    activeFilters = {};
                                    isLoading = true;
                                  });
                                  await loadProperties();
                                } else {
                                  await applyFilters(result);
                                }
                              }
                            },
                            child: Container(
                              height: 48, // << SAMAIN DENGAN SEARCH BAR
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
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
                                  textAlignVertical: TextAlignVertical.center,
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
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        )
                      : PageView.builder(
                          controller: _bannerController,

                          itemCount: banners.length,
                          itemBuilder: (context, index) {
                            final banner = banners[index];

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
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
                  height: 260, // tinggi list shorts
                  child: isLoadingVideos
                      ? const Center(child: CircularProgressIndicator())
                      : videos.isEmpty
                      ? const Center(child: Text("Tidak ada video"))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          cacheExtent: 500,
                          itemCount: videos.length,
                          itemBuilder: (context, index) {
                            final vid = videos[index];

                            return GestureDetector(
                              onTap: () {
                                final fixedUrl = fixYoutubeUrl(vid.link);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => VideoPlayerScreen(
                                      videos: videos,
                                      initialIndex: index,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 150, // ramping ala Shorts
                                margin: const EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      // === THUMBNAIL ===
                                      AspectRatio(
                                        aspectRatio: 9 / 16, // 🔥 SHORTS RATIO
                                        child: Image.network(
                                          getYoutubeThumbnail(vid.link),
                                          fit: BoxFit.cover,
                                        ),
                                      ),

                                      // === GRADIENT OVERLAY ===
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.45),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),

                                      // === PLAY ICON ===
                                      const Center(
                                        child: Icon(
                                          Icons.play_circle_fill,
                                          color: Colors.white,
                                          size: 48,
                                        ),
                                      ),
                                    ],
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
                    ? GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 6,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio:
                              MediaQuery.of(context).size.width /
                              (MediaQuery.of(context).size.height * 0.85),
                        ),
                        itemBuilder: (_, __) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: 120,
                                    decoration: const BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 14,
                                          width: 80,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          height: 12,
                                          width: 120,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          height: 12,
                                          width: double.infinity,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
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
                              (MediaQuery.of(context).size.height * 0.95),
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
                                  builder: (_) => DetailPropertyScreen(property: p),
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
                                  Expanded(
                                    child: Padding(
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
                                                getListingLabel(p.listingType),
                                              ),
                                              _buildTagBlue(
                                                shortenType(
                                                  p.propertyType ?? "",
                                                ),
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

                                          // NAME
                                          Text(
                                            p.nama ?? "-",
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
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
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
                        },
                      ),

                // Jarak di bawah card Property
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  

  Widget _buildPropertyList() {
    final recommended = getRecommendedProperties();
    return SizedBox(
      height: 400,
      child: isLoading
          ? ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (_, __) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                );
              },
            )
          : properties.isEmpty
          ? const Center(child: Text("Tidak ada property"))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 7),
              scrollDirection: Axis.horizontal,
              itemCount: recommended.length,
              itemBuilder: (context, index) {
                final p = recommended[index];
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
                            DetailPropertyScreen(property: p),
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
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // TAGS
                                Row(
                                  children: [
                                    _buildTagGrey(
                                      getListingLabel(p.listingType),
                                    ),
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

                                // NAME
                                Text(
                                  p.nama ?? "-",
                                  maxLines: 2,
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
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                // DESCRIPTION
                                Text(
                                  p.deskripsi ?? "",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    height: 1.3,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // ==== CALL + WHATSAPP BUTTONS ====
                                
                                Row(
                                  children: [                                   
                                    // CALL BUTTON
                                    Expanded(                                     
                                      child: GestureDetector(
                                        onTap: () async {
                                          final fixedPhone =
                                              p.telepon.startsWith("0")
                                              ? p.telepon.replaceFirst(
                                                  "0",
                                                  "+62",
                                                )
                                              : "+${p.telepon}";

                                          final url = Uri.parse(
                                            "tel:$fixedPhone",
                                          );
                                          await launchUrl(url);
                                        },
                                        child: Container(
                                          height: 38,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFF4A6CF7),
                                              width: 1.3,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.phone,
                                            color: Color(0xFF4A6CF7),
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    // WHATSAPP BUTTON
                                    Expanded(
                                      flex: 2,
                                      child: GestureDetector(
                                        onTap: () async {
                                          // 1️⃣ FORMAT HARGA
                                          final hargaInt =
                                              int.tryParse(p.harga ?? "0") ?? 0;
                                          final hargaFormatted = NumberFormat(
                                            '#,###',
                                            'id_ID',
                                          ).format(hargaInt);

                                          // 2️⃣ ISI PESAN
                                          final message =
                                              """
Halo 👋
Saya tertarik dengan properti berikut:

🏡 Nama Properti :
${p.nama}

🆔 Kode Properti :
${p.kode}

📍 Lokasi :
${p.lokasi}

💰 Harga :
Rp $hargaFormatted

Mohon info lebih lanjut ya 🙏
Terima kasih
""";

                                          // 3️⃣ ENCODE & KIRIM KE WA
                                          final encodedMessage =
                                              Uri.encodeComponent(message);
                                          final phone = p.telepon;
                                          final url = Uri.parse(
                                            "https://wa.me/$phone?text=$encodedMessage",
                                          );

                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(
                                              url,
                                              mode: LaunchMode
                                                  .externalApplication,
                                            );
                                          }
                                        },
                                        child: Container(
                                          height: 38,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
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
                                                size: 18,
                                              ),
                                              SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  'Whatsapp',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
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
