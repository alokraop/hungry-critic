// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) {
  return Review(
    author: json['author'] as String,
    authorName: json['authorName'] as String,
    rating: (json['rating'] as num).toDouble(),
    review: json['review'] as String?,
    reply: json['reply'] as String?,
    timestamp: _toDate(json['timestamp'] as int),
  )..restaurant = json['restaurant'] as String;
}

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
      'restaurant': instance.restaurant,
      'author': instance.author,
      'authorName': instance.authorName,
      'rating': instance.rating,
      'review': instance.review,
      'reply': instance.reply,
      'timestamp': _fromDate(instance.timestamp),
    };
