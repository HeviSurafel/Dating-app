class Swipe {
  final int id;
  final int swiperId;
  final int swipeeId;
  final String type;
  final DateTime createdAt;

  Swipe({
    required this.id,
    required this.swiperId,
    required this.swipeeId,
    required this.type,
    required this.createdAt,
  });

  factory Swipe.fromJson(Map<String, dynamic> json) {
    return Swipe(
      id: json['id'] as int,
      swiperId: json['swiper_id'] as int,
      swipeeId: json['swipee_id'] as int,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'swiper_id': swiperId,
      'swipee_id': swipeeId,
      'type': type,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isLike => type == 'like';
  bool get isPass => type == 'pass';
  bool get isSuperLike => type == 'super-like';
}