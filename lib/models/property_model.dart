import 'dart:convert';

class PropertyPhoto {
  final String id;
  final String photoUrl;
  final String propertyId;
  final String createdAt;

  PropertyPhoto({
    required this.id,
    required this.photoUrl,
    required this.propertyId,
    required this.createdAt,
  });

  factory PropertyPhoto.fromJson(Map<String, dynamic> json) {
    return PropertyPhoto(
      id: json['id'] ?? '',
      photoUrl: json['photo_url'] ?? '',
      propertyId: json['propertyId'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class PropertyModel {
  final String id;
  final String nama;
  final String lokasi;
  final String deskripsi;
  final int harga;
  final int luasTanah;
  final int luasBangunan;
  final int listrik;
  final int air;
  final int kamarTidur;
  final int kamarMandi;
  final int dapur;
  final int garasi;
  final int carport;
  // final String listrik;
  // final String air;
  final List<PropertyPhoto> foto;
  final String sertifikat;
  final String furnish;
  final String hadap;
  final String propertyType;
  final String? tipe;
  final String listingType;
  final String status;
  final String? rejectReason;
  final String userId;
  final int views;
  final int clicks;
  final String createdAt;
  final String updatedAt;

  PropertyModel({
    required this.id,
    required this.nama,
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
    required this.foto,
    required this.sertifikat,
    required this.furnish,
    required this.hadap,
    required this.propertyType,
    this.tipe,
    required this.listingType,
    required this.status,
    this.rejectReason,
    required this.userId,
    required this.views,
    required this.clicks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      lokasi: json['lokasi'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      harga: int.tryParse(json['harga'].toString()) ?? 0,
      luasTanah: int.tryParse(json['luas_tanah'].toString()) ?? 0,
      luasBangunan: int.tryParse(json['luas_bangunan'].toString()) ?? 0,
      listrik: int.tryParse(json['listrik'].toString()) ?? 0,
      air: int.tryParse(json['air'].toString()) ?? 0,
      kamarTidur: json['kamar_tidur'] ?? 0,
      kamarMandi: json['kamar_mandi'] ?? 0,
      dapur: json['dapur'] ?? 0,
      garasi: json['garasi'] ?? 0,
      carport: json['carport'] ?? 0,
      // listrik: json['listrik'] ?? '',
      // air: json['air'] ?? '',
      foto: (json['foto'] as List<dynamic>)
          .map((x) => PropertyPhoto.fromJson(x))
          .toList(),
      sertifikat: json['sertifikat'] ?? '',
      furnish: json['furnish'] ?? '',
      hadap: json['hadap'] ?? '',
      propertyType: json['property_type'] ?? '',
      tipe: json['tipe'],
      listingType: json['listing_type'] ?? '',
      status: json['status'] ?? '',
      rejectReason: json['reject_reason'],
      userId: json['userId'] ?? '',
      views: json['views'] ?? 0,
      clicks: json['clicks'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class PropertyListResponse {
  final List<PropertyModel> items;
  final int total;
  final int page;
  final int perPage;
  final int totalPages;

  PropertyListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.perPage,
    required this.totalPages,
  });

  factory PropertyListResponse.fromJson(Map<String, dynamic> json) {
    return PropertyListResponse(
      items: (json['items'] as List<dynamic>)
          .map((x) => PropertyModel.fromJson(x))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      perPage: json['perPage'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}
