import 'package:discount_scanner/widgets/themed_scaffold.dart';
import 'package:flutter/material.dart';

class HowToScreen extends StatelessWidget {
  const HowToScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: AppBar(
        title: const Text('How to Use'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildSection(
            context,
            icon: Icons.camera_alt,
            title: 'Scan Price Tag',
            description:
                'Tap the "Scan Price Tag" button on the home screen to open the camera. Point your camera at a price tag. The app will automatically detect the price and any discount percentage.',
          ),
          _buildSection(
            context,
            icon: Icons.edit,
            title: 'Enter Price Manually',
            description:
                'If the app can\'t detect the discount, or if you want to enter the price and discount manually, tap the "Enter Price Manually" button. You can then type in the price and select a discount.',
          ),
          _buildSection(
            context,
            icon: Icons.calculate,
            title: 'Calculator',
            description:
                'The "Calculator" button allows you to quickly calculate a discount without using the camera. Simply select a price and a discount percentage to see the final price.',
          ),
          _buildSection(
            context,
            icon: Icons.history,
            title: 'History',
            description:
                'The app saves all your calculations. You can view them by tapping the "History" button. You can also clear the history from this screen.',
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required IconData icon,
      required String title,
      required String description}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}