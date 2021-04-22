import 'package:flutter_test/flutter_test.dart';
import 'package:hungry_critic/models/review.dart';
import 'package:hungry_critic/routes/restaurants/review.dart';
import 'package:intl/intl.dart';

import '../utils.dart';

main() {
  group('Review tests', () {
    final goodReview = Review(
      author: 'foiamsd',
      authorName: 'Person',
      rating: 3.55,
      review: 'This place was pretty good',
      dateOfVisit: DateTime.now(),
    );

    testWidgets('Review information is displayed', (WidgetTester tester) async {
      final review = ReviewView(review: goodReview);
      await tester.pumpWidget(wrapBareWidget(review));

      final name = find.text(goodReview.authorName);
      final rating = find.text(goodReview.rating.toStringAsFixed(1));
      final content = find.text(goodReview.review);

      final format = DateFormat.yMd();
      final visit = format.format(goodReview.dateOfVisit);
      final hours = find.text(visit);

      expect(name, findsOneWidget);
      expect(rating, findsOneWidget);
      expect(content, findsOneWidget);
      expect(hours, findsOneWidget);
    });
  });
}
