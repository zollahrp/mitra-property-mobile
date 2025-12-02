// class PropertyPhoto {
//   final String id;
//   final String photoUrl;
//   final String propertyId;
//   final String createdAt;

//   PropertyPhoto({
//     required this.id,
//     required this.photoUrl,
//     required this.propertyId,
//     required this.createdAt,
//   });

//   factory PropertyPhoto.fromJson(Map<String, dynamic> json) {
//     return PropertyPhoto(
//       id: json['id'],
//       photoUrl: json['photo_url'],
//       propertyId: json['propertyId'],
//       createdAt: json['created_at'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       "id": id,
//       "photo_url": photoUrl,
//       "propertyId": propertyId,
//       "created_at": createdAt,
//     };
//   }
// }