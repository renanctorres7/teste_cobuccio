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
    final textTheme = Theme.of(context).textTheme;
    final textScaler = MediaQuery.textScalerOf(context);
    final chartHeight = textScaler.scale(180);
    final bottomReserved = textScaler.scale(48);
    final incomeFormatted = totalIncome.format();
    final expenseFormatted = totalExpense.format();
    final incomeY = totalIncome.asReais.clamp(0, double.infinity).toDouble();
    final expenseY = totalExpense.asReais.clamp(0, double.infinity).toDouble();

    return Semantics(
      label: 'Entradas $incomeFormatted, Saídas $expenseFormatted',
      container: true,
      child: SizedBox(
        height: chartHeight,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          child: ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                        reservedSize: bottomReserved,
                        getTitlesWidget: (value, meta) {
                          final isIncome = value == 0;
                          return SideTitleWidget(
                            meta: meta,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isIncome
                                        ? incomeFormatted
                                        : expenseFormatted,
                                    style: textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    isIncome ? 'Entradas' : 'Saídas',
                                    style: textTheme.labelMedium,
                                  ),
                                ],
                              ),
                            ),
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
                          toY: incomeY,
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
                          toY: expenseY,
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
        ),
      ),
    );
  }
}
