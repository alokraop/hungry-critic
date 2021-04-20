import 'dart:convert';

import '../models/review.dart';
import '../shared/config.dart';
import '../shared/http_utils.dart' as http;

class ReviewApi {
  ReviewApi(this._config, String token)
      : headers = {
          'Content-Type': 'application/json',
          'token': token,
        };

  final AppConfig _config;

  UriCreator get url => _config.http.withBase('reviews');

  final Map<String, String> headers;

  Future<List<Review>> findAll([Map<String, dynamic>? query]) async {
    final uri = url('', [], query);
    final response = await http.get(uri, headers: headers);
    List rs = jsonDecode(response);
    return rs.map((r) => Review.fromJson(r)).toList();
  }
}
