import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hungry_critic/models/restaurant.dart';
import 'package:hungry_critic/routes/restaurants/restaurant_card.dart';
import 'package:mockito/mockito.dart';

import '../utils.dart';

class MockCardTap extends Mock {
  call(Restaurant restaurant);
}

main() {
  group('Restaurant card tests', () {
    final restaurant = Restaurant(
      id: 'adoim-sefs-oimef-oaivo',
      owner: '32598w3',
      name: 'WOW! Momos',
      address: 'Kamanhalli, Bangalore',
      cuisines: ['Chinese', 'Italian'],
    )..averageRating = 3.33;

    testWidgets('Restaurant card is displayed', (WidgetTester tester) async {
      final tap = MockCardTap();
      final card = RestaurantCard(
        restaurant: restaurant,
        onTap: tap,
      );
      await tester.pumpWidget(wrapBareWidget(card));

      final name = find.text(restaurant.name);
      expect(name, findsOneWidget);

      final _address = restaurant.address;
      if (_address != null) {
        final address = find.text(_address);
        expect(address, findsOneWidget);
      }

      restaurant.cuisines.forEach((c) {
        final cuisine = find.text(c);
        expect(cuisine, findsOneWidget);
      });

      final rating = find.text(restaurant.averageRating.toStringAsFixed(1));
      expect(rating, findsOneWidget);

      final wholeCard = find.byType(InkWell);
      await tester.tap(wholeCard);

      verify(tap.call(restaurant)).called(1);
    });
  });
}
