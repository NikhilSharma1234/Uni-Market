import 'package:flutter/material.dart';

class Filters {
  int lowerPrice;
  int upperPrice;
  List<bool?> tags;
  Filters(this.lowerPrice, this.upperPrice, this.tags);
}
