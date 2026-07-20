import 'package:flutter/material.dart';
import 'package:memory_compass/features/tags/presentation/widgets/tag_color_picker.dart';

class TagFormResult {
  const TagFormResult({required this.name, required this.color});

  final String name;
  final Color color;
}

/// Shared name + color form used both to create a new tag and to rename or
/// recolor an existing one. Returns null via [Navigator.pop] on cancel.
class TagFormDialog extends StatefulWidget {
  const TagFormDialog({
    super.key,
    required this.title,
    this.initialName = '',
    this.initialColor = kDefaultTagColor,
  });

  final String title;
  final String initialName;
  final Color initialColor;

  @override
  State<TagFormDialog> createState() => _TagFormDialogState();
}

class _TagFormDialogState extends State<TagFormDialog> {
  late final _nameController = TextEditingController(text: widget.initialName);
  late Color _color = widget.initialColor;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(TagFormResult(name: name, color: _color));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Tag name'),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            Text('Color', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TagColorPicker(
              selectedColor: _color,
              onColorSelected: (color) => setState(() => _color = color),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
