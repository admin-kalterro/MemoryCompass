import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:memory_compass/core/di/providers.dart';
import 'package:memory_compass/core/theme/app_theme.dart';
import 'package:memory_compass/core/widgets/status_pill.dart';
import 'package:memory_compass/features/memories/domain/entities/memory_pin.dart';
import 'package:memory_compass/features/memories/domain/usecases/update_memory_pin_details.dart';
import 'package:memory_compass/features/memories/presentation/providers/memory_providers.dart';
import 'package:memory_compass/features/memories/presentation/widgets/full_screen_photo_view.dart';
import 'package:memory_compass/features/tags/presentation/providers/tag_providers.dart';

class MemoryDetailSheet extends ConsumerStatefulWidget {
  const MemoryDetailSheet({super.key, required this.pin});

  final MemoryPin pin;

  @override
  ConsumerState<MemoryDetailSheet> createState() => _MemoryDetailSheetState();
}

class _MemoryDetailSheetState extends ConsumerState<MemoryDetailSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  String? _title;
  String? _note;
  late String _photoPath;
  String? _pendingPhotoPath;
  bool _isEditing = false;
  bool _isSaving = false;

  MemoryPin get pin => widget.pin;

  @override
  void initState() {
    super.initState();
    _title = pin.title;
    _note = pin.note;
    _photoPath = pin.photoPath;
    _titleController = TextEditingController(text: _title ?? '');
    _noteController = TextEditingController(text: _note ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _isEditing
                  ? _pickNewPhoto
                  : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FullScreenPhotoView(
                          photoPath: _photoPath,
                          heroTag: pin.id,
                        ),
                      ),
                    ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Hero(
                      tag: pin.id,
                      child: Image.file(
                        File(_pendingPhotoPath ?? _photoPath),
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.photo_camera_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_isEditing) ...[
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note'),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: (_title ?? '').isNotEmpty
                        ? Text(_title!, style: textTheme.titleLarge)
                        : Text(
                            'Untitled memory',
                            style: textTheme.titleLarge?.copyWith(
                              color: textTheme.bodySmall?.color,
                            ),
                          ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit title and note',
                    onPressed: () => setState(() => _isEditing = true),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (pin.takenAt != null)
                    Text(
                      DateFormat.yMMMd().add_jm().format(
                        pin.takenAt!.toLocal(),
                      ),
                      style: textTheme.bodySmall,
                    )
                  else
                    const SizedBox.shrink(),
                  _SyncedPill(isSynced: pin.isSynced),
                ],
              ),
              if ((_note ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_note!),
              ],
            ],
            if (pin.tagIds.isNotEmpty) ...[
              const SizedBox(height: 8),
              _TagChips(tagIds: pin.tagIds),
            ],
            const SizedBox(height: 8),
            Text(
              '${pin.latitude.toStringAsFixed(5)}, ${pin.longitude.toStringAsFixed(5)}',
              style: textTheme.bodySmall?.mono,
            ),
            const SizedBox(height: 16),
            if (_isEditing) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : _cancelEditing,
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isSaving ? null : _saveDetails,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.check),
                      label: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ] else
              OutlinedButton.icon(
                onPressed: () => _confirmDelete(context, ref),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete memory'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
          ],
        ),
      ),
    );
  }


  void _cancelEditing() {
    setState(() {
      _titleController.text = _title ?? '';
      _noteController.text = _note ?? '';
      _pendingPhotoPath = null;
      _isEditing = false;
    });
  }

  Future<void> _pickNewPhoto() async {
    final picker = ref.read(imagePickerProvider);
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null || !mounted) return;
    setState(() => _pendingPhotoPath = picked.path);
  }

  Future<void> _saveDetails() async {
    setState(() => _isSaving = true);
    final newTitle = _blankToNull(_titleController.text);
    final newNote = _blankToNull(_noteController.text);
    final newPhotoPath = _pendingPhotoPath;
    final result = await ref
        .read(updateMemoryPinDetailsUseCaseProvider)
        .call(
          UpdateMemoryPinDetailsParams(
            id: pin.id,
            title: newTitle,
            note: newNote,
            sourceImagePath: newPhotoPath,
          ),
        );
    if (!mounted) return;
    result.match(
      (failure) => setState(() => _isSaving = false),
      (updatedPin) => setState(() {
        _title = newTitle;
        _note = newNote;
        _photoPath = updatedPin.photoPath;
        _pendingPhotoPath = null;
        _isSaving = false;
        _isEditing = false;
      }),
    );
  }

  String? _blankToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this memory?'),
        content: const Text(
          'The photo and its pin will be removed from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(deleteMemoryPinUseCaseProvider).call(pin.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _SyncedPill extends StatelessWidget {
  const _SyncedPill({required this.isSynced});

  final bool isSynced;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return StatusPill(
      icon: isSynced ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
      label: isSynced ? 'Synced' : 'Not backed up',
      color: isSynced ? scheme.secondary : scheme.onSurfaceVariant,
    );
  }
}

class _TagChips extends ConsumerWidget {
  const _TagChips({required this.tagIds});

  final List<String> tagIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagsProvider);
    return tagsAsync.when(
      data: (tags) {
        final linkedTags = tags
            .where((tag) => tagIds.contains(tag.id))
            .toList();
        if (linkedTags.isEmpty) return const SizedBox.shrink();
        return Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            for (final tag in linkedTags)
              Chip(
                avatar: CircleAvatar(backgroundColor: Color(tag.color)),
                label: Text(tag.name),
              ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
