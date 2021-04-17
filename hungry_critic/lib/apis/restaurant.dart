import 'dart:convert';

import '../models/restaurant.dart';
import '../models/review.dart';
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

  Future<List<Restaurant>> findAll() async {
    final response = await http.get(url(), headers: headers);
    List rs = jsonDecode(response);
    return rs.map((r) => Restaurant.fromJson(r)).toList();
  }

  Future<Restaurant> createNew(Restaurant restaurant) async {
    final response = await http.post(url(), headers: headers, body: jsonEncode(restaurant));
    return Restaurant.fromJson(jsonDecode(response));
  }

  Future delete(String id) {
    return http.delete(url(id), headers: headers);
  }

  Future update(Restaurant restaurant) {
    return http.put(url(restaurant.id), headers: headers, body: jsonEncode(restaurant));
  }

  Future<List<Review>> findAllReviews(String rId) async {
    final response = await http.get(url(rId, ['reviews']), headers: headers);
    List rs = jsonDecode(response);
    return rs.map((r) => Review.fromJson(r)).toList();
  }

  Future createReview(Review review) {
    final uri = url(review.restaurant, ['reviews']);
    return http.post(uri, headers: headers, body: jsonEncode(review));
  }

  Future updateReview(Review review) {
    final uri = url(review.restaurant, ['reviews', review.author]);
    return http.put(uri, headers: headers, body: jsonEncode(review));
  }

  Future deleteReview(Review review) {
    final uri = url(review.restaurant, ['reviews', review.author]);
    return http.delete(uri, headers: headers);
  }
}
