import 'package:discount_scanner/app_theme.dart';
import 'package:discount_scanner/widgets/themed_scaffold.dart';
import 'package:flutter/material.dart';

class CompanyInfoScreen extends StatelessWidget {
  const CompanyInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ThemedScaffold(
      appBar: AppBar(title: const Text('Company Info')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          _buildCompanyCard(context),
          const SizedBox(height: 14),
          _InfoTile(
            icon: Icons.business,
            label: 'Company',
            value: 'Cistem Code',
            color: colorScheme.primary,
          ),
          _InfoTile(
            icon: Icons.language,
            label: 'Website',
            value: 'https://cistemcode.com',
            color: colorScheme.primary,
          ),
          _InfoTile(
            icon: Icons.alternate_email,
            label: 'Email',
            value: 'info@cistemcode.com',
            color: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.storefront,
                color: colorScheme.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Cistem Code',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.navy,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Independent software company building simple, useful apps for everyday tasks.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        color: colorScheme.surface,
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(label),
          subtitle: SelectableText(value),
        ),
      ),
    );
  }
}
