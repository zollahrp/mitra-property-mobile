import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mitra_property/models/property_model.dart';
import 'package:mitra_property/service/property_service.dart';
import 'package:url_launcher/url_launcher.dart';

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

class _DetailPropertyScreenState extends State<DetailPropertyScreen> {
  int currentIndex = 0;

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
  
  //   bool isLoadingVideos = true;
  // List<VideoModel> videos = [];

  @override
  void initState() {
    super.initState();
    loadProperties();
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

  void openWhatsApp(String message) async {
    final url = Uri.parse(
      "https://wa.me/62811879603?text=${Uri.encodeComponent(message)}",
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Tidak bisa membuka WhatsApp");
    }
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
                    _infoItem("Land Area", "${widget.property.luasTanah} m²"),
                    _infoItem(
                      "Building Area",
                      "${widget.property.luasBangunan} m²",
                    ),
                    _infoItem("Bedrooms", "${widget.property.kamarTidur}"),
                    _infoItem("Bathrooms", "${widget.property.kamarMandi}"),
                    _infoItem("Kitchen", "${widget.property.dapur}"),
                    _infoItem("Garage", "${widget.property.garasi}"),
                    _infoItem("Carport", "${widget.property.carport}"),
                    _infoItem("Electricity", widget.property.listrik),
                    _infoItem("Water", widget.property.air),
                    _infoItem("Direction", widget.property.hadap),
                    _infoItem("Certificate", widget.property.sertifikat),
                    _infoItem("Furnish", widget.property.furnish),
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
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                    child: Image.network(
                                      p.foto.isNotEmpty
                                          ? p.foto.first.photoUrl
                                          : "https://via.placeholder.com/300",
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
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
                    Container(
                      width: 70,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.blue, width: 1.5),
                      ),
                      child: Icon(Icons.phone, color: Colors.blue, size: 26),
                    ),

                    const SizedBox(width: 12),

                    // ===== BUTTON WHATSAPP =====
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final phone = "62811879603";
                          final url = Uri.parse("https://wa.me/$phone");

                          if (await canLaunchUrl(url)) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          }
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
            itemCount: photos.length,
            onPageChanged: (i) => setState(() => currentIndex = i),
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
              itemCount: photos.length + 1,
              itemBuilder: (context, index) {
                // Last item → "10+"
                if (index == photos.length) {
                  return _moreThumbnail(photos.length);
                }

                return GestureDetector(
                  onTap: () => setState(() => currentIndex = index),
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
                  "Diperbarui ${property.updatedAt}",
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

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
                      openWhatsApp(msg);
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
                      openWhatsApp(msg);
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
            property.deskripsi,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.45,
            ),
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
}
