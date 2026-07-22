import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The minimum zoom at which the world (a 256px tile at zoom 0) still
/// covers [size], at any rotation.
///
/// Below this, the map's poles/antimeridian no longer reach the edge of the
/// viewport, leaving blank space instead of tiles. The map here supports
/// free two-finger rotation, and flutter_map's `ContainCameraLatitude`
/// constraint measures coverage against the *rotated* bounding box, which
/// is larger than [size] at any angle other than 0/90/180/270 — so the
/// diagonal (the rotated bound at 45 degrees, the worst case) is used
/// rather than the longer edge.
///
/// A small margin is added on top of the exact `256 * 2^z >= diagonal`
/// solution: at an exact fit, `ContainCameraLatitude.constrain` computes
/// its allowed-center range as empty (or empty by a rounding error) and
/// returns null instead of a clamped camera, which trips flutter_map's
/// internal assertion that the camera stays within the constraint after
/// any option change.
double minZoomForSize(Size size) {
  final diagonal = math.sqrt(
    size.width * size.width + size.height * size.height,
  );
  const safetyMargin = 0.1;
  return math.max(2.5, math.log(diagonal / 256) / math.ln2 + safetyMargin);
}
