import 'dart:convert';

import '../models/account.dart';
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

  Future<Account?> fetchAccount(String id) async {
    final response = await http.get(url(id), headers: headers);
    if (response == null) return null;
    return Account.fromJson(jsonDecode(response));
  }

  Future<void> initProfile(Account account) async {
    final body = jsonEncode(account);
    await http.post(url(), headers: headers, body: body);
  }

  Future<void> updateAccount(Account account) async {
    final body = jsonEncode(account);
    await http.put(url(account.id), headers: headers, body: body);
  }
}
