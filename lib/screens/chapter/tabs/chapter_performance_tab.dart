import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:study_app/theme/app_theme.dart';
import 'package:study_app/widgets/custom_card.dart';
import 'package:study_app/providers/study_provider.dart';

class ChapterPerformanceTab extends StatefulWidget {
  final String subjectId;
  final String chapterId;
  const ChapterPerformanceTab({super.key, required this.subjectId, required this.chapterId});

  @override
  State<ChapterPerformanceTab> createState() => _ChapterPerformanceTabState();
}

class _ChapterPerformanceTabState extends State<ChapterPerformanceTab> {
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
    return Consumer<StudyProvider>(
      builder: (context, studyProvider, child) {
        final chartData = studyProvider.getChartData(_selectedRange, chapterId: widget.chapterId);
        final totalForRange = chartData.fold(0, (sum, val) => sum + val);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text('Chapter Analytics', style: Theme.of(context).textTheme.headlineMedium),
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
          ],
        );
      },
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
                    dotData: FlDotData(show: chartData.length <= 7),
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
}
