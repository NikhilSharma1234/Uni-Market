import 'package:cloud_firestore/cloud_firestore.dart';

class Data {
  String name;
  double price;
  Timestamp dateListed;
  String owner;
  String imagePath;
  List<dynamic> tags;
  Data(this.name, this.price, this.dateListed, this.owner, this.imagePath,
      this.tags);
  @override
  toString() {
    return '$name $price $dateListed $owner $imagePath $tags';
  }
}

// Example call to firestore
// {condition: NEW, buyerId: null, marketplaceId: ItNl1jMiGqv9yVNlrRVZ, price: 10.99, sellerId: cameronmccoy@nevada.unr.edu, name: i am selling crack, images: [images/1707352753279.jpg], description: here is my
// crack, dateUpdated: Timestamp(seconds=1707352754, nanoseconds=591000000), dateDeleted: null, tags: [], schoolId: UNR, dateListed: Timestamp(seconds=1707352754, nanoseconds=591000000)}
// {marketplaceId: ItNl1jMiGqv9yVNlrRVZ, dateUpdated: Timestamp(seconds=0, nanoseconds=0), schoolId: UNR, price: 10.99, sellerId: cameronmccoy@nevada.unr.edu, itemId: , tags: [], condition: NEW, name:
// dfsfjkdjfkjsdkfjk, dateListed: Timestamp(seconds=1707335668, nanoseconds=916000000), imgPath: , dateDeleted: Timestamp(seconds=0, nanoseconds=0), description: shit, buyerId: }