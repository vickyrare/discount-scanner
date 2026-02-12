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
    _priceController =
        TextEditingController(text: widget.initialPrice?.toStringAsFixed(2));
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
            icon: const Icon(Icons.clear),
            onPressed: _clearAll,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPriceInputCard(),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _finalPrice != null
                  ? _buildFinalPriceDisplay(_finalPrice!)
                  : const SizedBox.shrink(),
            ),
            const Divider(height: 40),
            _buildDiscountSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceInputCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Original Price',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                prefixText: '\$'
,
                border: InputBorder.none,
                hintText: 'Enter price',
              ),
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Final Price',
              style: TextStyle(
                fontSize: 20,
                color: Colors.green,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\${finalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
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
            final isSelected = _discount == discount.toDouble();
            return ChoiceChip(
              label: Text('$discount%'),
              selected: isSelected,
              onSelected: (selected) {
                _selectDiscount(discount.toDouble());
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
}
