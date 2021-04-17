import 'package:rxdart/rxdart.dart';

import '../apis/restaurant.dart';
import '../models/restaurant.dart';
import 'account.dart';

class RestaurantBloc {
  RestaurantBloc(this.aBloc) : api = RestaurantApi(aBloc.config, aBloc.token);

  final RestaurantApi api;

  final AccountBloc aBloc;

  List<String> _restaurants = [];

  Map<String, Restaurant> _rMap = {};

  final _rSubject = BehaviorSubject<List<String>>();

  Stream<List<String>> get restaurants => _rSubject.stream;

  Future init() async {
    final rs = await api.findAll() ?? [];
    rs.forEach((r) => _rMap[r.id] = r);
    _restaurants = rs.map((r) => r.id).toList();
    _publish();
  }

  Restaurant? find(String id) => _rMap[id];

  Future createNew(Restaurant restaurant) async {
    _restaurants.insert(0, restaurant.id);
    _rMap[restaurant.id] = restaurant;
    _publish();
    return api.createNew(restaurant);
  }

  _publish() {
    _rSubject.sink.add(_restaurants);
  }

  dispose() {
    _rSubject.close();
  }

  Future deleteRestaurant(Restaurant restaurant) async {
    _restaurants.remove(restaurant.id);
    _rMap.remove(restaurant.id);
    _publish();
    return api.delete(restaurant.id);
  }
}
