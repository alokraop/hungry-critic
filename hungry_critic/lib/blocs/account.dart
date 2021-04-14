import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../apis/account.dart';
import '../data/account.dart';
import '../models/account.dart';
import '../shared/config.dart';

class AccountBloc {
  AccountBloc(this.config) {
    _provider = SelfProvider();
  }

  final AppConfig config;

  late AccountApi _api;

  late SelfProvider _provider;

  late Account account;

  String get id => account.id;

  String get token => account.token;

  final BehaviorSubject<Account> _accountSubject = BehaviorSubject<Account>();

  Stream<Account> get accountStream => _accountSubject.stream;

  Future<bool> init() async {
    final _account = await _provider.find();
    if (_account != null) {
      account = _account;
      _api = AccountApi(this.config, account.token);
      _publish(account);
    }
    return _account?.name != null;
  }

  Future update(Account changes) {
    account.update(changes);
    _publish(account);

    return Future.wait([
      _provider.save(account),
      _api.updateAccount(account),
    ]);
  }

  Future delete() => _provider.delete();

  void dispose() => _accountSubject.close();

  void _publish(Account account) {
    this.account = account;
    if (!_accountSubject.isClosed) {
      _accountSubject.sink.add(account);
    }
  }

  Future save(Account account) {
    _publish(account);
    _api = AccountApi(config, account.token);
    return _provider.save(account);
  }
}
