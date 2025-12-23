import 'package:discount_scanner/services/history_service.dart';
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
      _discount = discount;
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

  @override
  void dispose() {
    _priceController.removeListener(_updatePrice);
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Calculation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center, // Center align vertically
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),
                ),
                if (_finalPrice != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Final Price',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${_finalPrice!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Select Discount:',
                style: TextStyle(fontSize: 18),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 19, // 5, 10, 15, ..., 95
              itemBuilder: (context, index) {
                final discount = (index + 1) * 5;
                final isSelected = _discount == discount.toDouble();
                return ElevatedButton(
                  onPressed: () => _selectDiscount(discount.toDouble()),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10),
                    backgroundColor:
                        isSelected ? Theme.of(context).primaryColor : null,
                    foregroundColor: isSelected ? Colors.white : null,
                  ),
                  child: Text('$discount%'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
