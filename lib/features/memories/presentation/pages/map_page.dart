import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:memory_compass/core/constants/app_constants.dart';
import 'package:memory_compass/core/utils/map_zoom.dart';
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
    final pinsAsync = ref.watch(filteredMemoryPinsProvider);
    final hasQuery = ref.watch(
      memorySearchQueryProvider.select((query) => query.trim().isNotEmpty),
    );

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
      body: Stack(
        children: [
          pinsAsync.when(
            data: (pins) => pins.isEmpty && hasQuery
                ? const _NoResults()
                : _WorldMap(pins: pins),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                Center(child: Text('Could not load your memories: $error')),
          ),
          const Positioned(top: 12, left: 12, right: 12, child: _SearchBar()),
        ],
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

class _WorldMapState extends State<_WorldMap>
    with SingleTickerProviderStateMixin {
  static const double _maxZoom = 18;

  // Once the user is zoomed in this close, they're focused on a specific
  // spot, so a tap on empty map is treated as "add a memory here" instead
  // of just panning around the world.
  static const double _addMemoryZoomThreshold = _maxZoom * 0.8;

  final MapController _mapController = MapController();

  // SingleTickerProviderStateMixin only ever hands out one ticker for the
  // life of this State, so the controller is created once in initState and
  // reused (via forward(from: 0)) rather than rebuilt on every tap. A lazy
  // `late final` would instead construct it on first use, which could be as
  // late as dispose() if the button is never pressed — by then the widget
  // is unmounted and vsync's context lookup is unsafe.
  late final AnimationController _rotationAnimationController;
  VoidCallback? _rotationListener;

  // A pure two-finger rotate gesture is applied via MapController.rotateRaw,
  // which — unlike moves/zooms — never calls MapOptions.onPositionChanged.
  // Without this subscription, rotating the map by hand never updates
  // _rotation, so the compass never appears and tapping it does nothing.
  late final StreamSubscription<MapEvent> _mapEventSubscription;

  double _zoom = 2.2;
  double _rotation = 0;

  bool get _tapToAddEnabled => _zoom >= _addMemoryZoomThreshold;

  @override
  void initState() {
    super.initState();
    _rotationAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _mapEventSubscription = _mapController.mapEventStream.listen(
      _handleMapEvent,
    );
  }

  @override
  void dispose() {
    _mapEventSubscription.cancel();
    _rotationAnimationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _handleMapEvent(MapEvent event) {
    final camera = event.camera;
    if (camera.zoom != _zoom) setState(() => _zoom = camera.zoom);
    // Normalized so a reset that lands on an equivalent multiple of 360
    // (e.g. 360 instead of 0) still reads as north-up.
    final normalizedRotation = _normalizeRotation(camera.rotation);
    if (normalizedRotation != _rotation) {
      setState(() => _rotation = normalizedRotation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minZoom = minZoomForSize(constraints.biggest);
        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(20, 0),
                initialZoom: math.max(_zoom, minZoom),
                minZoom: minZoom,
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
                cameraConstraint: const CameraConstraint.containLatitude(
                  85,
                  -85,
                ),
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
                top: 68,
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
            Positioned(
              top: 76,
              right: 12,
              child: _CompassButton(
                rotation: _rotation,
                onPressed: _resetNorth,
              ),
            ),
          ],
        );
      },
    );
  }

  void _resetNorth() {
    final start = _mapController.camera.rotation;
    if (start == 0) return;

    // Rotation can accumulate past +/-360 over a continuous rotate gesture,
    // so animate to whichever multiple of 360 is nearest (the "true north"
    // equivalent to the current heading) rather than always animating back
    // toward 0, which could spin the map the long way round.
    final target = start - _normalizeRotation(start);

    if (_rotationListener != null) {
      _rotationAnimationController.removeListener(_rotationListener!);
    }
    final animation = Tween<double>(begin: start, end: target).animate(
      CurvedAnimation(
        parent: _rotationAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _rotationListener = () => _mapController.rotate(animation.value);
    _rotationAnimationController
      ..addListener(_rotationListener!)
      ..forward(from: 0);
  }

  // Wraps into (-180, 180] so headings that are a multiple of 360 apart
  // (e.g. 0 and 360) compare as equal.
  double _normalizeRotation(double degrees) {
    final wrapped = degrees % 360;
    return wrapped > 180 ? wrapped - 360 : wrapped;
  }

  void _handleTap(BuildContext context, LatLng point) {
    if (!_tapToAddEnabled) return;
    _dismissKeyboard(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            AddMemoryPage(initialLocation: point, initialZoom: _zoom),
      ),
    );
  }

  void _showDetail(BuildContext context, MemoryPin pin) {
    _dismissKeyboard(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => MemoryDetailSheet(pin: pin),
    );
  }

  // Plain unfocus() moves focus up to the enclosing FocusScopeNode, which
  // still remembers the search field as its last-focused descendant — so
  // once the pushed route/sheet is dismissed, focus traversal restores it
  // and pops the keyboard back open. Handing focus to a fresh, unattached
  // FocusNode instead makes sure nothing is left to restore.
  void _dismissKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
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

// Always visible so it can be used both to see the map's current heading
// at a glance and to reset it back to north.
class _CompassButton extends StatelessWidget {
  const _CompassButton({required this.rotation, required this.onPressed});

  final double rotation;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 2,
      shape: const CircleBorder(),
      color: colorScheme.surface,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          // The tile layer rotates by the same angle (see flutter_map's
          // Transform.rotate on camera.rotationRad), so rotating the rose
          // identically keeps its north tip pointing at true north on
          // screen no matter how the map is spun.
          child: Transform.rotate(
            angle: rotation * math.pi / 180,
            child: SvgPicture.asset(
              'assets/icons/compass_rose.svg',
              width: 24,
              height: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends ConsumerStatefulWidget {
  const _SearchBar();

  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(memorySearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = ref.watch(
      memorySearchQueryProvider.select((query) => query.isNotEmpty),
    );
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(28),
      color: colorScheme.surface,
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        onChanged: (value) =>
            ref.read(memorySearchQueryProvider.notifier).state = value,
        decoration: InputDecoration(
          hintText: 'Search title, note, or tags',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: hasQuery
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear search',
                  onPressed: () {
                    _controller.clear();
                    ref.read(memorySearchQueryProvider.notifier).state = '';
                  },
                )
              : null,
          filled: true,
          fillColor: colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 40,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No memories match your search',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
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
