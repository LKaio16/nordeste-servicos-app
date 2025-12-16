/// Modelo de dados da Tábua de Maré
/// Mapeia o TabelaMareResponse da API
class TideData {
  final String time;
  final String height;
  final TideType type;

  TideData({
    required this.time,
    required this.height,
    required this.type,
  });

  /// Cria um TideData a partir do JSON da API (TabelaMareResponse)
  /// Nota: O tipo (alta/baixa) será determinado depois quando tivermos todos os dados do dia
  factory TideData.fromApiJson(Map<String, dynamic> json) {
    final horario = json['horario']?.toString() ?? '';
    final metro = json['metro']?.toString() ?? '';
    
    // Tenta extrair o valor numérico do metro para determinar o tipo
    double? metroValue;
    try {
      metroValue = double.tryParse(metro.replaceAll(RegExp(r'[^\d.,]'), '').replaceAll(',', '.'));
    } catch (e) {
      metroValue = null;
    }
    
    // Determina se é maré alta ou baixa baseado na altura
    // Normalmente, marés altas têm valores maiores (acima de ~1.8m)
    // e marés baixas têm valores menores (abaixo de ~1.5m)
    TideType tipo;
    if (metroValue != null) {
      // Se o valor for maior ou igual a 1.8m, considera maré alta
      tipo = metroValue >= 1.8 ? TideType.high : TideType.low;
    } else {
      // Se não conseguir parsear, usa uma heurística simples
      // Se contém valores altos como "2", "3", "4", considera alta
      tipo = metro.contains(RegExp(r'[2-9]')) ? TideType.high : TideType.low;
    }
    
    return TideData(
      time: horario,
      height: metro,
      type: tipo,
    );
  }
  
  /// Método estático para processar uma lista de marés e determinar tipos mais precisos
  /// Compara os valores entre si para determinar quais são altas e quais são baixas
  static List<TideData> processTides(List<TideData> tides) {
    if (tides.isEmpty) return tides;
    
    // Extrai valores numéricos
    final values = tides.map((tide) {
      try {
        return double.tryParse(tide.height.replaceAll(RegExp(r'[^\d.,]'), '').replaceAll(',', '.')) ?? 0.0;
      } catch (e) {
        return 0.0;
      }
    }).toList();
    
    // Calcula média e mediana para determinar threshold
    final sortedValues = List<double>.from(values)..sort();
    final median = sortedValues.length % 2 == 0
        ? (sortedValues[sortedValues.length ~/ 2 - 1] + sortedValues[sortedValues.length ~/ 2]) / 2
        : sortedValues[sortedValues.length ~/ 2];
    
    // Usa mediana como threshold: valores acima são maré alta, abaixo são maré baixa
    return tides.asMap().entries.map((entry) {
      final index = entry.key;
      final tide = entry.value;
      final value = values[index];
      
      return TideData(
        time: tide.time,
        height: tide.height,
        type: value >= median ? TideType.high : TideType.low,
      );
    }).toList();
  }

  /// Factory para criar TideData a partir de JSON genérico (mock)
  factory TideData.fromJson(Map<String, dynamic> json) {
    // Se tem campos da API, usa fromApiJson
    if (json.containsKey('horario') || json.containsKey('metro')) {
      return TideData.fromApiJson(json);
    }
    
    return TideData(
      time: json['time'] ?? '',
      height: json['height'] ?? '',
      type: json['type'] == 'high' ? TideType.high : TideType.low,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'horario': time,
      'metro': height,
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







