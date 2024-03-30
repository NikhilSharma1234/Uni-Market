// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uni_market/components/item_page_info.dart';
import 'package:uni_market/components/ItemGeneration/item.dart';

void main() {
  testWidgets('Item Page Info test', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    Item itemData = Item(
      "Test Item 1",
      "12345",
      "This a test item for a test.",
      "NEW",
      "University of Nevada, Reno",
      12.00,
      DateTime(0, 0),
      ['image1path', 'secondImagePath'],
      "selleremailid@gmail.com",
      ['tag1', 'tag2'],
    );
    String sellerName = 'Nikhil Sharma';
    String sellerProfilePic = 'somelink';
    // Build our app and trigger a frame.
    await tester.pumpWidget(Builder(builder: (BuildContext context) {
      return MaterialApp(
          home: Scaffold(
              body: ItemPageInfo(
                  itemData: itemData,
                  sellerName: sellerName,
                  sellerProfilePic: sellerProfilePic)));
    }));

    // Verify that our counter starts at 0.
    expect(find.text('Test Item 1'), findsOneWidget);
    expect(find.text('tag2'), findsOneWidget);
  });
}
