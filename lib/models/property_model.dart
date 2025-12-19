import 'dart:convert';

/// =============================================
/// PHOTO MODEL
/// =============================================
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
      id: json["id"],
      photoUrl: json["photo_url"],
      propertyId: json["propertyId"],
      createdAt: json["created_at"],
    );
  }
}

/// =============================================
/// PROPERTY MODEL
/// =============================================
class PropertyModel {
  final String id;
  final String nama;
  final String kode;
  final String lokasi;
  final String deskripsi;
  final String harga;
  final String luasTanah;
  final String luasBangunan;
  final int kamarTidur;
  final int kamarMandi;
  final int dapur;
  final int garasi;
  final int carport;
  final String listrik;
  final String air;
  final List<PropertyPhoto> foto;
  final String sertifikat;
  final String furnish;
  final String hadap;
  final String propertyType;
  final String? type;
  final String listingType;
  final String status;
  final String? rejectReason;
  final String userId;
  final int views;
  final int clicks;
  final String telepon;
  final String createdAt;
  final String updatedAt;

  PropertyModel({
    required this.id,
    required this.nama,
    required this.kode,
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
    required this.type,
    required this.listingType,
    required this.status,
    required this.rejectReason,
    required this.userId,
    required this.views,
    required this.clicks,
    required this.telepon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json["id"] ?? "",
      nama: json["nama"] ?? "",
      kode: json["kode"] ?? "",
      lokasi: json["lokasi"] ?? "",
      deskripsi: json["deskripsi"] ?? "",
      harga: json["harga"] ?? "0",

      luasTanah: json["luas_tanah"]?.toString() ?? "0",
      luasBangunan: json["luas_bangunan"]?.toString() ?? "0",

      kamarTidur: json["kamar_tidur"] ?? 0,
      kamarMandi: json["kamar_mandi"] ?? 0,
      dapur: json["dapur"] ?? 0,
      garasi: json["garasi"] ?? 0,
      carport: json["carport"] ?? 0,

      listrik: json["listrik"]?.toString() ?? "",
      air: json["air"]?.toString() ?? "",

      sertifikat: json["sertifikat"] ?? "",
      furnish: json["furnish"] ?? "",
      hadap: json["hadap"] ?? "",
      propertyType: json["property_type"] ?? "",
      type: json["type"] ?? "",
      listingType: json["listing_type"] ?? "",
      status: json["status"] ?? "",
      rejectReason: json["reject_reason"] ?? "",

      userId: json["userId"] ?? "",
      views: json["views"] ?? 0,
      clicks: json["clicks"] ?? 0,
      telepon: json["telepon"] ?? "",

      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",

      foto: (json["foto"] as List<dynamic>? ?? [])
          .map((e) => PropertyPhoto.fromJson(e))
          .toList(),
    );
  }
}

/// =============================================
/// LIST PAGINATION MODEL
/// =============================================
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
      items: (json["items"] as List<dynamic>)
          .map((e) => PropertyModel.fromJson(e))
          .toList(),
      total: json["total"],
      page: json["page"],
      perPage: json["perPage"],
      totalPages: json["totalPages"],
    );
  }
}

/// =============================================
/// CREATE PROPERTY RESPONSE
/// =============================================
class CreatePropertyResponse {
  final String message;
  final PropertyModel property;

  CreatePropertyResponse({required this.message, required this.property});

  factory CreatePropertyResponse.fromJson(Map<String, dynamic> json) {
    return CreatePropertyResponse(
      message: json["message"],
      property: PropertyModel.fromJson(json["property"]),
    );
  }
}
