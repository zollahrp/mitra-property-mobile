import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mitra_property/models/property_model.dart';
import 'package:mitra_property/service/property_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mitra_property/service/saved_service.dart';

enum BookmarkState { idle, loading }

class DetailPropertyScreen extends StatefulWidget {
  final PropertyModel property;
  final String role; // ✅ SIMPAN ROLE

  const DetailPropertyScreen({
    super.key,
    required this.property,
    required this.role,
  });

  @override
  State<DetailPropertyScreen> createState() => _DetailPropertyScreenState();
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

class _DetailPropertyScreenState extends State<DetailPropertyScreen> {
  int currentIndex = 0;
  int visibleWordCount = 100;

  late final PageController _pageController;
  Timer? _autoSlideTimer;

  // List gambar dari assets
  // final List<String> images = [
  //   'assets/images/house.png',
  //   'assets/images/house.png',
  //   'assets/images/house.png',
  // ];
  late final List<PropertyPhoto> photos = widget.property.foto;
  // List<String> get images => widget.property.photos.map((e) => e.photoUrl).toList();

  String username = "";
  List<PropertyModel> properties = [];
  bool isLoading = true;
  Map<String, dynamic> activeFilters = {};
  List<PropertyModel> allProperties = [];
  bool isLoadingVideos = true;
  TextEditingController searchCtrl = TextEditingController();

  final SavedService savedService = SavedService();
  Set<String> savedIds = {};
  bool isLoadingSaved = true;

  String formatTanggal(String isoDate) {
    try {
      final date = DateTime.parse(
        isoDate.replaceFirst(RegExp(r':(\d{3})Z$'), '.\$1Z'),
      );

      const bulan = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "Mei",
        "Jun",
        "Jul",
        "Agu",
        "Sep",
        "Okt",
        "Nov",
        "Des",
      ];

      return "${date.day} ${bulan[date.month - 1]} ${date.year}";
    } catch (_) {
      return isoDate;
    }
  }

  //   bool isLoadingVideos = true;
  // List<VideoModel> videos = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _startAutoSlide();
    loadProperties();
    loadSavedProperties();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (!mounted) return;

      final total = widget.property.foto.length;
      if (total <= 1) return;

      final nextPage = (currentIndex + 1) % total;

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> loadSavedProperties() async {
    try {
      final ids = await savedService.getSavedIds();
      setState(() {
        savedIds = ids.toSet();
        isLoadingSaved = false;
      });
    } catch (e) {
      isLoadingSaved = false;
    }
  }

  String getDescriptionPreview(String text) {
    final words = text.split(RegExp(r'\s+'));

    if (words.length <= visibleWordCount) {
      return text;
    }

    return words.take(visibleWordCount).join(" ") + "...";
  }

  bool hasMoreWords(String text) {
    final words = text.split(RegExp(r'\s+'));
    return visibleWordCount < words.length;
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

  void openWhatsAppAdmin(String message) async {
    const adminPhone = "62811879603"; // FIXED
    final url = Uri.parse(
      "https://wa.me/$adminPhone?text=${Uri.encodeComponent(message)}",
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Tidak bisa membuka WhatsApp Admin");
    }
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

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Tidak bisa membuka WhatsApp Marketing");
    }
  }

  // void openWhatsApp(String message) async {
  //   final url = Uri.parse(
  //     "https://wa.me/62811879603?text=${Uri.encodeComponent(message)}",
  //   );

  //   if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
  //     throw Exception("Tidak bisa membuka WhatsApp");
  //   }
  // }

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(widget.property),
              _buildDetailInfo(widget.property),

              const SizedBox(height: 30),
              const Divider(height: 1),
              const SizedBox(height: 20),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Informasi Property",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _infoItem("Luas Tanah", "${widget.property.luasTanah} m²"),
                    _infoItem(
                      "Luas Bangunan",
                      "${widget.property.luasBangunan} m²",
                    ),
                    _infoItem("Kamar Tidur", "${widget.property.kamarTidur}"),
                    _infoItem("Kamar Mandi", "${widget.property.kamarMandi}"),
                    _infoItem("Dapur", "${widget.property.dapur}"),
                    _infoItem("Garasi", "${widget.property.garasi}"),
                    _infoItem("Carport", "${widget.property.carport}"),
                    _infoItem("Listrik", widget.property.listrik),
                    _infoItem("Air", widget.property.air),
                    _infoItem("Arah Bangunan", widget.property.hadap),
                    _infoItem("Sertifikat", widget.property.sertifikat),
                    _infoItem("Kondisi Furnitur", widget.property.furnish),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    // Garis atas 1
                    Divider(thickness: 1, color: Colors.grey.withOpacity(0.3)),

                    // Garis atas 2
                    Divider(thickness: 1, color: Colors.grey.withOpacity(0.3)),

                    const SizedBox(height: 14),

                    // ==== MARKETING PROFILE ====
                    Row(
                      children: [
                        // Foto
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage("assets/images/marketing.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Nama + role (DINAMIS)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Marketing",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "User ID: ${widget.property.userId.substring(0, 8)}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Garis bawah 1
                    Divider(thickness: 1, color: Colors.grey.withOpacity(0.3)),

                    // Garis bawah 2
                    Divider(thickness: 1, color: Colors.grey.withOpacity(0.3)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Rekomendasi Untukmu",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),

              SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: properties.length, // DINAMIS
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
                                  builder: (_) => DetailPropertyScreen(
                                    property: p,
                                    role: widget.role,
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
                                  // ==== IMAGE ====
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                        child: p.foto.isNotEmpty
                                            ? Image.network(
                                                p.foto.first.photoUrl,
                                                height: 120,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Image.asset(
                                                      "assets/images/house.png",
                                                      height: 120,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                    ),
                                              )
                                            : Image.asset(
                                                "assets/images/house.png",
                                                height: 120,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                      // ==== BOOKMARK ====
                                      Positioned(
                                        top: 8,
                                        right: 8,
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
                                                wasSaved
                                                    ? savedIds.remove(p.id)
                                                    : savedIds.add(p.id);
                                              });

                                              return true;
                                            } catch (_) {
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
                                        Row(
                                          children: [
                                            _buildTagGrey(
                                              (p.listingType ?? "") == "sell"
                                                  ? "Jual"
                                                  : "Sewa",
                                            ),
                                            const SizedBox(width: 6),
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

                                        // TITLE / NAMA PROPERTY
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
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // ===== BUTTON CALL =====
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final phone = widget.property.telepon.trim();

                          if (phone.isEmpty) return;

                          final fixedPhone = phone.startsWith("0")
                              ? phone.replaceFirst("0", "+62")
                              : phone.startsWith("+")
                              ? phone
                              : "+$phone";

                          final url = Uri.parse("tel:$fixedPhone");

                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF4A6CF7),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.phone,
                            color: Color(0xFF4A6CF7),
                            size: 26,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ===== BUTTON WHATSAPP =====
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // 🔢 FORMAT HARGA (PAKE TITIK)
                          final hargaInt =
                              int.tryParse(widget.property.harga ?? "0") ?? 0;
                          final hargaFormatted = NumberFormat(
                            '#,###',
                            'id_ID',
                          ).format(hargaInt);

                          openWhatsAppMarketing(
                            phone: widget.property.telepon,
                            message:
                                """
Halo 👋
Saya tertarik dengan properti berikut:

🏡 Nama Properti :
${widget.property.nama}

🆔 Kode Properti :
${widget.property.kode}

📍 Lokasi :
${widget.property.lokasi}

💰 Harga :
Rp $hargaFormatted

Mohon info lebih lanjut ya 🙏
Terima kasih
""",
                          );
                        },

                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.green, width: 1.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.message,
                                color: Colors.green,
                                size: 24,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Whatsapp",
                                style: TextStyle(
                                  fontSize: 16,
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
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================
  // HEADER SECTION
  // ===============================
  Widget _buildHeader(PropertyModel property) {
    final photos = property.foto; // list PropertyPhoto

    return Stack(
      children: [
        // ==== IMAGE CAROUSEL ====
        SizedBox(
          height: 320,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: photos.length,
            onPageChanged: (i) {
              setState(() => currentIndex = i);
            },
            itemBuilder: (context, index) {
              return Image.network(
                photos[index].photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Center(child: Icon(Icons.broken_image, size: 50)),
              );
            },
          ),
        ),

        // ==== BACK BUTTON ====
        Positioned(
          top: 16,
          left: 16,
          child: _circleButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
        ),

        // ==== BOOKMARK BTN ====
        Positioned(
          top: 16,
          right: 16,
          child: BookmarkButton(
            isSaved: savedIds.contains(widget.property.id),
            onToggle: (wasSaved) async {
              try {
                if (wasSaved) {
                  await savedService.removeSavedProperty(widget.property.id);
                } else {
                  await savedService.saveProperty(widget.property.id);
                }

                setState(() {
                  if (wasSaved) {
                    savedIds.remove(widget.property.id);
                  } else {
                    savedIds.add(widget.property.id);
                  }
                });

                return true;
              } catch (e) {
                return false;
              }
            },
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
              itemCount: photos.length + 1,
              itemBuilder: (context, index) {
                // Last item → "10+"
                if (index == photos.length) {
                  return _moreThumbnail(photos.length);
                }

                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
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
                        image: NetworkImage(photos[index].photoUrl),
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

  Widget _moreThumbnail(int total) {
    return Container(
      width: 60,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        "$total+",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildDetailInfo(PropertyModel property) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== TAGS =====
          Row(
            children: [
              _tagGrey(property.propertyType), // contoh: Rumah, Apartemen
              const SizedBox(width: 10),
              _tagBlue(property.listingType), // contoh: Disewa, Dijual
            ],
          ),

          const SizedBox(height: 12),

          // ===== PRICE =====
          Text(
            "Rp ${property.harga}",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4A6CF7),
            ),
          ),

          const SizedBox(height: 12),

          // ===== TITLE =====
          Text(
            property.nama,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 8),

          // ===== LOCATION =====
          Text(
            property.lokasi,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),

          const SizedBox(height: 10),

          // ===== STATS =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniStat(
                Icons.confirmation_number_outlined,
                "Kode",
                property.kode,
              ),
              _miniStat(
                Icons.visibility_outlined,
                "Views",
                property.views.toString(),
              ),
              _miniStat(
                Icons.ads_click_outlined,
                "Clicks",
                property.clicks.toString(),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ===== TYPE - FURNISH - CERTIFICATE =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _detailItem("Type", property.type ?? "-"),
              _detailItem("Furnish", property.furnish),
              _detailItem("Certificate", property.sertifikat),
            ],
          ),

          const SizedBox(height: 20),

          // ===== LAST UPDATED =====
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: Colors.black87),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Diperbarui ${formatTanggal(property.updatedAt)}",
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // ===== AJUKAN SECTION =====
          if (widget.role == "admin" || widget.role == "marketing") ...[
            const SizedBox(height: 20),

            // ===== AJUKAN SECTION =====
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final msg =
                          """
Halo, saya ingin mengajukan perhitungan pajak untuk properti berikut:

🏡 Nama: ${widget.property.nama}
📍 Lokasi: ${widget.property.lokasi}
💰 Harga: Rp ${widget.property.harga}
📄 ID Properti: ${widget.property.id}

Mohon bantuannya ya.
""";
                      openWhatsAppAdmin(msg);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE3B8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.receipt_long_outlined, size: 26),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "Ajukan\nPerhitungan Pajak",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final msg =
                          """
Halo, saya ingin mengajukan perhitungan KPR untuk properti berikut:

🏡 Nama: ${widget.property.nama}
📍 Lokasi: ${widget.property.lokasi}
💰 Harga: Rp ${widget.property.harga}
📄 ID Properti: ${widget.property.id}

Mohon informasi lebih lanjut terkait simulasi cicilan.
""";
                      openWhatsAppAdmin(msg);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A6CF7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.home_outlined,
                            size: 26,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Flexible(
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
                ),
              ],
            ),
          ],

          const SizedBox(height: 30),
          const Divider(height: 1),
          const SizedBox(height: 20),

          // ===== DESKRIPSI =====
          const Text(
            "Deskripsi",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 10),

          Text(
            getDescriptionPreview(property.deskripsi),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 10),

          if (hasMoreWords(property.deskripsi))
            GestureDetector(
              onTap: () {
                setState(() {
                  visibleWordCount += 100;
                });
              },
              child: const Text(
                "Baca Selengkapnya",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4A6CF7),
                  fontWeight: FontWeight.w600,
                ),
              ),
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
  //   Widget _moreThumbnail() {
  //     return Container(
  //       width: 60,
  //       margin: const EdgeInsets.only(right: 8),
  //       decoration: BoxDecoration(
  //         color: Colors.white.withOpacity(0.85),
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       child: const Center(
  //         child: Text(
  //           "10+",
  //           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  //         ),
  //       ),
  //     );
  //   }
  // }

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

  Widget _infoItem(String title, String value) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(height: 1, color: Colors.grey),
        const SizedBox(height: 14),
      ],
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

  Widget _miniStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
