import 'dart:convert';

import '../models/restaurant.dart';
import '../shared/config.dart';
import '../shared/http_utils.dart' as http;

class RestaurantApi {
  RestaurantApi(this._config, String token)
      : headers = {
          'Content-Type': 'application/json',
          'token': token,
        };

  final AppConfig _config;

  UriCreator get url => _config.http.withBase('restaurants');

  final Map<String, String> headers;

  Future<List<Restaurant>?> findAll() async {
    final response = await http.get(url(), headers: headers);
    if (response == null) return null;
    List rs = jsonDecode(response);
    return rs.map((r) => Restaurant.fromJson(r)).toList();
  }

  Future createNew(Restaurant restaurant) {
    return http.post(url(), headers: headers, body: jsonEncode(restaurant));
  }

  Future delete(String id) {
    return http.delete(url(id), headers: headers);
  }
}
