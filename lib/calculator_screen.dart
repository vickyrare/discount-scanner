import 'dart:async';

import 'package:discount_scanner/app_theme.dart';
import 'package:discount_scanner/services/history_service.dart';
import 'package:discount_scanner/widgets/discount_selector.dart';
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
  Timer? _historySaveTimer;

  final List<double> _prices = _generatePrices();

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
      _scheduleHistorySave(finalPriceValue);
    } else {
      _historySaveTimer?.cancel();
      setState(() {
        _finalPrice = null;
      });
    }
  }

  void _scheduleHistorySave(double finalPriceValue) {
    _historySaveTimer?.cancel();
    final price = _selectedPrice!;
    final discount = _selectedDiscount!;

    _historySaveTimer = Timer(const Duration(milliseconds: 700), () {
      HistoryService.addCalculation(
        price: price,
        discount: discount.toDouble(),
        finalPrice: finalPriceValue,
      );
    });
  }

  void _selectDiscount(int discount) {
    _selectedDiscount = discount;
    _calculateFinalPrice();
  }

  @override
  void dispose() {
    _historySaveTimer?.cancel();
    super.dispose();
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
                  _selectedPrice = value;
                  _calculateFinalPrice();
                },
              ),
            ),
            if (_finalPrice != null) ...[
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildFinalPriceDisplay(_finalPrice!),
              ),
              const SizedBox(height: 16),
            ] else
              const SizedBox(height: 8),
            DiscountSelector(
              selectedDiscount: _selectedDiscount,
              onSelected: _selectDiscount,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Text(
              'Final Price',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              finalPrice.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 34,
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
