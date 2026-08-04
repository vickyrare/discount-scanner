import 'package:flutter/material.dart';

class DiscountSelector extends StatelessWidget {
  final int? selectedDiscount;
  final ValueChanged<int> onSelected;

  const DiscountSelector({
    super.key,
    required this.selectedDiscount,
    required this.onSelected,
  });

  static const List<int> _popularDiscounts = [
    5,
    10,
    15,
    20,
    25,
    30,
    35,
    40,
    45,
    50,
    55,
    60,
    65,
    70,
    75,
    80,
    85,
    90,
    95,
  ];

  int get _exactValue => selectedDiscount ?? 10;

  void _stepBy(int delta) {
    onSelected((_exactValue + delta).clamp(1, 99));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Popular discounts',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _popularDiscounts.map((discount) {
                final isSelected = selectedDiscount == discount;
                return SizedBox(
                  width: 68,
                  child: ChoiceChip(
                    label: Center(child: Text('$discount%')),
                    selected: isSelected,
                    onSelected: (selected) => onSelected(discount),
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
            const SizedBox(height: 18),
            _buildExactHeader(context),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildStepButton(
                  context,
                  icon: Icons.remove,
                  tooltip: 'Decrease discount',
                  onPressed: _exactValue > 1 ? () => _stepBy(-1) : null,
                ),
                Expanded(
                  child: Slider(
                    value: _exactValue.toDouble(),
                    min: 1,
                    max: 99,
                    divisions: 98,
                    label: '$_exactValue%',
                    onChanged: (value) => onSelected(value.round()),
                  ),
                ),
                _buildStepButton(
                  context,
                  icon: Icons.add,
                  tooltip: 'Increase discount',
                  onPressed: _exactValue < 99 ? () => _stepBy(1) : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExactHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Exact discount',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          width: 64,
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$_exactValue%',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}
