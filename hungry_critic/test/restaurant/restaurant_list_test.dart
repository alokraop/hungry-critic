import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hungry_critic/blocs/master.dart';
import 'package:hungry_critic/blocs/restaurant.dart';
import 'package:hungry_critic/models/restaurant.dart';
import 'package:hungry_critic/routes/restaurants/restaurant_list.dart';
import 'package:hungry_critic/shared/context.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

import '../utils.dart';

class MockRestaurantBloc extends Mock implements RestaurantBloc {
  Map<String, Restaurant> _rMap = {};

  List<String> _restaurants = [];

  final _rSubject = BehaviorSubject<List<String>>();

  Stream<List<String>> get restaurants => _rSubject.stream;

  bool more = false;

  Future init() async {
    _rMap = {
      'id': Restaurant(
        id: 'id',
        owner: 'owner',
        name: 'First',
        address: 'Address',
        cuisines: ['American', 'French'],
      ),
      'id2': Restaurant(
        id: 'id2',
        owner: 'owner',
        name: 'Second',
        address: 'Address',
        cuisines: ['American', 'French'],
      ),
      'id3': Restaurant(
        id: 'id',
        owner: 'owner',
        name: 'Third',
        address: 'Address',
        cuisines: ['American', 'French'],
      ),
      'id4': Restaurant(
        id: 'id',
        owner: 'owner',
        name: 'Fourth',
        address: 'Address',
        cuisines: ['American', 'French'],
      ),
      'id5': Restaurant(
        id: 'id',
        owner: 'owner',
        name: 'Fifth',
        address: 'Address',
        cuisines: ['American', 'French'],
      ),
    };
    _restaurants.addAll(_rMap.keys);
    _rSubject.sink.add(_restaurants);
  }

  Restaurant? find(String id) {
    return _rMap[id];
  }

  Future<bool> loadMore() async {
    more = true;
    _rMap['id6'] = Restaurant(
      id: 'id',
      owner: 'owner',
      name: 'Sixth',
      address: 'Address',
      cuisines: ['American', 'French'],
    );
    _restaurants.add('id6');
    _rSubject.sink.add(_restaurants);
    return false;
  }

  dispose() {
    _rSubject.close();
  }
}

class MockMasterBloc extends Fake implements MasterBloc {
  MockMasterBloc(this.rBloc);

  RestaurantBloc rBloc;
}

main() {
  group('Restaurant list tests', () {
    final bloc = MockRestaurantBloc();
    final page = BlocsContainer(
      blocs: MockMasterBloc(bloc),
      child: wrapBareWidget(RestaurantList(onUpdate: (r) {})),
    );

    bloc.init();
    testWidgets('Restaurant list is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(page);

      final list = find.byKey(ValueKey('restaurant_list'));
      expect(list, findsNothing);

      await tester.pump();

      final newList = find.byKey(ValueKey('restaurant_list'));
      expect(newList, findsOneWidget);

      final view = tester.firstWidget<ListView>(newList);
      expect(view.childrenDelegate.estimatedChildCount, 5);
    });

    testWidgets('Restaurant scroll loads more', (WidgetTester tester) async {
      await tester.pumpWidget(page);
      await tester.pump();

      expect(bloc.more, false);

      final list = find.byKey(ValueKey('restaurant_list'));
      expect(list, findsOneWidget);

      final first = find.text('First');
      expect(first, findsOneWidget);

      await tester.drag(list, Offset(0, -300));

      await tester.pump();

      expect(bloc.more, true);
    });
  });
}
