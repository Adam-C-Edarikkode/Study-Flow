import 'package:study_app/models/timestamp.dart';

extension TimestampMapper on Timestamp {
  Map<String, dynamic> toMap() => {
        'id': id,
        'videoId': videoId,
        'label': label,
        'seconds': seconds,
      };
}

extension TimestampFromMap on Map<String, dynamic> {
  Timestamp toTimestamp() => Timestamp(
        id: this['id'] as String,
        videoId: this['videoId'] as String,
        label: this['label'] as String,
        seconds: this['seconds'] as int,
      );
}
