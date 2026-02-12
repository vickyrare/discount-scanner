import 'package:discount_scanner/services/history_service.dart';
import 'package:discount_scanner/widgets/themed_scaffold.dart';
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
      final finalPriceValue =
          _selectedPrice! - (_selectedPrice! * (_selectedDiscount! / 100));
      setState(() {
        _finalPrice = finalPriceValue;
      });
      HistoryService.addCalculation(
        price: _selectedPrice!,
        discount: _selectedDiscount!.toDouble(),
        finalPrice: finalPriceValue,
      );
    } else {
      setState(() {
        _finalPrice = null;
      });
    }
  }

  void _selectDiscount(int discount) {
    setState(() {
      _selectedDiscount = _selectedDiscount == discount ? null : discount;
      _calculateFinalPrice();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: AppBar(
        title: const Text('Discount Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDropdownCard(
              label: 'Original Price',
              child: DropdownButtonFormField<double>(
                value: _selectedPrice,
                hint: const Text('Select Price'),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                items: _prices.map((price) {
                  return DropdownMenuItem<double>(
                    value: price,
                    child: Text('${price.toStringAsFixed(2)}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPrice = value;
                  });
                  _calculateFinalPrice();
                },
              ),
            ),
            const SizedBox(height: 20),
            _buildDiscountSelector(),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 30),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _finalPrice != null
                  ? _buildFinalPriceDisplay(_finalPrice!)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 12),
          child: Text(
            'Select Discount:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          children: _discounts.map((discount) {
            final isSelected = _selectedDiscount == discount;
            return ChoiceChip(
              label: Text('$discount%'),
              selected: isSelected,
              onSelected: (selected) {
                _selectDiscount(discount);
              },
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              selectedColor: Theme.of(context).primaryColor,
              backgroundColor: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300]!,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDropdownCard({required String label, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildFinalPriceDisplay(double finalPrice) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Final Price',
              style: TextStyle(
                fontSize: 24,
                color: Colors.green,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${finalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
