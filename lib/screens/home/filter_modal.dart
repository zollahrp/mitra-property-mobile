import 'package:flutter/material.dart';
import 'package:mitra_property/models/property_model.dart';

class FilterModal extends StatefulWidget {
  const FilterModal({super.key});

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  // ==== STATE ====
  String selectedSort = "";
  List<String> selectedTypes = [];
  List<String> selectedApprovals = [];
  final TextEditingController uploaderCtrl = TextEditingController();
  // SATUAN LUAS (meter/are/hektare)
  String selectedUnit = "";

  // KAMAR TIDUR
  List<String> selectedBedrooms = [];

  // KONDISI
  List<String> selectedConditions = [];

  // SERTIFIKAT
  List<String> selectedCertificates = [];

  // ==== LIST OPTIONS ====
  final List<String> sortOptions = [
    "Harga Terendah",
    "Harga Tertinggi",
    "Terbaru",
    "Luas Tanah Terluas",
    "Luas Bangunan Terluas",
  ];

  final TextEditingController landMinCtrl = TextEditingController();
  final TextEditingController landMaxCtrl = TextEditingController();
  final TextEditingController buildMinCtrl = TextEditingController();
  final TextEditingController buildMaxCtrl = TextEditingController();

  // Tambahan controller luas bangunan & tanah
  final TextEditingController buildingMinCtrl = TextEditingController();
  final TextEditingController buildingMaxCtrl = TextEditingController();

  final List<String> types = ["Dijual", "Disewa"];

  final List<String> approvals = ["Rumah", "Apartemen", "Ruko", "Tanah"];

  void resetAll() {
    selectedSort = "";
    selectedTypes = [];
    selectedApprovals = [];

    selectedUnit = "";
    selectedBedrooms = [];
    selectedConditions = [];
    selectedCertificates = [];

    uploaderCtrl.clear();
    landMinCtrl.clear();
    landMaxCtrl.clear();
    buildingMinCtrl.clear();
    buildingMaxCtrl.clear();

    setState(() {});
  }

  void _toggleType(String item) {
    setState(() {
      if (selectedTypes.contains(item)) {
        selectedTypes.remove(item);
      } else {
        selectedTypes.add(item);
      }
    });
  }

  void _toggleApproval(String item) {
    setState(() {
      if (selectedApprovals.contains(item)) {
        selectedApprovals.remove(item);
      } else {
        selectedApprovals.add(item);
      }
    });
  }

  void _toggleBedroom(String item) {
    setState(() {
      if (selectedBedrooms.contains(item)) {
        selectedBedrooms.remove(item);
      } else {
        selectedBedrooms.add(item);
      }
    });
  }

  void _toggleCondition(String item) {
    setState(() {
      if (selectedConditions.contains(item)) {
        selectedConditions.remove(item);
      } else {
        selectedConditions.add(item);
      }
    });
  }

  void _toggleCertificate(String item) {
    setState(() {
      if (selectedCertificates.contains(item)) {
        selectedCertificates.remove(item);
      } else {
        selectedCertificates.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.95,
      initialChildSize: 0.92,
      minChildSize: 0.5,
      builder: (context, controller) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            controller: controller,
            children: [
              const SizedBox(height: 16),

              // ==== HEADER BAR ====
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // JUDUL TENGAH
                    const Text(
                      "Filter",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A6CF7),
                      ),
                    ),

                    // TOMBOL CLOSE DI KANAN
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black.withOpacity(0.5),
                              width: 1.4,
                            ),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // GARIS PEMBATAS
              const SizedBox(height: 5),

              Container(height: 1.2, color: Colors.black.withOpacity(0.1)),

              const SizedBox(height: 20),

              // ==== URUTKAN ====
              const Text(
                "Urutkan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: sortOptions.map((item) {
                  bool active = selectedSort == item;
                  return _filterChip(
                    text: item,
                    active: active,
                    onTap: () => setState(() => selectedSort = item),
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),

              // ==== TIPE IKLAN ====
              const Text(
                "Tipe Iklan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              Row(
                children: types.map((item) {
                  bool active = selectedTypes.contains(item);
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _filterChip(
                      text: item,
                      active: active,
                      onTap: () => _toggleType(item),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),

              // ==== PERSETUJUAN ====
              const Text(
                "Jenis Properti",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: approvals.map((item) {
                  bool active = selectedApprovals.contains(item);
                  return _filterChip(
                    text: item,
                    active: active,
                    onTap: () => _toggleApproval(item),
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),

              // ==== NAMA PENUNGGAH ====
              const Text(
                "Nama Penungggah",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: uploaderCtrl,
                decoration: InputDecoration(
                  hintText: "Ketik disini",
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // Satuan Luas
              const Text(
                "Satuan Luas",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                children: ["meter", "are", "Hektare"].map((item) {
                  bool active = selectedUnit == item;
                  return _filterChip(
                    text: item,
                    active: active,
                    onTap: () => setState(() => selectedUnit = item),
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),

              // LUAS TANAH
              const Text(
                "Luas Tanah",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: _inputWithUnit("Minimal", landMinCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _inputWithUnit("Maksimal", landMaxCtrl)),
                ],
              ),

              const SizedBox(height: 22),

              // LUAS BANGUNAN
              const Text(
                "Luas Bangunan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: _inputWithUnit("Minimal", buildingMinCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _inputWithUnit("Maksimal", buildingMaxCtrl)),
                ],
              ),

              const SizedBox(height: 22),

              // KAMAR TIDUR
              const Text(
                "Kamar Tidur",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                "Pilih minimal kamar tidur",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: ["1", "2", "3", "4", "5+"].map((item) {
                  bool active = selectedBedrooms.contains(item);
                  return _filterChip(
                    text: "$item Kamar",
                    active: active,
                    onTap: () => _toggleBedroom(item),
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),

              // KONDISI
              const Text(
                "Kondisi",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                children: ["Furnished", "Semi Furnish", "Unfurnished"].map((
                  item,
                ) {
                  bool active = selectedConditions.contains(item);
                  return _filterChip(
                    text: item,
                    active: active,
                    onTap: () => _toggleCondition(item),
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),

              // SERTIFIKAT
              const Text(
                "Sertifikat",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                children: ["SHM", "SHGB", "PPJB"].map((item) {
                  bool active = selectedCertificates.contains(item);
                  return _filterChip(
                    text: item,
                    active: active,
                    onTap: () => _toggleCertificate(item),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              // GARIS PEMBATAS
              Container(height: 1.2, color: Colors.black.withOpacity(0.1)),

              const SizedBox(height: 20),

              // ==== APPLY & RESET BUTTONS ====
              Row(
                children: [
                  // RESET
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(
                          color: Color(0xFF4A6CF7),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        resetAll();

                        Navigator.pop(context, {
                          "reset": true,
                        });
                      },
                      child: const Text(
                        "Reset Filter",
                        style: TextStyle(
                          color: Color(0xFF4A6CF7),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // APPLY
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A6CF7),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, {
                          "sort": selectedSort.isEmpty ? null : selectedSort,
                          "type": selectedTypes.isEmpty
                              ? null
                              : selectedTypes.join(","),
                          "propertyType": selectedApprovals.isEmpty
                              ? null
                              : selectedApprovals.join(","),
                          "uploader": uploaderCtrl.text.isEmpty
                              ? null
                              : uploaderCtrl.text,
                          "unit": selectedUnit.isEmpty ? null : selectedUnit,
                          "bedroom": selectedBedrooms.isEmpty
                              ? null
                              : selectedBedrooms.join(","),
                          "condition": selectedConditions.isEmpty
                              ? null
                              : selectedConditions.join(","),
                          "certificate": selectedCertificates.isEmpty
                              ? null
                              : selectedCertificates.join(","),
                          "landMin": landMinCtrl.text.isEmpty
                              ? null
                              : landMinCtrl.text,
                          "landMax": landMaxCtrl.text.isEmpty
                              ? null
                              : landMaxCtrl.text,
                          "buildingMin": buildingMinCtrl.text.isEmpty
                              ? null
                              : buildingMinCtrl.text,
                          "buildingMax": buildingMaxCtrl.text.isEmpty
                              ? null
                              : buildingMaxCtrl.text,
                        });
                      },

                      child: const Text(
                        "Terapkan Filter",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  /// ===== CHIP BUILDER (ACTIVE / INACTIVE) =====
  Widget _filterChip({
    required String text,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF4A6CF7) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? const Color(0xFF4A6CF7) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: active ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _inputWithUnit(String hint, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: hint,
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF4A6CF7),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: const Text(
              "m²",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
