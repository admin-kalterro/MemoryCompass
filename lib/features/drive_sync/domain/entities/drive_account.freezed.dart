// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'drive_account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DriveAccount {
  String get email => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;

  /// Create a copy of DriveAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DriveAccountCopyWith<DriveAccount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DriveAccountCopyWith<$Res> {
  factory $DriveAccountCopyWith(
    DriveAccount value,
    $Res Function(DriveAccount) then,
  ) = _$DriveAccountCopyWithImpl<$Res, DriveAccount>;
  @useResult
  $Res call({String email, String? displayName, String? photoUrl});
}

/// @nodoc
class _$DriveAccountCopyWithImpl<$Res, $Val extends DriveAccount>
    implements $DriveAccountCopyWith<$Res> {
  _$DriveAccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DriveAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? displayName = freezed,
    Object? photoUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: freezed == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DriveAccountImplCopyWith<$Res>
    implements $DriveAccountCopyWith<$Res> {
  factory _$$DriveAccountImplCopyWith(
    _$DriveAccountImpl value,
    $Res Function(_$DriveAccountImpl) then,
  ) = __$$DriveAccountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email, String? displayName, String? photoUrl});
}

/// @nodoc
class __$$DriveAccountImplCopyWithImpl<$Res>
    extends _$DriveAccountCopyWithImpl<$Res, _$DriveAccountImpl>
    implements _$$DriveAccountImplCopyWith<$Res> {
  __$$DriveAccountImplCopyWithImpl(
    _$DriveAccountImpl _value,
    $Res Function(_$DriveAccountImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DriveAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? displayName = freezed,
    Object? photoUrl = freezed,
  }) {
    return _then(
      _$DriveAccountImpl(
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: freezed == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$DriveAccountImpl implements _DriveAccount {
  const _$DriveAccountImpl({
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  @override
  final String email;
  @override
  final String? displayName;
  @override
  final String? photoUrl;

  @override
  String toString() {
    return 'DriveAccount(email: $email, displayName: $displayName, photoUrl: $photoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DriveAccountImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email, displayName, photoUrl);

  /// Create a copy of DriveAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DriveAccountImplCopyWith<_$DriveAccountImpl> get copyWith =>
      __$$DriveAccountImplCopyWithImpl<_$DriveAccountImpl>(this, _$identity);
}

abstract class _DriveAccount implements DriveAccount {
  const factory _DriveAccount({
    required final String email,
    final String? displayName,
    final String? photoUrl,
  }) = _$DriveAccountImpl;

  @override
  String get email;
  @override
  String? get displayName;
  @override
  String? get photoUrl;

  /// Create a copy of DriveAccount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DriveAccountImplCopyWith<_$DriveAccountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
