class AppConstants {
  const AppConstants._();

  static const String appName = 'MemoryCompass';

  /// Required by the OpenStreetMap tile usage policy to identify the
  /// requesting application; must match the app's package/bundle id.
  static const String osmUserAgentPackageName =
      'com.kalterro.memortycompass.memory_compass';

  static const String osmTileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Folder name created in the signed-in user's Google Drive to hold the
  /// synced photo library and manifest.
  static const String driveFolderName = 'MemoryCompass';
  static const String driveManifestFileName = 'manifest.json';
}
