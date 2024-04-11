import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uni_market/components/ItemGeneration/item.dart';
import 'package:uni_market/components/ItemGeneration/abstract_item_factory.dart';

void main() {
  testWidgets('Itembox creation test', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    AbstractItemFactory fac = AbstractItemFactory();

    Item item = Item(
        "TestItem",
        "123",
        "TestDescription",
        "NEW",
        "TestSchoolId",
        123.45,
        DateTime(0, 0),
        ["NOIMAGE"],
        "TestSellerId",
        ["TestTags"],
        false,
        null);

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
