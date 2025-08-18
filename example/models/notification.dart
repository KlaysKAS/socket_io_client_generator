/// Example notification model
class Notification {
  final String type;
  final String message;
  final DateTime createdAt;

  Notification({
    required this.type,
    required this.message,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      type: json['type'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
