import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intl/intl.dart';
import 'package:memory_compass/core/error/failures.dart';
import 'package:memory_compass/features/drive_sync/domain/entities/sync_status.dart';
import 'package:memory_compass/features/drive_sync/presentation/controllers/drive_sync_controller.dart';
import 'package:memory_compass/features/drive_sync/presentation/providers/drive_sync_providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _actionInProgress = false;

  Future<void> _runAction(
    Future<Either<Failure, Object?>> Function(DriveSyncController controller)
    action,
  ) async {
    setState(() => _actionInProgress = true);
    final controller = ref.read(driveSyncControllerProvider);
    final result = await action(controller);
    if (!mounted) return;
    setState(() => _actionInProgress = false);
    result.match((failure) => _showError(failure.message), (_) => null);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(syncStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Google Drive sync')),
      body: statusAsync.when(
        data: (status) => _SettingsBody(
          status: status,
          isBusy: _actionInProgress,
          onConnect: () => _runAction((c) => c.connectAndSync()),
          onSyncNow: () => _runAction((c) => c.syncNow()),
          onDisconnect: () => _runAction((c) => c.disconnect()),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Something went wrong: $error')),
      ),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody({
    required this.status,
    required this.isBusy,
    required this.onConnect,
    required this.onSyncNow,
    required this.onDisconnect,
  });

  final SyncStatus status;
  final bool isBusy;
  final VoidCallback onConnect;
  final VoidCallback onSyncNow;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (!status.isSignedIn) ...[
          const Icon(Icons.cloud_off_outlined, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Connect Google Drive to back up your memories. If you ever '
            'lose your phone, sign back in with the same account to get '
            'your photos and pins back.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: isBusy ? null : onConnect,
            icon: isBusy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.login),
            label: const Text('Connect Google Drive'),
          ),
        ] else ...[
          _AccountCard(status: status),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('Drive folder'),
            subtitle: Text(
              status.isFolderLinked ? 'MemoryCompass folder linked' : 'Not linked yet',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Last synced'),
            subtitle: Text(
              status.lastSyncedAt != null
                  ? DateFormat.yMMMd().add_jm().format(status.lastSyncedAt!.toLocal())
                  : 'Never',
            ),
          ),
          if (status.lastErrorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                status.lastErrorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: (isBusy || status.isSyncing) ? null : onSyncNow,
            icon: (isBusy || status.isSyncing)
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            label: const Text('Sync now'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: isBusy ? null : onDisconnect,
            icon: const Icon(Icons.logout),
            label: const Text('Disconnect'),
          ),
        ],
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.status});

  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    final account = status.account!;
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: account.photoUrl != null
            ? NetworkImage(account.photoUrl!)
            : null,
        child: account.photoUrl == null ? const Icon(Icons.person) : null,
      ),
      title: Text(account.displayName ?? account.email),
      subtitle: Text(account.email),
    );
  }
}
