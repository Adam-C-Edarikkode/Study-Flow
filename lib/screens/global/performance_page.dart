import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:study_app/theme/app_theme.dart';
import 'package:study_app/widgets/custom_card.dart';
import 'package:study_app/providers/study_provider.dart';
import 'package:study_app/providers/subject_provider.dart';

class PerformancePage extends StatelessWidget {
  const PerformancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Analytics'),
      ),
      body: Consumer<StudyProvider>(
        builder: (context, studyProvider, child) {
          final weeklyData = studyProvider.getWeeklyStudyData();
          final totalThisWeek = weeklyData.fold(0, (sum, val) => sum + val);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CustomCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total This Week:', style: Theme.of(context).textTheme.titleLarge),
                      Text('${totalThisWeek ~/ 60}h ${totalThisWeek % 60}m', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.primaryColor)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildWeeklyTrendCard(context, weeklyData),
              const SizedBox(height: 16),
              _buildSubjectDistributionCard(context, studyProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWeeklyTrendCard(BuildContext context, List<int> weeklyData) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Study Time',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(days[value.toInt()]);
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(7, (index) {
                      return FlSpot(index.toDouble(), weeklyData[index].toDouble());
                    }),
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 4,
                    dotData: const FlDotData(show: true), // Show dots so users can see zeros easily
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryColor.withAlpha(51),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectDistributionCard(BuildContext context, StudyProvider studyProvider) {
    return Consumer<SubjectProvider>(
      builder: (context, subjectProvider, child) {
        final distribution = studyProvider.getSubjectDistribution();
        final total = distribution.values.fold(0, (sum, val) => sum + val);

        if (total == 0 || distribution.isEmpty) {
          return CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Subject Distribution', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 24),
                const Center(child: Text('No study data recorded yet.')),
              ],
            ),
          );
        }

        final List<PieChartSectionData> sections = [];
        final List<Widget> legendItems = [];
        int colorIdx = 0;
        final List<Color> palette = [
          AppTheme.cardGradient1.colors.first,
          AppTheme.cardGradient2.colors.first,
          AppTheme.cardGradient3.colors.first,
          Colors.redAccent,
          Colors.purpleAccent
        ];

        distribution.forEach((subId, duration) {
          final subject = subjectProvider.subjects.firstWhere((s) => s.id == subId, orElse: () => throw Exception('Subject not found'));
          final percentage = (duration / total) * 100;
          final color = palette[colorIdx % palette.length];

          sections.add(
            PieChartSectionData(
              color: color,
              value: percentage,
              title: '${percentage.toStringAsFixed(0)}%',
              radius: 50,
              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )
          );

          legendItems.add(
            Padding(
              padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
              child: _buildLegend(subject.name, color),
            )
          );
          colorIdx++;
        });

        return CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Subject Distribution',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: sections,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                children: legendItems,
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegend(String title, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
