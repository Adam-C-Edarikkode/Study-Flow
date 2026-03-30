import 'package:hive/hive.dart';

part 'timestamp.g.dart';

@HiveType(typeId: 16)
class Timestamp extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String videoId;

  @HiveField(2)
  final String label;

  @HiveField(3)
  final int seconds;

  Timestamp({
    required this.id,
    required this.videoId,
    required this.label,
    required this.seconds,
  });
}
