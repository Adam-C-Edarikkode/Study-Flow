import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:study_app/theme/app_theme.dart';
import 'package:study_app/widgets/custom_card.dart';
import 'package:study_app/providers/study_provider.dart';
import 'package:study_app/providers/subject_provider.dart';
import 'package:study_app/models/subject.dart';

class PerformancePage extends StatefulWidget {
  const PerformancePage({super.key});

  @override
  State<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
  TimeRange _selectedRange = TimeRange.last7Days;

  String _getRangeString(TimeRange range) {
    switch (range) {
      case TimeRange.today: return 'Today';
      case TimeRange.yesterday: return 'Yesterday';
      case TimeRange.last7Days: return 'Last 7 Days';
      case TimeRange.last30Days: return 'Last 30 Days';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Analytics'),
      ),
      body: Consumer<StudyProvider>(
        builder: (context, studyProvider, child) {
          final chartData = studyProvider.getChartData(_selectedRange);
          final totalForRange = chartData.fold(0, (sum, val) => sum + val);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text('Analytics', style: Theme.of(context).textTheme.headlineMedium),
                   DropdownButton<TimeRange>(
                     value: _selectedRange,
                     items: TimeRange.values.map((r) => DropdownMenuItem(
                       value: r,
                       child: Text(_getRangeString(r)),
                     )).toList(),
                     onChanged: (val) {
                       if (val != null) {
                         setState(() => _selectedRange = val);
                       }
                     },
                   )
                ],
              ),
              const SizedBox(height: 16),
              CustomCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Time:', style: Theme.of(context).textTheme.titleLarge),
                      Text('${totalForRange ~/ 60}h ${totalForRange % 60}m', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.primaryColor)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildTrendCard(context, chartData),
              const SizedBox(height: 16),
              _buildSubjectDistributionCard(context, studyProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTrendCard(BuildContext context, List<int> chartData) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Study Trend',
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
                        if (chartData.length == 7) {
                          final weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          final now = DateTime.now();
                          int daysAgo = 6 - value.toInt();
                          int targetWeekday = now.subtract(Duration(days: daysAgo)).weekday;
                          if (value.toInt() >= 0 && value.toInt() < 7) {
                            return Text(weekDays[targetWeekday - 1]);
                          }
                        } else if (chartData.length == 24) {
                           if (value.toInt() % 6 == 0 && value.toInt() < 24 && value.toInt() >= 0) {
                              return Text('${value.toInt()}h');
                           }
                        } else if (chartData.length == 30) {
                           if (value.toInt() % 7 == 0 && value.toInt() < 30 && value.toInt() >= 0) {
                              return Text('D${value.toInt()+1}');
                           }
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(chartData.length, (index) {
                      return FlSpot(index.toDouble(), chartData[index].toDouble());
                    }),
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 4,
                    dotData: FlDotData(show: chartData.length <= 7), // Only show dots for small datasets
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
        final distribution = studyProvider.getSubjectDistribution(_selectedRange);
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
          final subjectList = subjectProvider.subjects.where((s) => s.id == subId);
          final subject = subjectList.isNotEmpty 
              ? subjectList.first 
              : subId == 'general'
                  ? Subject(id: 'general', name: 'General', colorValue: AppTheme.primaryColor.value, createdDate: DateTime.now())
                  : Subject(id: subId, name: 'Deleted Subject', colorValue: Colors.grey.value, createdDate: DateTime.now());
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
