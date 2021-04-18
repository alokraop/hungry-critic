import 'package:hungry_critic/models/review.dart';
import 'package:json_annotation/json_annotation.dart';

part 'restaurant.g.dart';

@JsonSerializable()
class Restaurant {
  Restaurant({
    required this.id,
    required this.owner,
    required this.name,
    this.address,
    this.cuisines = const [],
  })  : averageRating = 0,
        totalRatings = 0,
        totalReviews = 0;

  factory Restaurant.fromJson(Map<String, dynamic> json) => _$RestaurantFromJson(json);

  final String id;

  late String owner;

  final String name;

  final String? address;

  final List<String> cuisines;

  double averageRating;

  int totalRatings;

  int totalReviews;

  Review? bestReview;

  Review? worstReview;

  Map<String, dynamic> toJson() => _$RestaurantToJson(this);
}
