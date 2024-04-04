class Item {
  String name;
  String id;
  String description;
  String condition;
  String schoolId;
  double price;
  DateTime createdAt;
  List<String> imagePath;
  String sellerId;
  List<dynamic> tags;
  bool isFlagged;
  Item(this.name, this.id, this.description, this.condition, this.schoolId,
      this.price, this.createdAt, this.imagePath, this.sellerId, this.tags, this.isFlagged);

  Item.fromJSON(Map map)
      // all of these need to be initialized
      : name = "missing",
        id = "missing",
        description = "missing",
        condition = "missing",
        schoolId = "missing",
        price = 0.0,
        createdAt = DateTime(0, 0),
        sellerId = "missing",
        imagePath = [],
        tags = [],
        isFlagged = false {
    name = map['name'];
    id = map['id'];
    description = map['description'];
    condition = map['condition'];
    schoolId = map['schoolId'].toString();
    price = map['price'].toDouble();
    createdAt = DateTime.parse(map['createdAt']);
    sellerId = map['sellerId'];
    for (String path in map['images']) {
      imagePath.add(path);
    }
    tags = map['tags'];
    isFlagged = map['isFlagged'];
  }

  Item.fromFirebase(Map map)
      // all of these need to be initialized
      : name = "missing",
        id = "missing",
        description = "missing",
        condition = "missing",
        schoolId = "missing",
        price = 0.0,
        createdAt = DateTime(0, 0),
        sellerId = "missing",
        imagePath = [],
        tags = [],
        isFlagged = false {
    name = map['name'];
    id = map['id'];
    description = map['description'];
    condition = map['condition'];
    schoolId = map['schoolId'];
    price = map['price'].toDouble();
    createdAt = map['createdAt'].toDate();
    sellerId = map['sellerId'];
    for (String path in map['images']) {
      imagePath.add(path);
    }
    tags = map['tags'];
    isFlagged = map['isFlagged'];
  }

  @override
  toString() {
    return '$name $price $createdAt $sellerId $imagePath $tags';
  }
}

// Example call to firestore
// {condition: NEW, buyerId: null, marketplaceId: ItNl1jMiGqv9yVNlrRVZ, price: 10.99, sellerId: cameronmccoy@nevada.unr.edu, name: i am selling crack, images: [images/1707352753279.jpg], description: here is my
// crack, dateUpdated: Timestamp(seconds=1707352754, nanoseconds=591000000), dateDeleted: null, tags: [], schoolId: UNR, dateListed: Timestamp(seconds=1707352754, nanoseconds=591000000)}
// {marketplaceId: ItNl1jMiGqv9yVNlrRVZ, dateUpdated: Timestamp(seconds=0, nanoseconds=0), schoolId: UNR, price: 10.99, sellerId: cameronmccoy@nevada.unr.edu, itemId: , tags: [], condition: NEW, name:
// dfsfjkdjfkjsdkfjk, dateListed: Timestamp(seconds=1707335668, nanoseconds=916000000), imgPath: , dateDeleted: Timestamp(seconds=0, nanoseconds=0), description: shit, buyerId: }

// example call to typesense:
// full doc:
// {document: {condition: NEW, dateListed: 1708304323, dateUpdated: 1708304323, description: This is a test, id: bjxZMCR9PlhzEliDkX9w, images: [images/1708304322545.jpg], marketplaceId: ItNl1jMiGqv9yVNlrRVZ, name: Test_item, price: 5.55,
// schoolId: UNR, sellerId: jacobghunter@nevada.unr.edu, tags: []}, highlight: {description: {matched_tokens: [test], snippet: This is a <mark>test</mark>}, name: {matched_tokens: [Test], snippet: <mark>Test</mark>_item}}, highlights:
// [{field: name, matched_tokens: [Test], snippet: <mark>Test</mark>_item}, {field: description, matched_tokens: [test], snippet: This is a <mark>test</mark>}], text_match: 578730123365187700, text_match_info: {best_field_score:
// 1108091338752, best_field_weight: 14, fields_matched: 1, score: 578730123365187697, tokens_matched: 1}}

// just the item
// {condition: NEW, dateListed: 1708317444, dateUpdated: 1708317444, description: not a test (fr), id: Y86sBZUwNWMcEsE4S3U7, images: [images/1708317442804.jpg], marketplaceId: ItNl1jMiGqv9yVNlrRVZ, name: AAAAAAAAAAAAAAAAAAAAAAAAAAAAA,
// price: 100, schoolId: UNR, sellerId: jacobghunter@nevada.unr.edu, tags: []}