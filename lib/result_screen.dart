import 'package:discount_scanner/app_theme.dart';
import 'package:discount_scanner/services/history_service.dart';
import 'package:discount_scanner/widgets/themed_scaffold.dart';
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
    return ThemedScaffold(
      appBar: AppBar(title: const Text('Discounted Price')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildHeroResult(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPriceCard(
                    title: 'Original',
                    price: widget.price,
                    icon: Icons.sell_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPriceCard(
                    title: 'Discount',
                    price: widget.discount,
                    icon: Icons.percent,
                    isPercentage: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroResult() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.navy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.check, color: AppTheme.amber, size: 34),
          ),
          const SizedBox(height: 18),
          const Text(
            'Final Price',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _finalPrice.toStringAsFixed(2),
            style: const TextStyle(
              color: AppTheme.amber,
              fontSize: 56,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard({
    required String title,
    required double price,
    required IconData icon,
    bool isPercentage = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(
              isPercentage
                  ? '${price.toStringAsFixed(0)}%'
                  : price.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
