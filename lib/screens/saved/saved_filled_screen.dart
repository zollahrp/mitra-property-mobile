import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mitra_property/service/saved_service.dart';

import '../../models/property_model.dart';

class SavedFilledScreen extends StatefulWidget {
  const SavedFilledScreen({super.key});

  @override
  State<SavedFilledScreen> createState() => _SavedFilledScreenState();
}

class _SavedFilledScreenState extends State<SavedFilledScreen> {
  final SavedService savedService = SavedService();

  List<PropertyModel> savedProperties = [];
  bool isLoading = true;
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 🔥 reload setiap kali screen muncul
    if (!_hasLoaded) {
      _hasLoaded = true;
      loadSavedProperties();
    }
  }

  Future<void> loadSavedProperties() async {
    setState(() => isLoading = true);

    try {
      final res = await savedService.getSavedProperties();
      debugPrint("Saved properties count: ${res.length}");

      setState(() {
        savedProperties = res;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error load saved properties: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==== TITLE ====
              const Center(
                child: Text(
                  "Disimpan",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==== SEARCH BAR ====
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF4A6CF7),
                    width: 1.2,
                  ),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Cari Property",
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==== CONTENT ====
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : savedProperties.isEmpty
                        ? const Center(
                            child: Text("Belum ada property disimpan"),
                          )
                        : RefreshIndicator(
                            onRefresh: loadSavedProperties,
                            child: GridView.builder(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              itemCount: savedProperties.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.64,
                              ),
                              itemBuilder: (context, index) {
                                return _buildSavedCard(
                                  savedProperties[index],
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================
  // CARD PROPERTY (Grid)
  // ================================
  Widget _buildSavedCard(PropertyModel p) {
    final harga = int.tryParse(p.harga ?? "0") ?? 0;
    final hargaFormat =
        "Rp ${NumberFormat('#,###', 'id_ID').format(harga)}";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
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
                child: Image.network(
                  p.foto.isNotEmpty ? p.foto.first.photoUrl : "",
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      height: 120,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, size: 40),
                    );
                  },
                ),
              ),

              // BOOKMARK ICON
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.bookmark,
                    size: 22,
                    color: Color(0xFF4A6CF7),
                  ),
                ),
              )
            ],
          ),

          // ==== CONTENT ====
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TAGS
                Row(
                  children: [
                    _buildTagGrey(
                      p.listingType == "sell" ? "Jual" : "Sewa",
                    ),
                    const SizedBox(width: 6),
                    _buildTagBlue(p.propertyType),
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

                // TITLE
                Text(
                  p.nama,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 6),

                // LOCATION
                Text(
                  p.lokasi,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // TAG GREY
  Widget _buildTagGrey(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF7A7A7A),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // TAG BLUE
  Widget _buildTagBlue(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF4A6CF7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
