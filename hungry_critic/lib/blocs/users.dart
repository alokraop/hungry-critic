import 'package:rxdart/rxdart.dart';

import '../apis/account.dart';
import '../models/account.dart';
import 'account.dart';

class UserBloc {
  UserBloc(this.aBloc) : api = AccountApi(aBloc.config, aBloc.token);

  final AccountApi api;

  final AccountBloc aBloc;

  List<String> _users = [];

  Map<String, Account> _uMap = {};

  final _uSubject = BehaviorSubject<List<String>>();

  Stream<List<String>> get users => _uSubject.stream;

  Future init() async {
    final us = await api.fetchAll();
    us.forEach((u) => _uMap[u.id] = u);
    _users = us.map((u) => u.id).toList();
    _publish();
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
    return api.deleteAccount(account);
  }

  _publish() {
    _uSubject.sink.add(_users);
  }

  dispose() {
    _uSubject.close();
  }
}
