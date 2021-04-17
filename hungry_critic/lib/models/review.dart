import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

_fromDate(DateTime time) => time.millisecondsSinceEpoch;
_toDate(int millis) => DateTime.fromMicrosecondsSinceEpoch(millis);

@JsonSerializable()
class Review {
  Review({
    required this.author,
    required this.rating,
    this.review,
  }) : timestamp = DateTime.now();

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  late final String restaurant;

  final String author;

  final int rating;

  final String? review;

  @JsonKey(toJson: _fromDate, fromJson: _toDate)
  final DateTime timestamp;

  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}
