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
  List<bool?> tags;
  Sort sort;
  bool showFlagged = false;
  Condition condition;
  Filters(this.lowerPrice, this.upperPrice, this.tags, this.sort,
      this.showFlagged, this.condition);
  Filters.none()
      : lowerPrice = 0,
        upperPrice = 100000,
        tags = [false, false, false, false],
        sort = Sort.bestMatch,
        showFlagged = false,
        condition = Condition.none;
}
