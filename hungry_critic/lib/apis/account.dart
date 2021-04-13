import 'dart:convert';

import 'package:hungry_critic/models/account.dart';

import '../shared/config.dart';
import '../shared/http_utils.dart' as http;

class AccountApi {
  AccountApi(this._config, String token)
      : headers = {
          'Content-Type': 'application/json',
          'token': token,
        };

  final AppConfig _config;

  UriCreator get url => _config.http.withBase('accounts');

  final Map<String, String> headers;

  Future<Account?> fetchAccount(String? id) async {
    if (id == null) return null;
    final response = await http.get(url(), headers: headers);
    if (response == null) return null;
    return Account.fromJson(jsonDecode(response));
  }

  Future<void> updateAccount(Account account) async {
    final body = jsonEncode(account);
    await http.put(url(), headers: headers, body: body);
  }
}
