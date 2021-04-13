import 'dart:convert';

import '../models/account.dart';
import '../shared/config.dart';
import '../shared/http_utils.dart' as http;

class LoginException implements Exception {
  LoginException(this.message);

  final String message;

  String toString() => 'LoginException: $message';
}

class SignInApi {
  SignInApi(this._config);

  final AppConfig? _config;

  UriCreator get url => _config!.http.withBase('sign-up');

  final headers = {'Content-Type': 'application/json'};

  Future<AuthReceipt> signIn(Credentials creds) async {
    final response = await http.rawPost(
      url(),
      headers: headers,
      body: jsonEncode(creds),
    );
    if (_knownStatus(response.statusCode)) {
      final receipt = AuthReceipt.fromJson(jsonDecode(response.body));
      headers['token'] = receipt.token;
      return receipt;
    } else {
      throw LoginException('Couldn\'t sign in: ${response.body}');
    }
  }

  bool _knownStatus(int status) => status == 201 || status == 400;
}
