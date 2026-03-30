import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_app/theme/app_theme.dart';
import 'package:study_app/widgets/custom_card.dart';
import 'package:study_app/providers/academic_provider.dart';
import 'package:study_app/models/academic/subject_attendance.dart';
import 'package:study_app/screens/academic/subject_attendance_detail.dart';
import 'package:study_app/screens/academic/timetable_page.dart';

class AcademicPage extends StatelessWidget {
  const AcademicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'Timetable',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimetablePage())),
          ),
        ],
      ),
      body: Consumer<AcademicProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildDashboard(context, provider),
              const SizedBox(height: 16),
              _buildTodayClasses(context, provider),
              const SizedBox(height: 16),
              Text('Subjects', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (provider.subjects.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No academic subjects yet. Add one!')))
              else
                ...provider.subjects.map((s) => _buildSubjectTile(context, provider, s)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => _showAddSubjectDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, AcademicProvider provider) {
    return Row(
      children: [
        Expanded(child: _statCard(context, 'Subjects', '${provider.subjects.length}', AppTheme.primaryColor)),
        const SizedBox(width: 8),
        Expanded(child: _statCard(context, 'Overall', '${provider.overallAttendance.toStringAsFixed(provider.overallAttendance % 1 == 0 ? 0 : 1)}%', AppTheme.success)),
        const SizedBox(width: 8),
        Expanded(child: _statCard(context, 'At Risk', '${provider.subjectsAtRisk}', AppTheme.error)),
        const SizedBox(width: 8),
        Expanded(child: _statCard(context, 'Missed', '${provider.missedThisMonth}', AppTheme.warning)),
      ],
    );
  }

  Widget _statCard(BuildContext context, String label, String value, Color color) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildTodayClasses(BuildContext context, AcademicProvider provider) {
    final today = DateTime.now().weekday; // 1=Mon, 7=Sun
    final todaySchedule = provider.getScheduleForDay(today);
    if (todaySchedule.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Today's Classes", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...todaySchedule.map((sched) {
          final subName = provider.getSubjectName(sched.subjectId) ?? 'Unknown';
          return CustomCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule, color: AppTheme.primaryColor),
              title: Text(subName),
              subtitle: Text('${sched.startTime} – ${sched.endTime}${sched.room != null && sched.room!.isNotEmpty ? '  •  ${sched.room}' : ''}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline, color: AppTheme.success),
                    onPressed: () => provider.markAttendance(sched.subjectId, 'present'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined, color: AppTheme.error),
                    onPressed: () => provider.markAttendance(sched.subjectId, 'absent'),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSubjectTile(BuildContext context, AcademicProvider provider, SubjectAttendance subject) {
    final pct = subject.attendancePercentage;
    final color = subject.isSafe ? AppTheme.success : AppTheme.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomCard(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectAttendanceDetail(subjectId: subject.id))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(subject.subjectName, style: Theme.of(context).textTheme.titleLarge)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${pct.toStringAsFixed(pct % 1 == 0 ? 0 : 1)}%',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: subject.totalClasses == 0 ? 1.0 : pct / 100,
                backgroundColor: Colors.grey.shade300,
                color: color,
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('${subject.attendedClasses}/${subject.totalClasses} classes', style: Theme.of(context).textTheme.bodyMedium),
                const Spacer(),
                if (!subject.isSafe)
                  Row(children: [
                    const Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 16),
                    const SizedBox(width: 4),
                    Text('Below ${subject.requiredPercentage.toStringAsFixed(0)}%', style: const TextStyle(color: AppTheme.warning, fontSize: 12)),
                  ])
                else if (subject.classesCanMiss > 0)
                  Text('Can miss ${subject.classesCanMiss} more', style: TextStyle(color: AppTheme.success, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => provider.markAttendance(subject.id, 'present'),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Present'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.success),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => provider.markAttendance(subject.id, 'absent'),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Absent'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final pctCtrl = TextEditingController(text: '75');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Academic Subject'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Subject Name'), autofocus: true),
            const SizedBox(height: 8),
            TextField(controller: pctCtrl, decoration: const InputDecoration(labelText: 'Required Attendance %'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                final pct = double.tryParse(pctCtrl.text) ?? 75.0;
                Provider.of<AcademicProvider>(ctx, listen: false).addSubject(nameCtrl.text, pct);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
