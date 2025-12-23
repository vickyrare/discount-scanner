import 'package:discount_scanner/services/history_service.dart';
import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  final double price;
  final double discount;

  const ResultScreen({super.key, required this.price, required this.discount});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final double _finalPrice;

  @override
  void initState() {
    super.initState();
    _finalPrice = widget.price - (widget.price * (widget.discount / 100));
    HistoryService.addCalculation(
      price: widget.price,
      discount: widget.discount,
      finalPrice: _finalPrice,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discounted Price'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildPriceCard(
              title: 'Original Price',
              price: widget.price,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            _buildPriceCard(
              title: 'Discount',
              price: widget.discount,
              isPercentage: true,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            const Icon(Icons.arrow_downward, size: 40, color: Colors.grey),
            const SizedBox(height: 20),
            _buildPriceCard(
              title: 'Final Price',
              price: _finalPrice,
              color: Colors.green,
              isLarge: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard({
    required String title,
    required double price,
    required Color color,
    bool isPercentage = false,
    bool isLarge = false,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isLarge ? 20 : 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isPercentage
                  ? '${price.toStringAsFixed(0)}%'
                  : '\${price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: isLarge ? 40 : 30,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
