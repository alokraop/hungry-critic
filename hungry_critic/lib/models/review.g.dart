// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) {
  return Review(
    author: json['author'] as String,
    rating: json['rating'] as int,
    review: json['review'] as String?,
  )..restaurant = json['restaurant'] as String;
}

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
      'restaurant': instance.restaurant,
      'author': instance.author,
      'rating': instance.rating,
      'review': instance.review,
    };
