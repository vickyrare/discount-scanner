import 'package:flutter/material.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  double? _selectedPrice;
  int? _selectedDiscount;
  double? _finalPrice;

  final List<double> _prices = _generatePrices();
  final List<int> _discounts = List.generate(19, (index) => (index + 1) * 5);

  static List<double> _generatePrices() {
    final List<double> prices = [];
    // 5 to 100, increments of 5
    for (double i = 5; i <= 100; i += 5) {
      prices.add(i);
    }
    // 110 to 500, increments of 10
    for (double i = 110; i <= 500; i += 10) {
      prices.add(i);
    }
    // 550 to 1000, increments of 50
    for (double i = 550; i <= 1000; i += 50) {
      prices.add(i);
    }
    // 1100 to 5000, increments of 100
    for (double i = 1100; i <= 5000; i += 100) {
      prices.add(i);
    }
    return prices;
  }

  void _calculateFinalPrice() {
    if (_selectedPrice != null && _selectedDiscount != null) {
      setState(() {
        _finalPrice = _selectedPrice! - (_selectedPrice! * (_selectedDiscount! / 100));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discount Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Price Dropdown
            DropdownButtonFormField<double>(
              value: _selectedPrice,
              hint: const Text('Select Price'),
              decoration: const InputDecoration(
                labelText: 'Original Price',
                border: OutlineInputBorder(),
              ),
              items: _prices.map((price) {
                return DropdownMenuItem<double>(
                  value: price,
                  child: Text('\$${price.toStringAsFixed(2)}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPrice = value;
                });
                _calculateFinalPrice();
              },
            ),
            const SizedBox(height: 20),

            // Discount Dropdown
            DropdownButtonFormField<int>(
              value: _selectedDiscount,
              hint: const Text('Select Discount'),
              decoration: const InputDecoration(
                labelText: 'Discount Percentage',
                border: OutlineInputBorder(),
              ),
              items: _discounts.map((discount) {
                return DropdownMenuItem<int>(
                  value: discount,
                  child: Text('$discount%'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDiscount = value;
                });
                _calculateFinalPrice();
              },
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 30),

            // Final Price Display
            if (_finalPrice != null)
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Final Price',
                      style: TextStyle(fontSize: 24, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '\$${_finalPrice!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
