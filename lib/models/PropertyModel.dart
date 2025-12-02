// class PropertyModel {
//   final String id;
//   final String nama;
//   final String lokasi;
//   final String deskripsi;
//   final String harga;
//   final String luasTanah;
//   final String luasBangunan;
//   final int kamarTidur;
//   final int kamarMandi;
//   final int dapur;
//   final int garasi;
//   final int carport;
//   final String listrik;
//   final String air;
//   final List<PropertyPhoto> foto;
//   final String sertifikat;
//   final String furnish;
//   final String hadap;
//   final String propertyType;
//   final String? tipe;
//   final String listingType;
//   final String status;
//   final String? rejectReason;
//   final String userId;
//   final int views;
//   final int clicks;
//   final String createdAt;
//   final String updatedAt;

//   PropertyModel({
//     required this.id,
//     required this.nama,
//     required this.lokasi,
//     required this.deskripsi,
//     required this.harga,
//     required this.luasTanah,
//     required this.luasBangunan,
//     required this.kamarTidur,
//     required this.kamarMandi,
//     required this.dapur,
//     required this.garasi,
//     required this.carport,
//     required this.listrik,
//     required this.air,
//     required this.foto,
//     required this.sertifikat,
//     required this.furnish,
//     required this.hadap,
//     required this.propertyType,
//     required this.tipe,
//     required this.listingType,
//     required this.status,
//     required this.rejectReason,
//     required this.userId,
//     required this.views,
//     required this.clicks,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory PropertyModel.fromJson(Map<String, dynamic> json) {
//     return PropertyModel(
//       id: json['id'],
//       nama: json['nama'],
//       lokasi: json['lokasi'],
//       deskripsi: json['deskripsi'],
//       harga: json['harga'],
//       luasTanah: json['luas_tanah'],
//       luasBangunan: json['luas_bangunan'],
//       kamarTidur: json['kamar_tidur'],
//       kamarMandi: json['kamar_mandi'],
//       dapur: json['dapur'],
//       garasi: json['garasi'],
//       carport: json['carport'],
//       listrik: json['listrik'],
//       air: json['air'],
//       foto: (json['foto'] as List<dynamic>)
//           .map((e) => PropertyPhoto.fromJson(e))
//           .toList(),
//       sertifikat: json['sertifikat'],
//       furnish: json['furnish'],
//       hadap: json['hadap'],
//       propertyType: json['property_type'],
//       tipe: json['tipe'],
//       listingType: json['listing_type'],
//       status: json['status'],
//       rejectReason: json['reject_reason'],
//       userId: json['userId'],
//       views: json['views'],
//       clicks: json['clicks'],
//       createdAt: json['created_at'],
//       updatedAt: json['updated_at'],
//     );
//   }
// }
