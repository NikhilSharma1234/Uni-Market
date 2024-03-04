import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uni_market/components/ItemGeneration/item.dart';
import 'package:uni_market/components/ItemGeneration/AbstractItemFactory.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  testWidgets('Itembox creation test', (WidgetTester tester) async {
    // to make test work, you have to start the firestore emulator
    TestWidgetsFlutterBinding.ensureInitialized();

    AbstractItemFactory fac = AbstractItemFactory();

    Item item = Item(
        "TestItem",
        "123",
        "TestDescription",
        "NEW",
        "TestSchoolId",
        123.45,
        Timestamp(0, 0),
        ["NOIMAGE"],
        "TestSellerId",
        ["TestTags"]);

    await tester.pumpWidget(Builder(builder: (BuildContext context) {
      var itemBox = fac.buildItemBox(item, context);
      return MaterialApp(
          home: Scaffold(
        body: GridView.count(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          crossAxisCount: 2,
          childAspectRatio: 2 / 2,
          children: [itemBox],
        ),
      ));
    }));

    expect(find.text('TestItem'), findsOneWidget);
    expect(find.text('\$123.45'), findsOneWidget);
  });
}
