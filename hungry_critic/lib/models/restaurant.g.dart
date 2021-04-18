// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Restaurant _$RestaurantFromJson(Map<String, dynamic> json) {
  return Restaurant(
    id: json['id'] as String,
    owner: json['owner'] as String,
    name: json['name'] as String,
    address: json['address'] as String?,
    cuisines:
        (json['cuisines'] as List<dynamic>).map((e) => e as String).toList(),
  )
    ..averageRating = (json['averageRating'] as num).toDouble()
    ..totalRatings = json['totalRatings'] as int
    ..totalReviews = json['totalReviews'] as int
    ..bestReview = json['bestReview'] == null
        ? null
        : Review.fromJson(json['bestReview'] as Map<String, dynamic>)
    ..worstReview = json['worstReview'] == null
        ? null
        : Review.fromJson(json['worstReview'] as Map<String, dynamic>);
}

Map<String, dynamic> _$RestaurantToJson(Restaurant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'owner': instance.owner,
      'name': instance.name,
      'address': instance.address,
      'cuisines': instance.cuisines,
      'averageRating': instance.averageRating,
      'totalRatings': instance.totalRatings,
      'totalReviews': instance.totalReviews,
      'bestReview': instance.bestReview,
      'worstReview': instance.worstReview,
    };
