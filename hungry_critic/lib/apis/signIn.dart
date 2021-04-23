import 'dart:convert';

import '../models/account.dart';
import '../shared/config.dart';
import '../shared/http_utils.dart' as http;

class LoginException implements Exception {
  LoginException(this.status, this.message);

  final int status;

  final String message;

  String toString() => 'LoginException: $message';
}

class SignInApi {
  SignInApi(this._config);

  final AppConfig? _config;

  UriCreator get url => _config!.http.withBase('auth');

  final headers = {'Content-Type': 'application/json'};

  Future<AuthReceipt> signUp(Credentials creds) {
    return auth(creds, 'sign-up', 201);
  }

  Future<AuthReceipt> signIn(Credentials creds) {
    return auth(creds, 'sign-in', 200);
  }

  Future<AuthReceipt> auth(Credentials creds, String method, int code) async {
    final response = await http.rawPost(
      url(method),
      headers: headers,
      body: jsonEncode(creds),
    );
    if (response.statusCode == code) {
      final receipt = AuthReceipt.fromJson(jsonDecode(response.body));
      headers['token'] = receipt.token;
      return receipt;
    } else {
      throw LoginException(response.statusCode, 'Couldn\'t sign in: ${response.body}');
    }
  }
}
