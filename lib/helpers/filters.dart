enum Sort {
  lowToHigh,
  highToLow,
  bestMatch,
  newestToOldest,
  oldestToNewest,
}

enum Condition { newItem, usedItem, wornItem, none }

class Filters {
  int lowerPrice;
  int upperPrice;
  List<String?> tags;
  Sort sort;
  bool showFlagged = false;
  Condition condition;
  Filters(this.lowerPrice, this.upperPrice, this.tags, this.sort,
      this.showFlagged, this.condition);
  Filters.none()
      : lowerPrice = 0,
        upperPrice = 100000,
        tags = [],
        sort = Sort.bestMatch,
        showFlagged = false,
        condition = Condition.none;
}
