class SyncQueueItemModel {
  int? id;
  final int? tempId; // For mapping created items
  final String url;
  final String method;
  final Map<String, dynamic> body;
  final int timestamp;

  SyncQueueItemModel({
    this.id,
    this.tempId,
    required this.url,
    required this.method,
    required this.body,
    required this.timestamp,
  });

  factory SyncQueueItemModel.fromJson(Map<String, dynamic> json) {
    return SyncQueueItemModel(
      id: json['id'],
      tempId: json['tempId'],
      url: json['url'],
      method: json['method'],
      body: json['body'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tempId': tempId,
      'url': url,
      'method': method,
      'body': body,
      'timestamp': timestamp,
    };
  }
} 