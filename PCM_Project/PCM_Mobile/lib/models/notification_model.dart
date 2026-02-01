// Notification Models
class Notification {
  final String id;
  final String title;
  final String message;
  final String type; // 'info', 'success', 'warning', 'error', 'booking', 'payment'
  final DateTime timestamp;
  bool isRead;
  final String? actionUrl;
  final Map<String, dynamic>? data;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.actionUrl,
    this.data,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'info',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] ?? false,
      actionUrl: json['actionUrl'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'type': type,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
    'actionUrl': actionUrl,
    'data': data,
  };
}
