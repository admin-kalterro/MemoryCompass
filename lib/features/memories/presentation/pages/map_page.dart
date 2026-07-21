import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:memory_compass/core/constants/app_constants.dart';
import 'package:memory_compass/core/widgets/compass_mark.dart';
import 'package:memory_compass/features/drive_sync/presentation/pages/settings_page.dart';
import 'package:memory_compass/features/memories/domain/entities/memory_pin.dart';
import 'package:memory_compass/features/memories/presentation/pages/add_memory_page.dart';
import 'package:memory_compass/features/memories/presentation/providers/memory_providers.dart';
import 'package:memory_compass/features/memories/presentation/widgets/memory_detail_sheet.dart';
import 'package:memory_compass/features/memories/presentation/widgets/memory_marker.dart';
import 'package:memory_compass/features/tags/presentation/pages/manage_tags_page.dart';

class MapPage extends ConsumerWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinsAsync = ref.watch(memoryPinsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CompassMark(size: 20),
            const SizedBox(width: 8),
            const Text(AppConstants.appName),
          ],
        ),
      ),
      drawer: const _MainDrawer(),
      body: pinsAsync.when(
        data: (pins) => _WorldMap(pins: pins),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Could not load your memories: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddMemoryPage())),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Add memory'),
      ),
    );
  }
}

class _WorldMap extends StatefulWidget {
  const _WorldMap({required this.pins});

  final List<MemoryPin> pins;

  @override
  State<_WorldMap> createState() => _WorldMapState();
}

class _WorldMapState extends State<_WorldMap> {
  static const double _maxZoom = 18;

  // Once the user is zoomed in this close, they're focused on a specific
  // spot, so a tap on empty map is treated as "add a memory here" instead
  // of just panning around the world.
  static const double _addMemoryZoomThreshold = _maxZoom * 0.8;

  double _zoom = 2.2;

  bool get _tapToAddEnabled => _zoom >= _addMemoryZoomThreshold;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: const LatLng(20, 0),
            initialZoom: _zoom,
            minZoom: 1.5,
            maxZoom: _maxZoom,
            // flingAnimation fires on scale-gesture-end using the finger
            // focal-point tracking, which has a Flutter gesture recognizer
            // bug where the reported focal point/velocity can spike when a
            // finger lifts a beat before the other during a fast pinch.
            // That spurious velocity was flinging the camera across the
            // screen after a fast zoom, so momentum is disabled here.
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.flingAnimation,
            ),
            // Without this, pinch/pan gestures can drag the camera past the
            // poles, where the Web Mercator projection produces Infinity/NaN
            // pixel coordinates and crashes TileLayer's tile range math.
            // containLatitude only clamps latitude and leaves longitude free,
            // so panning can still wrap around the antimeridian using the
            // tile layer's built-in world wrap instead of dead-ending at
            // +/-180 degrees.
            cameraConstraint: const CameraConstraint.containLatitude(85, -85),
            onPositionChanged: (camera, hasGesture) {
              if (camera.zoom != _zoom) setState(() => _zoom = camera.zoom);
            },
            onTap: (_, point) => _handleTap(context, point),
          ),
          children: [
            TileLayer(
              urlTemplate: AppConstants.osmTileUrlTemplate,
              userAgentPackageName: AppConstants.osmUserAgentPackageName,
            ),
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                maxClusterRadius: 45,
                size: const Size(48, 48),
                alignment: Alignment.center,
                maxZoom: _maxZoom,
                markers: [
                  for (final pin in widget.pins)
                    Marker(
                      point: LatLng(pin.latitude, pin.longitude),
                      width: 48,
                      height: 48,
                      // The pin's tail tapers to a point near the bottom of
                      // its bounding box (see _PinClipper), not its center,
                      // so that's what needs to land on the coordinate.
                      // flutter_map's alignment is the widget's position
                      // relative to the point, not the point's position
                      // within the widget, so the sign is inverted from what
                      // you'd naively expect: negative y pulls the widget up,
                      // landing its bottom (the tip) on the point.
                      alignment: const Alignment(0, -0.86),
                      child: MemoryMarker(
                        pin: pin,
                        onTap: () => _showDetail(context, pin),
                      ),
                    ),
                ],
                builder: (context, markers) =>
                    _ClusterMarker(count: markers.length),
              ),
            ),
          ],
        ),
        if (_tapToAddEnabled)
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: Text(
                    'Tap the map to add a memory',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _handleTap(BuildContext context, LatLng point) {
    if (!_tapToAddEnabled) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            AddMemoryPage(initialLocation: point, initialZoom: _zoom),
      ),
    );
  }

  void _showDetail(BuildContext context, MemoryPin pin) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => MemoryDetailSheet(pin: pin),
    );
  }
}

class _ClusterMarker extends StatelessWidget {
  const _ClusterMarker({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primary,
        border: Border.all(color: colorScheme.surface, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _MainDrawer extends StatelessWidget {
  const _MainDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CompassMark(size: 32),
                    const SizedBox(width: 10),
                    Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_sync_outlined),
              title: const Text('Google Drive sync'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.sell_outlined),
              title: const Text('Manage tags'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ManageTagsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
