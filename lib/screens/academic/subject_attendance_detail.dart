import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_app/theme/app_theme.dart';
import 'package:study_app/providers/academic_provider.dart';
import 'package:study_app/models/academic/subject_attendance.dart';
import 'package:intl/intl.dart';

class SubjectAttendanceDetail extends StatelessWidget {
  final String subjectId;
  const SubjectAttendanceDetail({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    return Consumer<AcademicProvider>(
      builder: (context, provider, child) {
        final subject = provider.subjects.cast<SubjectAttendance?>().firstWhere((s) => s?.id == subjectId, orElse: () => null);
        if (subject == null) return const Scaffold(body: Center(child: Text('Subject not found')));

        final records = provider.getRecordsForSubject(subjectId);
        final pct = subject.attendancePercentage;
        final color = subject.isSafe ? AppTheme.success : AppTheme.error;

        return Scaffold(
          appBar: AppBar(
            title: Text(subject.subjectName),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Subject?'),
                      content: const Text('This will delete all attendance records for this subject.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                          onPressed: () {
                            provider.deleteSubject(subjectId);
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Stats header
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text('${pct.toStringAsFixed(pct % 1 == 0 ? 0 : 1)}%', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
                          const SizedBox(height: 4),
                          Text('Attendance', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        _miniStat(context, 'Attended', '${subject.attendedClasses}', AppTheme.success),
                        const SizedBox(height: 8),
                        _miniStat(context, 'Missed', '${subject.missedClasses}', AppTheme.error),
                        const SizedBox(height: 8),
                        _miniStat(context, 'Total', '${subject.totalClasses}', AppTheme.primaryColor),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (subject.isSafe && subject.classesCanMiss > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('✅ You can miss ${subject.classesCanMiss} more classes safely.', style: const TextStyle(color: AppTheme.success)),
                )
              else if (!subject.isSafe)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('⚠️ Attendance is below the required percentage!', style: TextStyle(color: AppTheme.error)),
                ),
              const SizedBox(height: 16),
              Text('History', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (records.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No records yet.')))
              else
                ...records.map((r) => ListTile(
                  leading: Icon(
                    r.status == 'present' ? Icons.check_circle : Icons.cancel,
                    color: r.status == 'present' ? AppTheme.success : AppTheme.error,
                  ),
                  title: Text(r.status == 'present' ? 'Present' : 'Absent'),
                  subtitle: Text(DateFormat('MMM d, yyyy – h:mm a').format(r.date)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => provider.deleteRecord(r.id),
                  ),
                )),
            ],
          ),
        );
      },
    );
  }

  Widget _miniStat(BuildContext context, String label, String value, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('$label: ', style: Theme.of(context).textTheme.bodyMedium),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
