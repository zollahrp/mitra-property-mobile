import 'package:flutter/material.dart';
import 'package:mitra_property/models/property_model.dart';

class FilterModal extends StatefulWidget {
  const FilterModal({super.key});

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  // ==== STATE ====
  String selectedSort = "Harga Terendah";
  String selectedType = "Disewa";
  String selectedApproval = "Kavling";
  final TextEditingController uploaderCtrl = TextEditingController();
  // SATUAN LUAS (meter/are/hektare)
  String selectedUnit = "meter";

  // KAMAR TIDUR
  String selectedBedroom = "1 Kamar";

  // KONDISI
  String selectedCondition = "Furnished";

  // SERTIFIKAT
  String selectedCertificate = "SHM";

  // ==== LIST OPTIONS ====
  final List<String> sortOptions = [
    "Rekomendasi",
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

  final List<String> approvals = ["Rumah", "Apartemen", "Kavling"];

  void resetAll() {
    selectedSort = "Harga Terendah";
    selectedType = "Disewa";
    selectedApproval = "Kavling";

    selectedUnit = "meter";
    selectedBedroom = "1 Kamar";
    selectedCondition = "Furnished";
    selectedCertificate = "SHM";

    uploaderCtrl.clear();
    landMinCtrl.clear();
    landMaxCtrl.clear();
    buildingMinCtrl.clear();
    buildingMaxCtrl.clear();

    setState(() {});
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
                  bool active = selectedType == item;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _filterChip(
                      text: item,
                      active: active,
                      onTap: () => setState(() => selectedType = item),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),

              // ==== PERSETUJUAN ====
              const Text(
                "Persetujuan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              Row(
                children: approvals.map((item) {
                  bool active = selectedApproval == item;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _filterChip(
                      text: item,
                      active: active,
                      onTap: () => setState(() => selectedApproval = item),
                    ),
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
                "Minimal",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: ["1 Kamar", "2 Kamar", "3 Kamar", "4 Kamar"].map((
                  item,
                ) {
                  bool active = selectedBedroom == item;
                  return _filterChip(
                    text: item,
                    active: active,
                    onTap: () => setState(() => selectedBedroom = item),
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
                children: ["Furnished", "Semi Furnish", "Unfurnish"].map((
                  item,
                ) {
                  bool active = selectedCondition == item;
                  return _filterChip(
                    text: item,
                    active: active,
                    onTap: () => setState(() => selectedCondition = item),
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
                  bool active = selectedCertificate == item;
                  return _filterChip(
                    text: item,
                    active: active,
                    onTap: () => setState(() => selectedCertificate = item),
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
                          "sort": selectedSort,
                          "type": selectedType,
                          "approval": selectedApproval,
                          "uploader": uploaderCtrl.text,
                          "unit": selectedUnit,
                          "bedroom": selectedBedroom,
                          "condition": selectedCondition,
                          "certificate": selectedCertificate,
                          "landMin": landMinCtrl.text,
                          "landMax": landMaxCtrl.text,
                          "buildingMin": buildingMinCtrl.text,
                          "buildingMax": buildingMaxCtrl.text,
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
                          "sort": selectedSort,
                          "type": selectedType,
                          "approval": selectedApproval,
                          "uploader": uploaderCtrl.text,
                          "unit": selectedUnit,
                          "bedroom": selectedBedroom,
                          "condition": selectedCondition,
                          "certificate": selectedCertificate,
                          "landMin": landMinCtrl.text,
                          "landMax": landMaxCtrl.text,
                          "buildingMin": buildingMinCtrl.text,
                          "buildingMax": buildingMaxCtrl.text,
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
