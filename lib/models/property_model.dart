class PropertyModel {
  final String? id;
  final String? nama; // hanya muncul jika backend memang kirim
  final String lokasi;
  final String deskripsi;
  final int harga;
  final int luasTanah;
  final int luasBangunan;
  final int kamarTidur;
  final int kamarMandi;
  final int dapur;
  final int garasi;
  final int carport;
  final int listrik;
  final String air;
  final String sertifikat;
  final String furnish;
  final String hadap;
  final String propertyType;
  final String tipe;
  final String listingType;
  final String userId;
  final String foto;
  final String? status;

  String get thumbnailUrl {
    return foto.startsWith("http")
        ? foto
        : "https://your-backend-url.com/uploads/$foto";
  }

  PropertyModel({
    this.id,
    this.nama,
    required this.lokasi,
    required this.deskripsi,
    required this.harga,
    required this.luasTanah,
    required this.luasBangunan,
    required this.kamarTidur,
    required this.kamarMandi,
    required this.dapur,
    required this.garasi,
    required this.carport,
    required this.listrik,
    required this.air,
    required this.sertifikat,
    required this.furnish,
    required this.hadap,
    required this.propertyType,
    required this.tipe,
    required this.listingType,
    required this.userId,
    required this.foto,
    this.status,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id']?.toString(),
      nama: json['nama'], // optional
      lokasi: json['lokasi'] ?? "",
      deskripsi: json['deskripsi'] ?? "",
      harga: int.tryParse(json['harga'].toString()) ?? 0,
      luasTanah: json['luas_tanah'] ?? 0,
      luasBangunan: json['luas_bangunan'] ?? 0,
      kamarTidur: json['kamar_tidur'] ?? 0,
      kamarMandi: json['kamar_mandi'] ?? 0,
      dapur: json['dapur'] ?? 0,
      garasi: json['garasi'] ?? 0,
      carport: json['carport'] ?? 0,
      listrik: json['listrik'] ?? 0,
      air: json['air'].toString(),
      sertifikat: json['sertifikat'] ?? "",
      furnish: json['furnish'] ?? "",
      hadap: json['hadap'] ?? "",
      propertyType: json['property_type'] ?? "",
      tipe: json['tipe'] ?? "",
      listingType: json['listing_type'] ?? "",
      userId: json['userId'] ?? "",
      foto: json['foto'] ?? "",
      status: json['status'],
    );
  }
}
