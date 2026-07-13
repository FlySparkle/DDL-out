import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/time/deadline_service.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/board_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/application/settings_controller.dart';
import 'adaptive_editor.dart';
import 'confirmation_dialog.dart';
import 'editor_frame.dart';

const _presetColors = <Color>[
  Color(0xFF4A90E2),
  Color(0xFF50E3C2),
  Color(0xFF8BC34A),
  Color(0xFFF5A623),
  Color(0xFFFF4D4F),
  Color(0xFF7E57C2),
  Color(0xFFBD10E0),
  Color(0xFF4A4A4A),
];

Future<void> showCategoryEditor(
  BuildContext context, {
  Category? category,
  int taskCount = 0,
}) {
  return showAdaptiveEditor(
    context,
    child: CategoryEditor(category: category, taskCount: taskCount),
  );
}

class CategoryEditor extends ConsumerStatefulWidget {
  const CategoryEditor({
    required this.category,
    required this.taskCount,
    super.key,
  });

  final Category? category;
  final int taskCount;

  @override
  ConsumerState<CategoryEditor> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends ConsumerState<CategoryEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late Color _color;
  bool _showCustom = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _color = Color(
      widget.category?.colorArgb ?? _presetColors.first.toARGB32(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EditorFrame(
      title: widget.category == null ? l10n.newCategory : l10n.editCategory,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              maxLength: 60,
              decoration: InputDecoration(labelText: l10n.categoryName),
              validator: (value) {
                final name = value?.trim() ?? '';
                if (name.isEmpty) return l10n.nameRequired;
                if (name.length > 60) return l10n.nameTooLong;
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(l10n.categoryColor),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in _presetColors)
                  _ColorSwatch(
                    color: value,
                    selected: value.toARGB32() == _color.toARGB32(),
                    onTap: () => setState(() => _color = value),
                  ),
                IconButton.filledTonal(
                  tooltip: l10n.customColor,
                  onPressed: () => setState(() => _showCustom = !_showCustom),
                  icon: const Icon(Icons.colorize),
                ),
              ],
            ),
            if (_showCustom)
              ColorPicker(
                color: _color,
                onColorChanged: (value) => setState(() => _color = value),
                pickersEnabled: const {
                  ColorPickerType.both: false,
                  ColorPickerType.primary: false,
                  ColorPickerType.accent: false,
                  ColorPickerType.bw: false,
                  ColorPickerType.custom: false,
                  ColorPickerType.customSecondary: false,
                  ColorPickerType.wheel: true,
                },
                enableShadesSelection: false,
                showColorCode: true,
                colorCodeHasColor: true,
                wheelDiameter: 180,
                padding: const EdgeInsets.only(top: 16),
              ),
          ],
        ),
      ),
      leadingAction: widget.category == null
          ? null
          : TextButton.icon(
              onPressed: _saving ? null : _delete,
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.delete),
            ),
      primaryAction: FilledButton(
        onPressed: _saving ? null : _save,
        child: Text(l10n.save),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repository = ref.read(categoryRepositoryProvider);
    if (widget.category == null) {
      await repository.create(_nameController.text.trim(), _color.toARGB32());
    } else {
      await repository.update(
        widget.category!,
        _nameController.text.trim(),
        _color.toARGB32(),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmation(
      context,
      title: l10n.deleteCategoryTitle,
      body: l10n.deleteCategoryBody(widget.taskCount),
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(categoryRepositoryProvider).delete(widget.category!.id);
    await ref
        .read(settingsControllerProvider.notifier)
        .removeCategoryPreference(widget.category!.id);
    if (mounted) Navigator.pop(context);
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message:
          '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.transparent,
              width: 3,
            ),
          ),
          child: selected
              ? Icon(
                  Icons.check,
                  color: DeadlineService.readableForeground(color),
                )
              : null,
        ),
      ),
    );
  }
}
