import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uni_market/pages/ItemGeneration/data.dart';

SingleChildScrollView ItemPageInfo(Data itemData, var sellerInformation) {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            itemData.name,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold
            )
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 36
            ),
            child: Text(
              '\$${itemData.price}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.start
            ),
          ),
          Text('Listed ${DateFormat('yMd').format(itemData.dateListed.toDate())} at ${itemData.schoolId}',
            style: const TextStyle(
              fontSize: 16
            )),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: ElevatedButton(
              onPressed: (){},
              style: ElevatedButton.styleFrom(
                  shape: const BeveledRectangleBorder()
                ),
              child: const Text(
                'Contact Seller',
              ),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('About the product',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            )),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Product Description: ${itemData.description}'),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('Product Tags:'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            
            children: <Widget>[
            for (var tag in itemData.tags) 
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Chip(
                  label:  Text(tag),
                ),
              )
            ]
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Divider()
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('Seller Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
            )),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ElevatedButton(
                    onPressed: (){},
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(24),
                    ),
                    child: const Icon(Icons.person, size: 96)
                  ),
                ),
                Text('Name: ${sellerInformation['name'].toString()}'),
                const Text('Items Sold: 2'),
                const Text('Items Bought: 2'),
              ],
            ),
          ),
        ]
      ),
    ),
  );
}