import 'package:flutter/material.dart';
import 'package:uni_market/helpers/filters.dart';
import 'package:uni_market/helpers/functions.dart';

getDrawer(
    BuildContext context,
    TextEditingController lowerPrice,
    TextEditingController upperPrice,
    Filters filter,
    Function(Filters) applyFilters,
    Function(Condition) setCondition,
    Function(List<Widget>, bool, [bool? start]) redrawItems,
    Widget tags) {
  return Drawer(
    backgroundColor: Colors.transparent,
    shadowColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8), bottomRight: Radius.circular(8))),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 50, bottom: 50, left: 8, right: 8),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text("Price Range",
                            style: TextStyle(fontSize: 24))),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 125,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: lowerPrice,
                            onChanged: ((value) {
                              if (value != "") {
                                filter.lowerPrice = int.parse(lowerPrice.text);
                              } else {
                                filter.lowerPrice = 0;
                              }
                            }),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Lower",
                            ),
                          ),
                        ),
                        const Text('-'),
                        SizedBox(
                          width: 125,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: upperPrice,
                            onChanged: ((value) {
                              if (value != "") {
                                filter.upperPrice = int.parse(upperPrice.text);
                              } else {
                                filter.upperPrice = 100000;
                              }
                            }),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Upper",
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text("Sort By", style: TextStyle(fontSize: 24))),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: DropdownMenu(
                          onSelected: (value) => filter.sort = value as Sort,
                          initialSelection: filter.sort,
                          dropdownMenuEntries: const [
                            DropdownMenuEntry(
                                value: Sort.highToLow, label: 'High to Low'),
                            DropdownMenuEntry(
                                value: Sort.lowToHigh, label: 'Low to High'),
                            DropdownMenuEntry(
                                value: Sort.newestToOldest,
                                label: 'Newest to Oldest'),
                            DropdownMenuEntry(
                                value: Sort.oldestToNewest,
                                label: 'Oldest to Newest'),
                            DropdownMenuEntry(
                                value: Sort.bestMatch, label: 'Best Match')
                          ]),
                    ),
                  ],
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     const Text('Show Flagged Items:',
                //         style: TextStyle(fontSize: 24)),
                //     Checkbox(
                //         value: filter.showFlagged,
                //         onChanged: (value) {
                //           setState(() {
                //             filter.showFlagged = value!;
                //           });
                //         })
                //   ],
                // ),
                Column(
                  children: [
                    const Padding(
                        padding: EdgeInsets.all(8),
                        child:
                            Text("Condition", style: TextStyle(fontSize: 24))),
                    ListTile(
                        title: const Text("New"),
                        leading: Radio<Condition>(
                            value: Condition.newItem,
                            groupValue: filter.condition,
                            toggleable: true,
                            onChanged: (value) {
                              setCondition(value ?? Condition.none);
                            })),
                    ListTile(
                        title: const Text("Used"),
                        leading: Radio<Condition>(
                            value: Condition.usedItem,
                            groupValue: filter.condition,
                            toggleable: true,
                            onChanged: (value) {
                              setCondition(value ?? Condition.none);
                            })),
                    ListTile(
                        title: const Text("Worn"),
                        leading: Radio<Condition>(
                            value: Condition.wornItem,
                            groupValue: filter.condition,
                            toggleable: true,
                            onChanged: (value) {
                              setCondition(value ?? Condition.none);
                            })),
                  ],
                ),
                tags,
                Padding(
                    padding: const EdgeInsets.all(5),
                    child: TextButton(
                        style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll<Color>(Colors.green),
                        ),
                        onPressed: () {
                          if (filter.lowerPrice > filter.upperPrice) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Invalid Price Range'),
                                    content: const Text(
                                        'The lower price must be less than the upper price.'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                });
                          } else {
                            redrawItems([], false);
                            applyFilters(filter);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Apply Filters'))),
                Padding(
                    padding: const EdgeInsets.all(5),
                    child: TextButton(
                        style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll<Color>(Colors.red),
                        ),
                        onPressed: () {
                          redrawItems([], false);
                          applyFilters(Filters.none());
                          Navigator.pop(context);
                        },
                        child: const Text('Clear Filters')))
              ]),
        )),
  );
}
