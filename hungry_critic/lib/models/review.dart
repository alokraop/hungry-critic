import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

_fromDate(DateTime time) => time.millisecondsSinceEpoch;
_toDate(int millis) => DateTime.fromMillisecondsSinceEpoch(millis);

@JsonSerializable()
class Review {
  Review({
    required this.author,
    required this.authorName,
    required this.rating,
    this.review,
    this.reply,
    DateTime? timestamp,
  }) {
    this.timestamp = timestamp ?? DateTime.now();
  }

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);

  late final String restaurant;

  final String author;

  final String authorName;

  final double rating;

  final String? review;

  String? reply;

  @JsonKey(toJson: _fromDate, fromJson: _toDate)
  late DateTime timestamp;

  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}
