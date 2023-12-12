class Data {
  String name;
  int price;
  String dateListed;
  String owner;
  String imagePath;
  List<String> tags;
  Data(this.name, this.price, this.dateListed, this.owner, this.imagePath,
      this.tags);
  @override
  toString() {
    return '$name $price $dateListed $owner $imagePath $tags';
  }
}
