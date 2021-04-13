import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/account.dart';
import '../shared/aspects.dart';

class SelfProvider {
  final _storage = FlutterSecureStorage();

  SelfProvider();

  Future<Account?> find() async {
    try {
      final profileJson = await _storage.read(key: 'account');
      if (profileJson == null) return null;
      return Account.fromJson(jsonDecode(profileJson));
    } catch (e) {
      Aspects.instance.log('Couldn\'t find profile: ${e.toString()}');
      return null;
    }
  }

  Future save(Account account) {
    final userValue = jsonEncode(account.toJson());
    return _storage.write(key: 'account', value: userValue);
  }

  Future delete() {
    return _storage.deleteAll();
  }
}
