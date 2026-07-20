import 'package:freezed_annotation/freezed_annotation.dart';

part 'drive_account.freezed.dart';

@freezed
sealed class DriveAccount with _$DriveAccount {
  const factory DriveAccount({
    required String email,
    String? displayName,
    String? photoUrl,
  }) = _DriveAccount;
}
