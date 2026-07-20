import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory_compass/core/constants/app_constants.dart';
import 'package:memory_compass/core/theme/app_theme.dart';
import 'package:memory_compass/core/usecase/usecase.dart';
import 'package:memory_compass/features/drive_sync/presentation/providers/drive_sync_providers.dart';
import 'package:memory_compass/features/memories/presentation/pages/map_page.dart';

class MemoryCompassApp extends StatelessWidget {
  const MemoryCompassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const _AppStartup(),
    );
  }
}

/// Kicks off a silent Google session restore in the background, then shows
/// the map immediately rather than blocking on a splash screen. The
/// settings screen picks up the result via [syncStatusProvider].
class _AppStartup extends ConsumerStatefulWidget {
  const _AppStartup();

  @override
  ConsumerState<_AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends ConsumerState<_AppStartup> {
  @override
  void initState() {
    super.initState();
    unawaited(
      ref.read(restoreGoogleSessionUseCaseProvider).call(const NoParams()),
    );
  }

  @override
  Widget build(BuildContext context) => const MapPage();
}
