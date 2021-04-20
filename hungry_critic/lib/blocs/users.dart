import 'package:hungry_critic/blocs/restaurant.dart';
import 'package:rxdart/rxdart.dart';

import '../apis/account.dart';
import '../models/account.dart';
import 'account.dart';

class UserBloc {
  UserBloc(this.aBloc, this.rBloc) : api = AccountApi(aBloc.config, aBloc.token);

  final AccountApi api;

  final AccountBloc aBloc;

  final RestaurantBloc rBloc;

  List<String> _users = [];

  Map<String, Account> _uMap = {};

  final _uSubject = BehaviorSubject<List<String>>();

  Stream<List<String>> get users => _uSubject.stream;

  Future init() {
    _users = [];
    return _load();
  }

  Future<int> _load([Map<String, dynamic>? query]) async {
    final us = await api.fetchAll(query);
    us.forEach((u) => _uMap[u.id] = u);
    _users.addAll(
      us.where((u) => u.id != aBloc.account.id).map((u) => u.id).toList(),
    );
    _publish();
    return us.length;
  }

  Future<bool> loadMore() async {
    final query = {
      'offset': _users.length.toString(),
      'limit': limit.toString(),
    };
    final length = await _load(query);
    return length == limit;
  }

  Account? find(String id) => _uMap[id];

  Future update(Account update) {
    _uMap[update.id] = update;
    _publish();
    return api.updateAccount(update);
  }

  Future delete(Account account) async {
    _users.remove(account.id);
    _uMap.remove(account.id);
    _publish();
    await api.deleteAccount(account);
    switch (account.role) {
      case UserRole.USER:
        return rBloc.deleteReviews(account.id);
      case UserRole.OWNER:
        return rBloc.deleteRestaurants(account.id);
      default:
    }
  }

  _publish() {
    _uSubject.sink.add(_users);
  }

  dispose() {
    _uSubject.close();
  }
}
