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
    review: json['review'] as String,
    dateOfVisit: _toDate(json['dateOfVisit'] as int),
    reply: json['reply'] as String?,
    timestamp: _toDate(json['timestamp'] as int),
  )..restaurant = json['restaurant'] as String;
}

Map<String, dynamic> _$ReviewToJson(Review instance) {
  final val = <String, dynamic>{
    'restaurant': instance.restaurant,
    'author': instance.author,
    'authorName': instance.authorName,
    'rating': instance.rating,
    'review': instance.review,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('dateOfVisit', _fromDate(instance.dateOfVisit));
  writeNotNull('reply', instance.reply);
  writeNotNull('timestamp', _fromDate(instance.timestamp));
  return val;
}
