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
  double? _selectedPresetPrice;
  int? _discount;
  double? _finalPrice;
  Timer? _historySaveTimer;

  final List<double> _presetPrices = _generatePresetPrices();

  static List<double> _generatePresetPrices() {
    final List<double> prices = [];
    for (double i = 5; i <= 100; i += 5) {
      prices.add(i);
    }
    for (double i = 110; i <= 500; i += 10) {
      prices.add(i);
    }
    for (double i = 550; i <= 1000; i += 50) {
      prices.add(i);
    }
    for (double i = 1100; i <= 5000; i += 100) {
      prices.add(i);
    }
    return prices;
  }

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
    _selectedPresetPrice = _findPresetPrice(_price);
    _calculateFinalPrice();
  }

  double? _findPresetPrice(double? price) {
    if (price == null) return null;

    for (final presetPrice in _presetPrices) {
      if ((presetPrice - price).abs() < 0.001) {
        return presetPrice;
      }
    }
    return null;
  }

  void _selectPresetPrice(double? price) {
    if (price == null) return;

    _priceController.text = price.toStringAsFixed(2);
    _priceController.selection = TextSelection.collapsed(
      offset: _priceController.text.length,
    );
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
      _selectedPresetPrice = null;
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
        title: const Text('Price Calculator'),
        actions: [
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.clear),
            onPressed: _clearAll,
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildAmountCard(),
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

  Widget _buildAmountCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount',
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
              decoration: InputDecoration(
                prefixText: '\$',
                hintText: 'Enter amount',
                suffixIcon: IconButton(
                  tooltip: 'Done',
                  icon: const Icon(Icons.keyboard_hide),
                  onPressed: () =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ),
              ),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<double>(
              value: _selectedPresetPrice,
              hint: const Text('Select a preset amount'),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.list_alt),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: _presetPrices.map((price) {
                return DropdownMenuItem<double>(
                  value: price,
                  child: Text(price.toStringAsFixed(2)),
                );
              }).toList(),
              onChanged: _selectPresetPrice,
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
