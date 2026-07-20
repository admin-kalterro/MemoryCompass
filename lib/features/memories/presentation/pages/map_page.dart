import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:memory_compass/core/constants/app_constants.dart';
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
      appBar: AppBar(title: const Text(AppConstants.appName)),
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

class _WorldMap extends StatelessWidget {
  const _WorldMap({required this.pins});

  final List<MemoryPin> pins;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: const LatLng(20, 0),
        initialZoom: 2.2,
        minZoom: 1.5,
        maxZoom: 18,
        // Without this, pinch/pan gestures can drag the camera past the
        // poles, where the Web Mercator projection produces Infinity/NaN
        // pixel coordinates and crashes TileLayer's tile range math.
        cameraConstraint: CameraConstraint.contain(
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
        MarkerLayer(
          markers: [
            for (final pin in pins)
              Marker(
                point: LatLng(pin.latitude, pin.longitude),
                width: 48,
                height: 48,
                child: MemoryMarker(
                  pin: pin,
                  onTap: () => _showDetail(context, pin),
                ),
              ),
          ],
        ),
      ],
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
                child: Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.titleLarge,
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
