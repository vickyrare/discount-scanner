import 'package:discount_scanner/app_theme.dart';
import 'package:discount_scanner/services/history_service.dart';
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
  double? _discount;
  double? _finalPrice;

  final List<int> _discounts = List.generate(19, (index) => (index + 1) * 5);

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
    setState(() {
      _price = double.tryParse(_priceController.text);
      _calculateFinalPrice();
    });
  }

  void _selectDiscount(double discount) {
    setState(() {
      _discount = _discount == discount ? null : discount;
      _calculateFinalPrice();
    });
  }

  void _calculateFinalPrice() {
    if (_price != null && _discount != null) {
      final finalPriceValue = _price! - (_price! * (_discount! / 100));
      setState(() {
        _finalPrice = finalPriceValue;
      });
      HistoryService.addCalculation(
        price: _price!,
        discount: _discount!,
        finalPrice: finalPriceValue,
      );
    } else {
      setState(() {
        _finalPrice = null;
      });
    }
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
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _finalPrice != null
                  ? _buildFinalPriceDisplay(_finalPrice!)
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            _buildDiscountSelector(),
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
        padding: const EdgeInsets.all(20),
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
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
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
            final isSelected = _discount == discount.toDouble();
            return SizedBox(
              width: 68,
              child: ChoiceChip(
                label: Center(child: Text('$discount%')),
                selected: isSelected,
                onSelected: (selected) {
                  _selectDiscount(discount.toDouble());
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
}
