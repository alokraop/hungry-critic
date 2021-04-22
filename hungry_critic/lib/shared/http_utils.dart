import 'dart:convert';

import 'package:http/http.dart' as http;

import 'aspects.dart';

typedef Future<String> HttpMethod(Uri url, {Map<String, String>? headers, body});

class HttpException implements Exception {
  HttpException(this.message);

  final String message;

  String toString() => 'HttpException: $message';
}

Future<String> get(Uri url, {Map<String, String>? headers}) async {
  final response = await http.get(url, headers: headers).catchError(recordError);
  final firstDigit = response.statusCode ~/ 100;
  if (firstDigit != 2) {
    final exception = HttpException('GET $url -> ${response.body}');
    Aspects.instance.recordError(exception);
    throw exception;
  }
  return response.body;
}

Future<String> post(
  Uri url, {
  Map<String, String>? headers,
  body,
  Encoding? encoding,
}) async {
  final response = await rawPost(
    url,
    headers: headers,
    body: body,
    encoding: encoding,
  ).catchError(recordError);
  final firstDigit = response.statusCode ~/ 100;
  if (firstDigit != 2) {
    final exception = HttpException('POST $url -> ${response.body}');
    Aspects.instance.recordError(exception);
    throw exception;
  }
  return response.body;
}

Future<http.Response> rawPost(
  Uri url, {
  Map<String, String>? headers,
  body,
  Encoding? encoding,
}) {
  return http.post(url, headers: headers, body: body, encoding: encoding).catchError(recordError);
}

Future<String> put(
  Uri url, {
  Map<String, String>? headers,
  body,
  Encoding? encoding,
}) async {
  final response = await http
      .put(
        url,
        headers: headers,
        body: body,
        encoding: encoding,
      )
      .catchError(recordError);
  final firstDigit = response.statusCode ~/ 100;
  if (firstDigit != 2) {
    final exception = HttpException('PUT $url -> ${response.body}');
    Aspects.instance.recordError(exception);
    throw exception;
  }
  return response.body;
}

Future<String> delete(Uri url, {Map<String, String>? headers}) async {
  final response = await http.delete(url, headers: headers).catchError(recordError);
  final firstDigit = response.statusCode ~/ 100;
  if (firstDigit != 2) {
    final exception = HttpException('DELETE $url -> ${response.body}');
    Aspects.instance.recordError(exception);
    throw exception;
  }
  return response.body;
}

http.Response recordError(e, [StackTrace? stack]) {
  Aspects.instance.recordError(e, stack);
  return http.Response(e.toString(), 499);
}
