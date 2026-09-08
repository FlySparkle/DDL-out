import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_markdown_plus_latex/flutter_markdown_plus_latex.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown/markdown.dart' as md;

import '../../../../app/navigation/app_navigation_shell.dart';
import '../../../../core/links/external_link_launcher.dart';
import '../../../../data/task_details/task_detail_document.dart';
import '../../../../l10n/app_localizations.dart';

/// Uses the same parser extensions for rendering and outline extraction.
md.ExtensionSet taskMarkdownExtensions() => md.ExtensionSet(
  [_MultilineLatexSyntax(), ...md.ExtensionSet.gitHubFlavored.blockSyntaxes],
  [_InlineLatexSyntax(), ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes],
);

// Compatibility for standalone \\[ ... \\] delimiters and formulas next to CJK
// text. Parsing the equation and rendering TeX remain library responsibilities.
class _MultilineLatexSyntax extends LatexBlockSyntax {
  @override
  RegExp get pattern => RegExp(
    r'^(?:(\${1,2}|\\\[|\\\])(?:\n|$))|(?:(?:\\\[(.+)\\\])(?:\n|$))',
    multiLine: true,
  );
}

class _InlineLatexSyntax extends md.InlineSyntax {
  _InlineLatexSyntax()
    : super(
        r'(\$\$(?:\\.|[^\n])*?\$\$|\$(?!\s)(?:\\.|[^$\\\n])+?\$|\\\((?:\\.|[^\n])*?\\\)|\\\[(?:\\.|[^\n])*?\\\])',
      );
  final _delegate = LatexInlineSyntax();

  @override
  bool onMatch(md.InlineParser parser, Match match) =>
      _delegate.onMatch(parser, match);
}

String taskMarkdownSource(TaskDetailDocument document) => document.blocks
    .map(
      (block) => switch (block) {
        TaskDetailTextBlock(:final text) => text,
        TaskDetailImageBlock(:final image) =>
          '\n\n![](${TaskDetailDocumentCodec.imageSourceFor(image.id)})\n\n',
      },
    )
    .join();

class TaskMarkdownHeading {
  TaskMarkdownHeading(this.level, this.title);
  final int level;
  final String title;
  final key = GlobalKey();
}

List<TaskMarkdownHeading> taskMarkdownHeadings(String source) {
  final nodes = md.Document(
    extensionSet: taskMarkdownExtensions(),
    encodeHtml: false,
  ).parseLines(source.split('\n'));
  final headings = <TaskMarkdownHeading>[];
  void visit(md.Node node) {
    if (node is! md.Element) return;
    if (RegExp(r'^h[1-6]$').hasMatch(node.tag)) {
      headings.add(
        TaskMarkdownHeading(int.parse(node.tag[1]), node.textContent),
      );
    }
    for (final child in node.children ?? <md.Node>[]) {
      visit(child);
    }
  }

  for (final node in nodes) {
    visit(node);
  }
  return headings;
}

class TaskMarkdownPreview extends ConsumerWidget {
  const TaskMarkdownPreview({required this.document, this.headings, super.key});
  final TaskDetailDocument document;
  final List<TaskMarkdownHeading>? headings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headingBuilder = headings == null ? null : _HeadingBuilder(headings!);
    final l10n = AppLocalizations.of(context);
    return MarkdownBody(
      key: const ValueKey('task-markdown-body'),
      data: taskMarkdownSource(document),
      selectable: true,
      fitContent: false,
      extensionSet: taskMarkdownExtensions(),
      builders: {
        'latex': LatexElementBuilder(
          textStyle: Theme.of(context).textTheme.bodyMedium,
        ),
        if (headingBuilder != null)
          for (var level = 1; level <= 6; level++) 'h$level': headingBuilder,
      },
      onTapLink: (_, href, _) {
        final uri = href == null ? null : Uri.tryParse(href);
        if (uri != null) openExternalLink(context, ref, uri);
      },
      imageBuilder: (uri, title, alt) {
        final id = TaskDetailDocumentCodec.imageIdFromSource(uri.toString());
        final image = document.images
            .where((image) => image.id == id)
            .firstOrNull;
        if (image == null) {
          // Preview stays offline; external images can be opened explicitly.
          return TextButton.icon(
            icon: const Icon(Icons.image_outlined),
            label: Text(alt ?? l10n.markdownImageUnavailable),
            onPressed: uri.scheme == 'https' || uri.scheme == 'http'
                ? () => openExternalLink(context, ref, uri)
                : null,
          );
        }
        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 480),
          child: Image.memory(
            image.bytes,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Text(l10n.markdownImageUnavailable),
          ),
        );
      },
    );
  }
}

class _HeadingBuilder extends MarkdownElementBuilder {
  _HeadingBuilder(this.headings);
  final List<TaskMarkdownHeading> headings;
  int _index = 0;

  @override
  bool isBlockElement() => true;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    if (_index >= headings.length) return null;
    final heading = headings[_index++];
    return Semantics(
      key: heading.key,
      header: true,
      child: _RenderedHeading(element: element),
    );
  }
}

/// Render the original heading AST through the library so emphasis, links and
/// formulas retain the same appearance in preview and full-screen reading.
class _RenderedHeading extends ConsumerStatefulWidget {
  const _RenderedHeading({required this.element});
  final md.Element element;

  @override
  ConsumerState<_RenderedHeading> createState() => _RenderedHeadingState();
}

class _RenderedHeadingState extends ConsumerState<_RenderedHeading>
    implements MarkdownBuilderDelegate {
  final _recognizers = <TapGestureRecognizer>[];

  void _clearRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _clearRecognizers();
    super.dispose();
  }

  @override
  GestureRecognizer createLink(String text, String? href, String title) {
    final recognizer = TapGestureRecognizer()
      ..onTap = () {
        final uri = href == null ? null : Uri.tryParse(href);
        if (uri != null) openExternalLink(context, ref, uri);
      };
    _recognizers.add(recognizer);
    return recognizer;
  }

  @override
  TextSpan formatText(MarkdownStyleSheet styleSheet, String code) =>
      TextSpan(text: code, style: styleSheet.code);

  @override
  Widget build(BuildContext context) {
    _clearRecognizers();
    final style = MarkdownStyleSheet.fromTheme(Theme.of(context));
    final builder = MarkdownBuilder(
      delegate: this,
      selectable: true,
      styleSheet: style,
      imageDirectory: null,
      imageBuilder: (_, _, alt) => Text(alt ?? ''),
      checkboxBuilder: null,
      bulletBuilder: null,
      builders: {
        'latex': LatexElementBuilder(
          textStyle: style.styles[widget.element.tag],
        ),
      },
      paddingBuilders: {},
      listItemCrossAxisAlignment: MarkdownListItemCrossAxisAlignment.baseline,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: builder.build([widget.element]),
    );
  }
}

class TaskMarkdownPage extends StatefulWidget {
  const TaskMarkdownPage({
    required this.title,
    required this.document,
    super.key,
  });
  final String title;
  final TaskDetailDocument document;

  @override
  State<TaskMarkdownPage> createState() => _TaskMarkdownPageState();
}

class _TaskMarkdownPageState extends State<TaskMarkdownPage> {
  final _scaffold = GlobalKey<ScaffoldState>();
  final _scroll = ScrollController();
  late final _headings = taskMarkdownHeadings(
    taskMarkdownSource(widget.document),
  );
  bool _showOutline = true;
  bool _openedInitialOutline = false;
  int? _selected;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_openedInitialOutline) return;
    _openedInitialOutline = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          !AppNavigationLayout.canUseFixed(MediaQuery.sizeOf(context).width)) {
        _scaffold.currentState?.openDrawer();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _jump(int index, bool wide) {
    if (!wide) _scaffold.currentState?.closeDrawer();
    final target = _headings[index].key.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: AppNavigationLayout.expansionDuration,
        curve: Curves.easeInOutCubicEmphasized,
        alignment: 0,
      );
    }
    setState(() => _selected = index);
  }

  Widget _outline(bool wide) {
    final l10n = AppLocalizations.of(context);
    return Material(
      key: const ValueKey('markdown-outline'),
      color: AppNavigationVisuals.backgroundColor(context),
      shape: AppNavigationVisuals.navigationShape,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: AppNavigationLayout.expandedWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.markdownOutline,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: _headings.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(l10n.markdownNoHeadings),
                    )
                  : ListView.builder(
                      itemCount: _headings.length,
                      itemBuilder: (context, index) {
                        final heading = _headings[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            left: 8 + (heading.level - 1) * 12,
                            right: 8,
                            bottom: 4,
                          ),
                          child: ListTile(
                            key: ValueKey('markdown-outline-$index'),
                            shape: const StadiumBorder(),
                            selected: _selected == index,
                            selectedTileColor: Theme.of(
                              context,
                            ).colorScheme.secondaryContainer,
                            title: Text(
                              heading.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _jump(index, wide),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = AppNavigationLayout.canUseFixed(constraints.maxWidth);
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): () {
              if (_scaffold.currentState?.isDrawerOpen ?? false) {
                _scaffold.currentState!.closeDrawer();
              } else {
                Navigator.of(context).pop();
              }
            },
          },
          child: Focus(
            autofocus: true,
            child: Scaffold(
              key: _scaffold,
              appBar: AppBar(
                title: Text(
                  widget.title.isEmpty ? l10n.taskDetailsSection : widget.title,
                ),
                leading: IconButton(
                  icon: const Icon(Icons.fullscreen_exit),
                  tooltip: l10n.exitMarkdownFullscreen,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.toc),
                    tooltip: l10n.markdownOutline,
                    onPressed: () {
                      if (wide) {
                        setState(() => _showOutline = !_showOutline);
                      } else {
                        _scaffold.currentState?.openDrawer();
                      }
                    },
                  ),
                ],
              ),
              drawer: wide
                  ? null
                  : Drawer(
                      width: AppNavigationLayout.expandedWidth,
                      child: SafeArea(child: _outline(false)),
                    ),
              body: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (wide && _showOutline)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                        child: _outline(true),
                      ),
                    Expanded(
                      child: Scrollbar(
                        controller: _scroll,
                        child: SingleChildScrollView(
                          key: const ValueKey('markdown-reader-scroll'),
                          controller: _scroll,
                          padding: const EdgeInsets.all(24),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 900),
                              child: TaskMarkdownPreview(
                                document: widget.document,
                                headings: _headings,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
