import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CalculationRecord {
  final DateTime date;
  final double price;
  final double discount;
  final double finalPrice;

  CalculationRecord({
    required this.date,
    required this.price,
    required this.discount,
    required this.finalPrice,
  });

  // For serialization
  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'price': price,
        'discount': discount,
        'finalPrice': finalPrice,
      };

  // For deserialization
  factory CalculationRecord.fromJson(Map<String, dynamic> json) =>
      CalculationRecord(
        date: DateTime.parse(json['date']),
        price: json['price'],
        discount: json['discount'],
        finalPrice: json['finalPrice'],
      );

  // Override equals for uniqueness check
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalculationRecord &&
          runtimeType == other.runtimeType &&
          date.year == other.date.year &&
          date.month == other.date.month &&
          date.day == other.date.day &&
          price == other.price &&
          discount == other.discount;

  @override
  int get hashCode => date.year.hashCode ^ date.month.hashCode ^ date.day.hashCode ^ price.hashCode ^ discount.hashCode;
}

class HistoryService {
  static const _historyKey = 'calculation_history';

  static Future<void> addCalculation({
    required double price,
    required double discount,
    required double finalPrice,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final newRecord = CalculationRecord(
      date: DateTime.now(),
      price: price,
      discount: discount,
      finalPrice: finalPrice,
    );

    final history = await getHistory();

    // Add only if it's a unique calculation for the day
    if (!history.contains(newRecord)) {
      history.insert(0, newRecord); // Add to the top of the list
      final List<String> historyJson =
          history.map((record) => json.encode(record.toJson())).toList();
      await prefs.setStringList(_historyKey, historyJson);
    }
  }

  static Future<List<CalculationRecord>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? historyJson = prefs.getStringList(_historyKey);

    if (historyJson == null) {
      return [];
    }

    return historyJson
        .map((recordJson) =>
            CalculationRecord.fromJson(json.decode(recordJson)))
        .toList();
  }
  
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
