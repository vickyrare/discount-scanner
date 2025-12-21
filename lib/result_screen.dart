import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final double price;
  final double discount;

  const ResultScreen({super.key, required this.price, required this.discount});

  @override
  Widget build(BuildContext context) {
    final double discountedPrice = price - (price * (discount / 100));

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
              price: price,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            _buildPriceCard(
              title: 'Discount',
              price: discount,
              isPercentage: true,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            const Icon(Icons.arrow_downward, size: 40, color: Colors.grey),
            const SizedBox(height: 20),
            _buildPriceCard(
              title: 'Final Price',
              price: discountedPrice,
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
                  : '\$${price.toStringAsFixed(2)}',
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
