import 'package:flutter/material.dart';

class HelpAndFeedback extends StatelessWidget {
  const HelpAndFeedback({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.titleMedium?.color ?? Colors.black;
    final primary = colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        
      ),
    );
  }
}
