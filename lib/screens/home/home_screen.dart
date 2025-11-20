import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A6CF7), Color(0xFF6C8CFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // == AVATAR + GREETING ==
                    Row(
                      children: [
                        CircleAvatar(
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
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Hello, Jenny!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Monday, 12 April 2025',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // == DROPDOWN + SEARCH ==
                    Row(
                      children: [
                        // DROPDOWN
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButton<String>(
                            value: 'Dijual',
                            underline: const SizedBox(),
                            icon: const Icon(Icons.keyboard_arrow_down),
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

                        const SizedBox(width: 10),

                        // SEARCH BAR
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Cari Property',
                                hintStyle: const TextStyle(color: Colors.grey),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Colors.grey,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
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
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/video_thumb.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: const [
                          Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        ],
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
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  return Container(
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
                          child: Image.asset(
                            'assets/images/property1.png',
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
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
                                  _buildTagGrey('Jual'),
                                  const SizedBox(width: 6),
                                  _buildTagBlue('Rumah'),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // PRICE
                              const Text(
                                'Rp. 650 Juta',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A6CF7),
                                ),
                              ),

                              const SizedBox(height: 6),

                              // TITLE 2 lines
                              const Text(
                                'Lorem ipsum dolor sit amet\nLorem ipsum dolor sit',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                ),
                              ),

                              const SizedBox(height: 6),

                              // LOCATION
                              const Text(
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
          return Container(
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
          );
        },
      ),
    );
  }

  //   Widget _buildTag(String label) {
  //     return Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //       decoration: BoxDecoration(
  //         color: const Color(0xFFE8ECFF),
  //         borderRadius: BorderRadius.circular(6),
  //       ),
  //       child: Text(
  //         label,
  //         style: const TextStyle(
  //           color: Color(0xFF4A6CF7),
  //           fontSize: 11,
  //           fontWeight: FontWeight.w500,
  //         ),
  //       ),
  //     );
  //   }
  // }

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
