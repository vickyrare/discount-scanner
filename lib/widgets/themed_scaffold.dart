import 'package:discount_scanner/app_theme.dart';
import 'package:discount_scanner/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemedScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final bool extendBodyBehindAppBar;
  final Widget? bottomNavigationBar;

  const ThemedScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.extendBodyBehindAppBar = false,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: appBar,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [
                    AppTheme.darkSurface,
                    Color(0xFF14252A),
                    AppTheme.darkSurface,
                  ]
                : const [
                    AppTheme.mint,
                    AppTheme.lightSurface,
                    AppTheme.lightSurface,
                  ],
          ),
        ),
        child: SafeArea(
          top: appBar == null && !extendBodyBehindAppBar,
          bottom: bottomNavigationBar == null,
          child: body,
        ),
      ),
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      floatingActionButton: FloatingActionButton.small(
        tooltip: 'Toggle theme',
        onPressed: () {
          Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
        },
        child: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
