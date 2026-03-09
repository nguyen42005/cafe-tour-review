import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceModel {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String openTime;
  final String closeTime;
  final String priceMin;
  final String priceMax;
  final String categoryId;
  final String categoryName;
  final List<String> amenities;
  final String coverImage;
  final List<String> subImages;
  final String status; // 'pending', 'approved', 'rejected'
  final String createdBy;
  final DateTime createdAt;

  PlaceModel({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.openTime,
    required this.closeTime,
    required this.priceMin,
    required this.priceMax,
    this.categoryId = '',
    this.categoryName = '',
    required this.amenities,
    required this.coverImage,
    required this.subImages,
    this.status = 'pending',
    required this.createdBy,
    required this.createdAt,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json, String documentId) {
    return PlaceModel(
      id: documentId,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
      openTime: json['openTime'] ?? '07:00',
      closeTime: json['closeTime'] ?? '22:00',
      priceMin: json['priceMin'] ?? '',
      priceMax: json['priceMax'] ?? '',
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      amenities: List<String>.from(json['amenities'] ?? []),
      coverImage: json['coverImage'] ?? '',
      subImages: List<String>.from(json['subImages'] ?? []),
      status: json['status'] ?? 'pending',
      createdBy: json['createdBy'] ?? '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      'openTime': openTime,
      'closeTime': closeTime,
      'priceMin': priceMin,
      'priceMax': priceMax,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'amenities': amenities,
      'coverImage': coverImage,
      'subImages': subImages,
      'status': status,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
