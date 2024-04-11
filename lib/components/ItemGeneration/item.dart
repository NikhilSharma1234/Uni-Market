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
  DateTime? deletedAt;
  Item(
      this.name,
      this.id,
      this.description,
      this.condition,
      this.schoolId,
      this.price,
      this.createdAt,
      this.imagePath,
      this.sellerId,
      this.tags,
      this.isFlagged,
      this.deletedAt);

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
        isFlagged = false,
        deletedAt = null {
    name = map['name'];
    id = map['id'];
    description = map['description'];
    condition = map['condition'];
    schoolId = map['schoolId'].toString();
    price = map['price'].toDouble();
    createdAt =
        DateTime.fromMicrosecondsSinceEpoch((map['createdAt'] * 1000000));
    sellerId = map['sellerId'];
    for (String path in map['images']) {
      imagePath.add(path);
    }
    tags = map['tags'];
    isFlagged = map['isFlagged'];
    deletedAt =
        map['deletedAt'] == 'None' ? null : DateTime.parse(map['deletedAt']);
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
        isFlagged = false,
        deletedAt = null {
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
    deletedAt = map['deletedAt']?.toDate();
  }

  @override
  toString() {
    return '$name $price $createdAt $sellerId $imagePath $tags';
  }
}
