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

  Future<List<Account>> fetchAll(Map<String, dynamic>? query) async {
    final uri = url('', [], query);
    final response = await http.get(uri, headers: headers);
    List rs = jsonDecode(response);
    return rs.map((r) => Account.fromJson(r)..token = '').toList();
  }

  Future<Account?> fetchAccount(String id) async {
    final response = await http.get(url(id), headers: headers);
    return Account.fromJson(jsonDecode(response));
  }

  Future<AuthReceipt> initProfile(Account account) async {
    final body = jsonEncode(account);
    final response = await http.post(url(), headers: headers, body: body);
    return AuthReceipt.fromJson(jsonDecode(response));
  }

  Future<void> updateAccount(Account account) async {
    final body = jsonEncode(account);
    await http.put(url(account.id), headers: headers, body: body);
  }

  Future deleteAccount(Account account) {
    return http.delete(url(account.id), headers: headers);
  }
}
