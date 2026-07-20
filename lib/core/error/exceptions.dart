class StorageException implements Exception {
  const StorageException(this.message);
  final String message;
  @override
  String toString() => 'StorageException: $message';
}

class LocalDatabaseException implements Exception {
  const LocalDatabaseException(this.message);
  final String message;
  @override
  String toString() => 'LocalDatabaseException: $message';
}

class AuthenticationException implements Exception {
  const AuthenticationException(this.message);
  final String message;
  @override
  String toString() => 'AuthenticationException: $message';
}

class DriveException implements Exception {
  const DriveException(this.message);
  final String message;
  @override
  String toString() => 'DriveException: $message';
}
