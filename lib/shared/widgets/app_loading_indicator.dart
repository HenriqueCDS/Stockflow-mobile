// Novo – não existe no React como componente Flutter
import 'package:flutter/material.dart';
import 'package:homestock_mobile/core/theme/hs_colors.dart';

class AppLoadingIndicator extends StatelessWidget {
  final String? text;
  const AppLoadingIndicator({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: context.hs.primary,
            strokeWidth: 2.5,
          ),
          if (text != null) ...[
            const SizedBox(height: 16),
            Text(
              text!,
              style: TextStyle(
                color: context.hs.text2,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
