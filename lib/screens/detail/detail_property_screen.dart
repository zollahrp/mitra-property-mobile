import 'package:flutter/material.dart';
import 'package:mitra_property/models/property_model.dart';

class DetailPropertyScreen extends StatefulWidget {
  final PropertyModel property;

  const DetailPropertyScreen({super.key, required this.property});

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
                    _infoItem("Land area", "200 Hectar"),
                    _infoItem("Building area", "200 m²"),
                    _infoItem("Bedrooms", "3"),
                    _infoItem("Extra rooms", "1"),
                    _infoItem("Garage", "1"),
                    _infoItem("Carport", "1"),
                    _infoItem("Kitchen", "1"),
                    _infoItem("Electricity", "2000 Watt"),
                    _infoItem("Direction", "Barat"),
                    _infoItem("Fee", "10 %"),
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
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage(
                                "assets/images/marketing.png",
                              ), // ganti sesuai asset
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Nama + role
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Marketing A",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Team Marketing Mitra Property",
                              style: TextStyle(
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
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      // onTap: () {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (_) => DetailPropertyScreen(
                      //         property: properties[index],
                      //       ),
                      //     ),
                      //   );
                      // },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.07),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // IMAGE
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: Image.asset(
                                'assets/images/property1.png',
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),

                            // CONTENT
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                12,
                                10,
                                12,
                                12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      _buildTagGrey('Jual'),
                                      SizedBox(width: 6),
                                      _buildTagBlue('Rumah'),
                                    ],
                                  ),

                                  SizedBox(height: 8),

                                  Text(
                                    'Rp. 650 Juta',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4A6CF7),
                                    ),
                                  ),

                                  SizedBox(height: 6),

                                  Text(
                                    'Lorem ipsum dolor sit amet\nLorem ipsum dolor sit',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      height: 1.25,
                                    ),
                                  ),

                                  SizedBox(height: 6),

                                  Text(
                                    'Kota Bogor, Jawa Barat',
                                    style: TextStyle(
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
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.green, width: 1.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.message, color: Colors.green, size: 24),
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
              _detailItem("Type", property.tipe ?? "-"),
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
                    children: const [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 26,
                        color: Colors.black87,
                      ),
                      SizedBox(width: 8),
                      Flexible(
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
                    children: const [
                      Icon(Icons.home_outlined, size: 26, color: Colors.white),
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
            ],
          ),

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
