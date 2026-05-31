import 'package:discount_scanner/app_theme.dart';
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
      appBar: AppBar(title: const Text('Discount Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
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
                    child: Text(price.toStringAsFixed(2)),
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
            const SizedBox(height: 24),
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

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.speed, color: Colors.white, size: 36),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Quickly compare common shelf discounts.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountSelector() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12),
          child: Text(
            'Select Discount:',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _discounts.map((discount) {
            final isSelected = _selectedDiscount == discount;
            return SizedBox(
              width: 68,
              child: ChoiceChip(
                label: Center(child: Text('$discount%')),
                selected: isSelected,
                onSelected: (selected) {
                  _selectDiscount(discount);
                },
                labelStyle: TextStyle(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
                selectedColor: colorScheme.primary,
                backgroundColor: colorScheme.surface,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDropdownCard({required String label, required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildFinalPriceDisplay(double finalPrice) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.navy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Final Price',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              finalPrice.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.bold,
                color: AppTheme.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
