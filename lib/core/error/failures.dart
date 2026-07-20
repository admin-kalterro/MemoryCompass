import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.storage(String message) = StorageFailure;
  const factory Failure.notFound(String message) = NotFoundFailure;
  const factory Failure.permissionDenied(String message) = PermissionFailure;
  const factory Failure.noPhotoSelected() = NoPhotoSelectedFailure;
  const factory Failure.authentication(String message) = AuthenticationFailure;
  const factory Failure.network(String message) = NetworkFailure;
  const factory Failure.drive(String message) = DriveFailure;
  const factory Failure.validation(String message) = ValidationFailure;
  const factory Failure.unexpected(String message) = UnexpectedFailure;
}

extension FailureMessage on Failure {
  String get message => when(
    storage: (m) => m,
    notFound: (m) => m,
    permissionDenied: (m) => m,
    noPhotoSelected: () => 'No photo selected.',
    authentication: (m) => m,
    network: (m) => m,
    drive: (m) => m,
    validation: (m) => m,
    unexpected: (m) => m,
  );
}
