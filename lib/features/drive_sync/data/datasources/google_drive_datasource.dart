import 'package:googleapis/drive/v3.dart' as drive;
import 'package:memory_compass/core/error/exceptions.dart';

/// Thin wrapper around [drive.DriveApi] for the handful of operations the
/// sync engine needs: finding/creating the app folder, and uploading,
/// updating and downloading files within it.
class GoogleDriveDataSource {
  const GoogleDriveDataSource();

  Future<String> findOrCreateFolder(drive.DriveApi api, String name) async {
    final existingId = await findFileId(
      api,
      folderId: null,
      fileName: name,
      mimeType: _folderMimeType,
    );
    if (existingId != null) return existingId;

    final folder = drive.File()
      ..name = name
      ..mimeType = _folderMimeType;
    final created = await api.files.create(folder, $fields: 'id');
    final id = created.id;
    if (id == null) {
      throw const DriveException('Drive did not return a folder id.');
    }
    return id;
  }

  /// Finds a file by name, optionally scoped to a parent folder.
  Future<String?> findFileId(
    drive.DriveApi api, {
    required String? folderId,
    required String fileName,
    String? mimeType,
  }) async {
    final escapedName = fileName.replaceAll("'", r"\'");
    final clauses = <String>["name = '$escapedName'", 'trashed = false'];
    if (folderId != null) clauses.add("'$folderId' in parents");
    if (mimeType != null) clauses.add("mimeType = '$mimeType'");

    final result = await api.files.list(
      q: clauses.join(' and '),
      spaces: 'drive',
      $fields: 'files(id, name)',
    );
    final files = result.files;
    if (files == null || files.isEmpty) return null;
    return files.first.id;
  }

  Future<String> uploadOrUpdateFile(
    drive.DriveApi api, {
    required String folderId,
    required String fileName,
    required List<int> bytes,
    required String mimeType,
    String? existingFileId,
  }) async {
    final media = drive.Media(
      Stream.value(bytes),
      bytes.length,
      contentType: mimeType,
    );
    if (existingFileId != null) {
      final updated = await api.files.update(
        drive.File(),
        existingFileId,
        uploadMedia: media,
        $fields: 'id',
      );
      return updated.id ?? existingFileId;
    }

    final file = drive.File()
      ..name = fileName
      ..parents = [folderId];
    final created = await api.files.create(
      file,
      uploadMedia: media,
      $fields: 'id',
    );
    final id = created.id;
    if (id == null) {
      throw const DriveException('Drive did not return a file id.');
    }
    return id;
  }

  Future<List<int>> downloadFile(drive.DriveApi api, String fileId) async {
    final response = await api.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    );
    if (response is! drive.Media) {
      throw const DriveException('Unexpected response downloading file.');
    }
    final bytes = <int>[];
    await for (final chunk in response.stream) {
      bytes.addAll(chunk);
    }
    return bytes;
  }

  static const String _folderMimeType = 'application/vnd.google-apps.folder';
}
