import 'package:flutter/material.dart';

class TotalCard extends StatelessWidget {
  const TotalCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isHidden,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isHidden;

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
            Icon(icon, color: color, semanticLabel: label),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              isHidden ? r'R$ ••••••' : value,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
