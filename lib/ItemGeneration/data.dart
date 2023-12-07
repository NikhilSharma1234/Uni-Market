class Data {
  String name;
  int price;
  String dateListed;
  String owner;
  List<String> tags;
  Data(this.name, this.price, this.dateListed, this.owner, this.tags);
  @override
  toString() {
    return '$name $price $dateListed $owner $tags';
  }
}
