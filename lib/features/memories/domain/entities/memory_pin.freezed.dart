// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'memory_pin.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MemoryPin {
  String get id => throw _privateConstructorUsedError;
  String get photoPath => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get takenAt => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  String? get driveFileId => throw _privateConstructorUsedError;
  bool get isSynced => throw _privateConstructorUsedError;
  List<String> get tagIds => throw _privateConstructorUsedError;

  /// Create a copy of MemoryPin
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemoryPinCopyWith<MemoryPin> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemoryPinCopyWith<$Res> {
  factory $MemoryPinCopyWith(MemoryPin value, $Res Function(MemoryPin) then) =
      _$MemoryPinCopyWithImpl<$Res, MemoryPin>;
  @useResult
  $Res call({
    String id,
    String photoPath,
    double latitude,
    double longitude,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? takenAt,
    String? title,
    String? note,
    String? driveFileId,
    bool isSynced,
    List<String> tagIds,
  });
}

/// @nodoc
class _$MemoryPinCopyWithImpl<$Res, $Val extends MemoryPin>
    implements $MemoryPinCopyWith<$Res> {
  _$MemoryPinCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MemoryPin
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? photoPath = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? takenAt = freezed,
    Object? title = freezed,
    Object? note = freezed,
    Object? driveFileId = freezed,
    Object? isSynced = null,
    Object? tagIds = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            photoPath: null == photoPath
                ? _value.photoPath
                : photoPath // ignore: cast_nullable_to_non_nullable
                      as String,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            takenAt: freezed == takenAt
                ? _value.takenAt
                : takenAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            driveFileId: freezed == driveFileId
                ? _value.driveFileId
                : driveFileId // ignore: cast_nullable_to_non_nullable
                      as String?,
            isSynced: null == isSynced
                ? _value.isSynced
                : isSynced // ignore: cast_nullable_to_non_nullable
                      as bool,
            tagIds: null == tagIds
                ? _value.tagIds
                : tagIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MemoryPinImplCopyWith<$Res>
    implements $MemoryPinCopyWith<$Res> {
  factory _$$MemoryPinImplCopyWith(
    _$MemoryPinImpl value,
    $Res Function(_$MemoryPinImpl) then,
  ) = __$$MemoryPinImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String photoPath,
    double latitude,
    double longitude,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? takenAt,
    String? title,
    String? note,
    String? driveFileId,
    bool isSynced,
    List<String> tagIds,
  });
}

/// @nodoc
class __$$MemoryPinImplCopyWithImpl<$Res>
    extends _$MemoryPinCopyWithImpl<$Res, _$MemoryPinImpl>
    implements _$$MemoryPinImplCopyWith<$Res> {
  __$$MemoryPinImplCopyWithImpl(
    _$MemoryPinImpl _value,
    $Res Function(_$MemoryPinImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MemoryPin
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? photoPath = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? takenAt = freezed,
    Object? title = freezed,
    Object? note = freezed,
    Object? driveFileId = freezed,
    Object? isSynced = null,
    Object? tagIds = null,
  }) {
    return _then(
      _$MemoryPinImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        photoPath: null == photoPath
            ? _value.photoPath
            : photoPath // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        takenAt: freezed == takenAt
            ? _value.takenAt
            : takenAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        driveFileId: freezed == driveFileId
            ? _value.driveFileId
            : driveFileId // ignore: cast_nullable_to_non_nullable
                  as String?,
        isSynced: null == isSynced
            ? _value.isSynced
            : isSynced // ignore: cast_nullable_to_non_nullable
                  as bool,
        tagIds: null == tagIds
            ? _value._tagIds
            : tagIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc

class _$MemoryPinImpl implements _MemoryPin {
  const _$MemoryPinImpl({
    required this.id,
    required this.photoPath,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.updatedAt,
    this.takenAt,
    this.title,
    this.note,
    this.driveFileId,
    this.isSynced = false,
    final List<String> tagIds = const <String>[],
  }) : _tagIds = tagIds;

  @override
  final String id;
  @override
  final String photoPath;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? takenAt;
  @override
  final String? title;
  @override
  final String? note;
  @override
  final String? driveFileId;
  @override
  @JsonKey()
  final bool isSynced;
  final List<String> _tagIds;
  @override
  @JsonKey()
  List<String> get tagIds {
    if (_tagIds is EqualUnmodifiableListView) return _tagIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tagIds);
  }

  @override
  String toString() {
    return 'MemoryPin(id: $id, photoPath: $photoPath, latitude: $latitude, longitude: $longitude, createdAt: $createdAt, updatedAt: $updatedAt, takenAt: $takenAt, title: $title, note: $note, driveFileId: $driveFileId, isSynced: $isSynced, tagIds: $tagIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemoryPinImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.photoPath, photoPath) ||
                other.photoPath == photoPath) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.takenAt, takenAt) || other.takenAt == takenAt) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.driveFileId, driveFileId) ||
                other.driveFileId == driveFileId) &&
            (identical(other.isSynced, isSynced) ||
                other.isSynced == isSynced) &&
            const DeepCollectionEquality().equals(other._tagIds, _tagIds));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    photoPath,
    latitude,
    longitude,
    createdAt,
    updatedAt,
    takenAt,
    title,
    note,
    driveFileId,
    isSynced,
    const DeepCollectionEquality().hash(_tagIds),
  );

  /// Create a copy of MemoryPin
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemoryPinImplCopyWith<_$MemoryPinImpl> get copyWith =>
      __$$MemoryPinImplCopyWithImpl<_$MemoryPinImpl>(this, _$identity);
}

abstract class _MemoryPin implements MemoryPin {
  const factory _MemoryPin({
    required final String id,
    required final String photoPath,
    required final double latitude,
    required final double longitude,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final DateTime? takenAt,
    final String? title,
    final String? note,
    final String? driveFileId,
    final bool isSynced,
    final List<String> tagIds,
  }) = _$MemoryPinImpl;

  @override
  String get id;
  @override
  String get photoPath;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get takenAt;
  @override
  String? get title;
  @override
  String? get note;
  @override
  String? get driveFileId;
  @override
  bool get isSynced;
  @override
  List<String> get tagIds;

  /// Create a copy of MemoryPin
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemoryPinImplCopyWith<_$MemoryPinImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
