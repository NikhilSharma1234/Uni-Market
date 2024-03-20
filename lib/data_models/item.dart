import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  String? id;
  Timestamp? createdAt;
  Timestamp? dateUpdated;
  Timestamp? deletedAt;
  String? description;
  List<dynamic>? images;
  bool? isFlagged;
  String? lastReviewedBy;
  String? marketplaceId;
  String? name;
  double? price;
  String? schoolId;
  String? sellerId;
  List<dynamic>? tags;
  List? imageLinks;

  delete() {
    id = null;
    createdAt = null;
    dateUpdated = null;
    deletedAt = null;
    description = null;
    images = null;
    isFlagged = null;
    lastReviewedBy = null;
    marketplaceId = null;
    name = null;
    price = null;
    schoolId = null;
    sellerId = null;
    tags = null;
    imageLinks = null;
  }

  Item({
    required this.id,
    required this.createdAt,
    required this.dateUpdated,
    required this.deletedAt,
    required this.description,
    required this.images,
    required this.isFlagged,
    required this.lastReviewedBy,
    required this.marketplaceId,
    required this.name,
    required this.price,
    required this.schoolId,
    required this.sellerId,
    required this.tags,
    this.imageLinks
  });
}