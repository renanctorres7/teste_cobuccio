import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:teste_cobuccio/app/core/domain/money.dart';

class PeriodTotalsChart extends StatelessWidget {
  const PeriodTotalsChart({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
  });

  final Money totalIncome;
  final Money totalExpense;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 180,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      return Text(
                        value == 0 ? 'Entradas' : 'Saídas',
                        style: Theme.of(context).textTheme.labelMedium,
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: totalIncome.asReais
                          .clamp(0, double.infinity)
                          .toDouble(),
                      color: colorScheme.primary,
                      width: 28,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: totalExpense.asReais
                          .clamp(0, double.infinity)
                          .toDouble(),
                      color: colorScheme.error,
                      width: 28,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
