import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:memory_compass/core/constants/app_constants.dart';
import 'package:memory_compass/core/widgets/compass_mark.dart';
import 'package:memory_compass/features/memories/presentation/controllers/add_memory_controller.dart';
import 'package:memory_compass/features/memories/presentation/controllers/add_memory_state.dart';
import 'package:memory_compass/features/tags/presentation/providers/tag_providers.dart';

class AddMemoryPage extends ConsumerStatefulWidget {
  const AddMemoryPage({super.key, this.initialLocation, this.initialZoom});

  /// Location chosen before the photo was picked, e.g. by tapping a spot on
  /// the world map. Takes priority over any GPS location found in the
  /// photo's EXIF data, since it reflects where the user meant to pin it.
  final LatLng? initialLocation;

  /// Zoom level of the world map at the moment [initialLocation] was chosen,
  /// so the mini map here opens at the same zoom instead of jumping to a
  /// different level and disorienting the user.
  final double? initialZoom;

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
              initialZoom: widget.initialZoom,
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
    this.initialZoom,
  });

  final AddMemoryState state;
  final AddMemoryController controller;
  final TextEditingController titleController;
  final TextEditingController noteController;
  final double? initialZoom;

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
        _LocationHintBadge(state: state),
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
                initialZoom: state.hasLocation ? (initialZoom ?? 12) : 2.2,
                minZoom: 1.5,
                maxZoom: 18,
                // flingAnimation fires on scale-gesture-end using the finger
                // focal-point tracking, which has a Flutter gesture
                // recognizer bug where the reported focal point/velocity can
                // spike when a finger lifts a beat before the other during a
                // fast pinch. That spurious velocity was flinging the camera
                // across the screen after a fast zoom, so momentum is
                // disabled here.
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.flingAnimation,
                ),
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
                        // The mark's tail tapers to a point near the bottom
                        // of its bounding box, not its center — that's what
                        // needs to land on the coordinate. flutter_map's
                        // alignment is the widget's position relative to the
                        // point, not the point's position within the widget,
                        // so the sign is inverted from what you'd naively
                        // expect: negative y pulls the widget up, landing its
                        // bottom (the tip) on the point.
                        alignment: const Alignment(0, -0.86),
                        child: const CompassMark(size: 40),
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
}

/// A small badge describing where the pin's location came from: found in
/// the photo's EXIF data, or waiting for / set by a tap on the map.
class _LocationHintBadge extends StatelessWidget {
  const _LocationHintBadge({required this.state});

  final AddMemoryState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fromExif = state.hasLocation && state.locationFromExif;

    final IconData icon;
    final String label;
    final Color accent;
    if (fromExif) {
      icon = Icons.gps_fixed;
      label = 'GPS found in photo — tap the map to adjust';
      accent = scheme.secondary;
    } else if (state.hasLocation) {
      icon = Icons.touch_app_outlined;
      label = 'Tap the map to move the pin';
      accent = scheme.onSurfaceVariant;
    } else {
      icon = Icons.touch_app_outlined;
      label = 'No GPS data found — tap the map to place this memory';
      accent = scheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: accent),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: accent),
            ),
          ),
        ],
      ),
    );
  }
}
