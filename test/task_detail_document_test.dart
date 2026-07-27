import 'dart:typed_data';

import 'package:ddl_out/data/task_details/task_detail_document.dart';
import 'package:ddl_out/data/task_details/task_detail_image.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TaskDetailImage image(String id) => TaskDetailImage(
    id: id,
    mimeType: 'image/png',
    bytes: Uint8List.fromList([1, 2, 3]),
  );

  test('legacy text and attachment images migrate without data loss', () {
    final first = image('first');
    final second = image('second');

    final document = TaskDetailDocumentCodec.decode(
      details: 'Legacy details',
      images: [first, second],
    );

    expect(document.blocks, hasLength(3));
    expect((document.blocks[0] as TaskDetailTextBlock).text, 'Legacy details');
    expect((document.blocks[1] as TaskDetailImageBlock).image.id, 'first');
    expect((document.blocks[2] as TaskDetailImageBlock).image.id, 'second');
  });

  test('interleaved blocks retain their order through persisted fields', () {
    final embedded = image('embedded');
    final source = TaskDetailDocument([
      const TaskDetailTextBlock('Before'),
      TaskDetailImageBlock(embedded),
      const TaskDetailTextBlock('After'),
    ]);

    final details = TaskDetailDocumentCodec.encode(source);
    final restored = TaskDetailDocumentCodec.decode(
      details: details,
      images: [embedded],
    );

    expect(restored.blocks, hasLength(3));
    expect((restored.blocks[0] as TaskDetailTextBlock).text, 'Before');
    expect((restored.blocks[1] as TaskDetailImageBlock).image.id, 'embedded');
    expect((restored.blocks[2] as TaskDetailTextBlock).text, 'After');
    expect(details.split('\n'), hasLength(3));
  });

  test('unreferenced images append after explicitly embedded content', () {
    final embedded = image('embedded');
    final legacy = image('legacy');
    final encoded = TaskDetailDocumentCodec.encode(
      TaskDetailDocument([
        const TaskDetailTextBlock('Text'),
        TaskDetailImageBlock(embedded),
      ]),
    );

    final restored = TaskDetailDocumentCodec.decode(
      details: encoded,
      images: [embedded, legacy],
    );

    expect(
      restored.blocks.whereType<TaskDetailImageBlock>().map(
        (block) => block.image.id,
      ),
      ['embedded', 'legacy'],
    );
  });
}
