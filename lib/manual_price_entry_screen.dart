import 'dart:async';

import 'package:discount_scanner/app_theme.dart';
import 'package:discount_scanner/services/history_service.dart';
import 'package:discount_scanner/widgets/discount_selector.dart';
import 'package:discount_scanner/widgets/themed_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ManualPriceEntryScreen extends StatefulWidget {
  final double? initialPrice;
  const ManualPriceEntryScreen({super.key, this.initialPrice});

  @override
  State<ManualPriceEntryScreen> createState() => _ManualPriceEntryScreenState();
}

class _ManualPriceEntryScreenState extends State<ManualPriceEntryScreen> {
  late final TextEditingController _priceController;
  double? _price;
  int? _discount;
  double? _finalPrice;
  Timer? _historySaveTimer;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.initialPrice?.toStringAsFixed(2),
    );
    _price = widget.initialPrice;
    _priceController.addListener(_updatePrice);
  }

  void _updatePrice() {
    _price = double.tryParse(_priceController.text);
    _calculateFinalPrice();
  }

  void _selectDiscount(int discount) {
    _discount = discount;
    _calculateFinalPrice();
  }

  void _calculateFinalPrice() {
    if (_price != null && _discount != null) {
      final finalPriceValue = _price! - (_price! * (_discount! / 100));
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
    final price = _price!;
    final discount = _discount!;

    _historySaveTimer = Timer(const Duration(milliseconds: 700), () {
      HistoryService.addCalculation(
        price: price,
        discount: discount.toDouble(),
        finalPrice: finalPriceValue,
      );
    });
  }

  void _clearAll() {
    _priceController.clear();
    setState(() {
      _price = null;
      _discount = null;
      _finalPrice = null;
    });
  }

  @override
  void dispose() {
    _historySaveTimer?.cancel();
    _priceController.removeListener(_updatePrice);
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: AppBar(
        title: const Text('Manual Calculation'),
        actions: [
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.clear),
            onPressed: _clearAll,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildPriceInputCard(),
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
              selectedDiscount: _discount,
              onSelected: _selectDiscount,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.navy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.edit_note, color: AppTheme.amber, size: 38),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Enter any price and tap a discount.',
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

  Widget _buildPriceInputCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Original Price',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                prefixText: '\$',
                hintText: 'Enter price',
              ),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalPriceDisplay(double finalPrice) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.teal,
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
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
