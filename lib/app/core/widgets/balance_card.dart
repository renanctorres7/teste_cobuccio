import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.formattedBalance,
    required this.isHidden,
    required this.onToggleVisibility,
  });

  final String formattedBalance;
  final bool isHidden;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Saldo disponível',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  tooltip: isHidden ? 'Exibir saldo' : 'Ocultar saldo',
                  onPressed: onToggleVisibility,
                  icon: Icon(
                    isHidden ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isHidden ? r'R$ ••••••' : formattedBalance,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
