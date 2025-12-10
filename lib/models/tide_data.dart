/// Modelo de dados da Tábua de Maré
class TideData {
  final String time;
  final String height;
  final TideType type;

  TideData({
    required this.time,
    required this.height,
    required this.type,
  });

  factory TideData.fromJson(Map<String, dynamic> json) {
    return TideData(
      time: json['time'] ?? '',
      height: json['height'] ?? '',
      type: json['type'] == 'high' ? TideType.high : TideType.low,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'height': height,
      'type': type == TideType.high ? 'high' : 'low',
    };
  }
}

enum TideType { high, low }

extension TideTypeExtension on TideType {
  String get label {
    switch (this) {
      case TideType.high:
        return 'Maré Alta';
      case TideType.low:
        return 'Maré Baixa';
    }
  }
}







