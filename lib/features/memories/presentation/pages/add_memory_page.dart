import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:memory_compass/core/constants/app_constants.dart';
import 'package:memory_compass/features/memories/presentation/controllers/add_memory_controller.dart';
import 'package:memory_compass/features/memories/presentation/controllers/add_memory_state.dart';
import 'package:memory_compass/features/tags/presentation/providers/tag_providers.dart';

class AddMemoryPage extends ConsumerStatefulWidget {
  const AddMemoryPage({super.key, this.initialLocation});

  /// Location chosen before the photo was picked, e.g. by tapping a spot on
  /// the world map. Takes priority over any GPS location found in the
  /// photo's EXIF data, since it reflects where the user meant to pin it.
  final LatLng? initialLocation;

  @override
  ConsumerState<AddMemoryPage> createState() => _AddMemoryPageState();
}

class _AddMemoryPageState extends ConsumerState<AddMemoryPage> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  bool _pickAttempted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startPicking());
  }

  Future<void> _startPicking() async {
    final picked = await ref
        .read(addMemoryControllerProvider.notifier)
        .pickPhoto(initialLocation: widget.initialLocation);
    if (!mounted) return;
    if (!picked) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _pickAttempted = true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addMemoryControllerProvider);
    final controller = ref.read(addMemoryControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('New memory')),
      body: !_pickAttempted || !state.hasPhoto
          ? const Center(child: CircularProgressIndicator())
          : _AddMemoryForm(
              state: state,
              controller: controller,
              titleController: _titleController,
              noteController: _noteController,
            ),
    );
  }
}

class _AddMemoryForm extends StatelessWidget {
  const _AddMemoryForm({
    required this.state,
    required this.controller,
    required this.titleController,
    required this.noteController,
  });

  final AddMemoryState state;
  final AddMemoryController controller;
  final TextEditingController titleController;
  final TextEditingController noteController;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(state.imagePath!),
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _locationHint(state),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 260,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: state.hasLocation
                    ? LatLng(state.latitude!, state.longitude!)
                    : const LatLng(20, 0),
                initialZoom: state.hasLocation ? 12 : 2.2,
                minZoom: 1.5,
                maxZoom: 18,
                onTap: (_, point) =>
                    controller.setLocation(point.latitude, point.longitude),
                cameraConstraint: CameraConstraint.containCenter(
                  bounds: LatLngBounds(
                    const LatLng(-85, -180),
                    const LatLng(85, 180),
                  ),
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: AppConstants.osmTileUrlTemplate,
                  userAgentPackageName: AppConstants.osmUserAgentPackageName,
                ),
                if (state.hasLocation)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(state.latitude!, state.longitude!),
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.location_pin,
                          color: Theme.of(context).colorScheme.primary,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Title (optional)'),
          onChanged: controller.setTitle,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: noteController,
          decoration: const InputDecoration(labelText: 'Note (optional)'),
          maxLines: 3,
          onChanged: controller.setNote,
        ),
        const SizedBox(height: 16),
        Text('Tags', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Consumer(
          builder: (context, ref, _) {
            final tagsAsync = ref.watch(tagsProvider);
            return tagsAsync.when(
              data: (tags) => tags.isEmpty
                  ? Text(
                      'No tags yet. Create some from the menu.',
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final tag in tags)
                          FilterChip(
                            avatar: CircleAvatar(
                              backgroundColor: Color(tag.color),
                            ),
                            showCheckmark: false,
                            label: Text(tag.name),
                            selected: state.selectedTagIds.contains(tag.id),
                            onSelected: (_) => controller.toggleTag(tag.id),
                          ),
                      ],
                    ),
              loading: () => const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (error, _) => Text('Could not load tags: $error'),
            );
          },
        ),
        if (state.errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            state.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: state.canSave
              ? () async {
                  final saved = await controller.save();
                  if (saved && context.mounted) {
                    Navigator.of(context).pop(true);
                  }
                }
              : null,
          icon: state.isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: const Text('Save memory'),
        ),
      ],
    );
  }

  String _locationHint(AddMemoryState state) {
    if (!state.hasLocation) return 'Tap the map to place this memory.';
    return state.locationFromExif
        ? 'Location found in the photo. Tap the map to adjust it.'
        : 'Tap the map to move the pin.';
  }
}
