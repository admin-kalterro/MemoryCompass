import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_compass/core/error/failures.dart';
import 'package:memory_compass/features/tags/domain/entities/tag.dart';
import 'package:memory_compass/features/tags/domain/usecases/create_tag.dart';
import 'package:memory_compass/features/tags/domain/usecases/update_tag.dart';
import 'package:memory_compass/features/tags/presentation/providers/tag_providers.dart';
import 'package:memory_compass/features/tags/presentation/widgets/tag_form_dialog.dart';

class ManageTagsPage extends ConsumerWidget {
  const ManageTagsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage tags')),
      body: tagsAsync.when(
        data: (tags) => tags.isEmpty
            ? const Center(child: Text('No tags yet. Tap + to add one.'))
            : ListView.builder(
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final tag = tags[index];
                  return ListTile(
                    leading: CircleAvatar(backgroundColor: Color(tag.color)),
                    title: Text(tag.name),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () => _editTag(context, ref, tag),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load tags: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createTag(context, ref),
        tooltip: 'New tag',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _createTag(BuildContext context, WidgetRef ref) async {
    final form = await showDialog<TagFormResult>(
      context: context,
      builder: (_) => const TagFormDialog(title: 'New tag'),
    );
    if (form == null) return;

    final result = await ref
        .read(createTagUseCaseProvider)
        .call(CreateTagParams(name: form.name, color: form.color.toARGB32()));
    if (!context.mounted) return;
    result.match((failure) => _showError(context, failure.message), (_) {});
  }

  Future<void> _editTag(BuildContext context, WidgetRef ref, Tag tag) async {
    final form = await showDialog<TagFormResult>(
      context: context,
      builder: (_) => TagFormDialog(
        title: 'Edit tag',
        initialName: tag.name,
        initialColor: Color(tag.color),
      ),
    );
    if (form == null) return;

    final result = await ref
        .read(updateTagUseCaseProvider)
        .call(
          UpdateTagParams(
            id: tag.id,
            name: form.name,
            color: form.color.toARGB32(),
          ),
        );
    if (!context.mounted) return;
    result.match((failure) => _showError(context, failure.message), (_) {});
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
