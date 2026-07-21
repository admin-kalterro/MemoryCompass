# MemoryCompass design system

The identity: a map pin standing in for a compass needle — brass tip
north, ink tip south, the same two-tone convention as an instrument you'd
trust with your position. Ink and brass carry the brand; patina is the
app's original teal, aged rather than replaced. Everything below exists so
a new screen looks like it belongs next to the others without having to
re-derive these decisions.

## Where things live

| What | File |
|---|---|
| Raw brand colors | `lib/core/theme/app_colors.dart` |
| `ThemeData` (light + dark) | `lib/core/theme/app_theme.dart` |
| The mark, as a widget | `lib/core/widgets/compass_mark.dart` |
| Status/scope pill | `lib/core/widgets/status_pill.dart` |
| Teardrop marker (map pins) | `lib/features/memories/presentation/widgets/memory_marker.dart` |

## Color

Don't reach for `Colors.*` or raw hex in a screen. Use `AppColors` only
when you need a fixed brand color that isn't a semantic role (e.g. the
mark's brass/ink needle halves, which are fixed regardless of theme).
Everywhere else, pull from `Theme.of(context).colorScheme` so light/dark
and future palette tweaks stay centralized.

| Token | Hex | `ColorScheme` role | Use for |
|---|---|---|---|
| Ink | `#0D1A2E` | dark `surface` base / scaffold bg | Page ground at night |
| Brass | `#C9974C` | `primary` | Primary actions, the mark's north tip, taken-at emphasis |
| Patina | `#4F8D83` | `secondary` | Sync/success state, secondary accent |
| Paper | `#ECE4D1` | light `surface` / on-dark text | Light-mode ground, text on ink |
| Rust | `#B24B34` | `error` | Delete and irreversible actions only — never decorative |

Both `AppTheme.light()` and `AppTheme.dark()` are built from these via
`ColorScheme.fromSeed(seedColor: AppColors.brass, ...)` with the roles
above pinned explicitly, so `colorScheme.primary` is always brass,
`colorScheme.secondary` is always patina, `colorScheme.error` is always
rust — Material still derives the container/outline/surface-variant tones
around them.

Rust is spoken for. If a new screen needs a warning or destructive color,
it's rust — don't introduce a second red.

## Type

Three roles, no new fonts to bundle:

- **Display/serif** (`fontFamily: 'serif'`) — `headlineSmall`,
  `titleLarge`, `titleMedium` in the theme already carry this. Use those
  text styles for page/section headings and anything meant to feel
  engraved. Don't set `fontFamily: 'serif'` ad hoc in a widget; add the
  role to `AppTheme._textTheme` if a new heading level is needed.
- **Body/sans** — the platform default (Roboto/SF), used for everything
  else. This is `bodyLarge`/`bodyMedium`/`bodySmall` and is the default if
  you don't specify a style.
- **Mono** — anything where digits need to line up: coordinates,
  timestamps, sync log entries. Don't hardcode `fontFamily: 'monospace'`;
  use the extension:

  ```dart
  import 'package:memory_compass/core/theme/app_theme.dart';

  Text('43.6453, -79.3806', style: textTheme.bodySmall?.mono)
  ```

## The mark

`CompassMark(size: 20, color: ...)` draws the logo glyph directly (no
image asset), so it stays crisp at any size and its outline adapts to
whatever `color` you pass — default falls back to the ambient icon color,
then `onSurface`. The needle stays fixed brass-north/ink-south regardless
of context; that two-tone is the brand invariant, don't override it.

Use it:
- Next to the app name in an `AppBar` title or `DrawerHeader` (see
  `MapPage`), at 20–32px.
- As a "you are here" map marker (see `AddMemoryPage`'s mini-map), at
  ~40px.

Don't use `Icons.location_pin` or another stock pin icon anywhere in the
app — `CompassMark` is the pin.

### Anchor gotcha

The mark's silhouette tapers to a point near the *bottom* of its bounding
box, not the center (see the path in `compass_mark.dart` / `_PinClipper`
— the tip sits at y≈93 of a 0–100 box). If you place it as a
`flutter_map` `Marker`, its default `Alignment.center` will anchor the
pin's visual middle on the coordinate, not the tip. Set:

```dart
Marker(
  point: someLatLng,
  alignment: const Alignment(0, 0.86),
  child: const CompassMark(size: 40),
)
```

`MemoryMarker` and the add-memory location pin both already do this —
copy the pattern for any new marker.

## Map pins (photo markers)

`MemoryMarker` clips a photo into the same teardrop as the mark
(`_PinClipper`, shared shape/coordinates with `CompassMark`), brass
background showing through as a 3px border, `PhysicalShape` for a
shape-matched drop shadow. If a new screen needs a "photo pinned to a
place" visual, reuse `MemoryMarker` rather than building another shape —
the teardrop is meant to be the one photo-marker silhouette in the app.

## Status pills

`StatusPill(icon, label, color)` — a small labeled badge for state that
reads better at a glance than a sentence: sync status, access scope,
connection state. Pattern:

```dart
StatusPill(
  icon: isSynced ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
  label: isSynced ? 'Synced' : 'Not backed up',
  color: isSynced ? scheme.secondary : scheme.onSurfaceVariant,
)
```

Semantic color, not decorative: patina/secondary for a positive/synced
state, `onSurfaceVariant` for a neutral/waiting one, `error` (rust) only
for something actually wrong. Used today in `SettingsPage` (Connected,
drive.file scope) and `MemoryDetailSheet` (Synced).

## Components that come free from the theme

These already look right without any per-screen styling — just use the
plain widget:

- `Card` — flat (`elevation: 0`), theme `surface` color, 12px rounded
  corners with a hairline `outlineVariant` border. No shadow-based cards.
- `FilledButton` — brass background, ink text. This is the primary action
  button; use it once per screen for the main action ("Save memory",
  "Sync now").
- `OutlinedButton` — for secondary/cancel actions. For a destructive one,
  pass `style: OutlinedButton.styleFrom(foregroundColor:
  Theme.of(context).colorScheme.error)` explicitly (see the delete button
  in `MemoryDetailSheet`) — the outline color itself doesn't default to
  rust, since most outlined buttons aren't destructive.
- `FloatingActionButton` — brass background, ink icon.
- Chips (`FilterChip`/`Chip`) — patina-tinted when selected.
- `TextField`/`InputDecoration` — rounded, brass focus ring.

## Adding a new screen — checklist

1. Wrap content in `Scaffold` and let it inherit `scaffoldBackgroundColor`
   — don't set a background color per screen.
2. Pull colors from `Theme.of(context).colorScheme`, not `AppColors`,
   unless you specifically need a fixed brand color regardless of theme
   (e.g. inside a custom painter).
3. Headings use the theme's `titleLarge`/`titleMedium`/`headlineSmall`
   (serif comes for free). Coordinates/timestamps use `.mono`. Everything
   else is plain body text.
4. Group related info in a `Card`, not a bare `Column` of `ListTile`s —
   see `SettingsPage` for the pattern (account card, then a card grouping
   Drive folder + last synced).
5. State worth a glance (synced, connected, scope) is a `StatusPill`, not
   a sentence.
6. Any location marker uses `CompassMark` (chrome/picker) or
   `MemoryMarker` (photo pin) — never a stock map icon — and sets
   `alignment: const Alignment(0, 0.86)` if it's a `flutter_map` `Marker`.
7. Run `flutter analyze` before calling it done; the lint set will catch
   most drift (e.g. an accidental `Colors.blue`).
