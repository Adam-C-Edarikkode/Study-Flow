import 'package:study_app/models/block.dart';

extension BlockMapper on Block {
  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'content': content,
        'order': order,
        'isChecked': isChecked,
      };
}

extension BlockFromMap on Map<String, dynamic> {
  Block toBlock() => Block(
        id: this['id'] as String,
        type: BlockType.values.firstWhere(
          (e) => e.name == this['type'],
          orElse: () => BlockType.text,
        ),
        content: this['content'] as String,
        order: this['order'] as int,
        isChecked: this['isChecked'] as bool? ?? false,
      );
}
