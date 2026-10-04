import 'package:ddl_out/data/task_details/task_detail_document.dart';
import 'package:ddl_out/features/board/presentation/widgets/task_markdown_preview.dart';
import 'package:ddl_out/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;

Widget _app(Widget child) => ProviderScope(
  child: MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  ),
);

void main() {
  test(
    'LaTeX recognizes CJK adjacency and multiline delimiters but not code',
    () {
      const source = r'''中文$x^2$公式，\(a+b\)结束。

\[
\frac{1}{2}
\]

`$code$`

```tex
$literal$
```
''';
      final nodes = md.Document(
        extensionSet: taskMarkdownExtensions(),
      ).parseLines(source.split('\n'));
      final equations = <String>[];
      void visit(md.Node node) {
        if (node is md.Element) {
          if (node.tag == 'latex') equations.add(node.textContent);
          for (final child in node.children ?? <md.Node>[]) {
            visit(child);
          }
        }
      }

      for (final node in nodes) {
        visit(node);
      }
      expect(equations, [r'x^2', 'a+b', r'\frac{1}{2}']);
    },
  );
  test('outline uses Markdown headings including setext and excludes code', () {
    final headings = taskMarkdownHeadings(
      '# Top\n\n## **Child**\n\n```md\n# Code\n```\n\nSetext\n---\n\n## Child',
    );
    expect(headings.map((h) => h.level), [1, 2, 2, 2]);
    expect(headings.map((h) => h.title), ['Top', 'Child', 'Setext', 'Child']);
    expect(headings.map((h) => h.key).toSet(), hasLength(4));
  });

  testWidgets('renders GFM and inline and block LaTeX offline', (tester) async {
    const source = r'''
# Heading

**Bold** and $x^2 + y^2 = z^2$.

$$
\frac{1}{2} + \sqrt{x}
$$

\(a+b\) and \[ c=d \]

| A | B |
|---|---|
| 1 | 2 |

- [x] Done

```dart
final value = 1;
```
''';
    await tester.pumpWidget(
      _app(
        const SingleChildScrollView(
          child: TaskMarkdownPreview(
            document: TaskDetailDocument([TaskDetailTextBlock(source)]),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Heading'), findsOneWidget);
    expect(find.byType(Table), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop outline jumps to repeated headings and survives resize', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final source =
        '# Repeated\n\n${List.filled(60, 'Paragraph.\n\n').join()}## Repeated\n\nEnd';
    await tester.pumpWidget(
      _app(
        TaskMarkdownPage(
          title: 'Reading',
          document: TaskDetailDocument([TaskDetailTextBlock(source)]),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('markdown-outline')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('markdown-outline-1')));
    await tester.pumpAndSettle();
    final scroll = tester.widget<SingleChildScrollView>(
      find.byKey(const ValueKey('markdown-reader-scroll')),
    );
    expect(scroll.controller!.offset, greaterThan(500));
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(400, 800);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Outline'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('markdown-outline-0')));
    await tester.pumpAndSettle();
    expect(scroll.controller!.offset, closeTo(0, 50));
    expect(tester.takeException(), isNull);
  });
}
