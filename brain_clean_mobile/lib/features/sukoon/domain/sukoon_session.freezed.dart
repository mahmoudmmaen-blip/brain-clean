// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sukoon_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SukoonSession _$SukoonSessionFromJson(Map<String, dynamic> json) {
  return _SukoonSession.fromJson(json);
}

/// @nodoc
mixin _$SukoonSession {
  String get id => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;
  DateTime get completedAt => throw _privateConstructorUsedError;
  String? get wanderNote => throw _privateConstructorUsedError;
  bool get wasInterrupted => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SukoonSessionCopyWith<SukoonSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SukoonSessionCopyWith<$Res> {
  factory $SukoonSessionCopyWith(
          SukoonSession value, $Res Function(SukoonSession) then) =
      _$SukoonSessionCopyWithImpl<$Res, SukoonSession>;
  @useResult
  $Res call(
      {String id,
      int durationMinutes,
      DateTime completedAt,
      String? wanderNote,
      bool wasInterrupted});
}

/// @nodoc
class _$SukoonSessionCopyWithImpl<$Res, $Val extends SukoonSession>
    implements $SukoonSessionCopyWith<$Res> {
  _$SukoonSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? durationMinutes = null,
    Object? completedAt = null,
    Object? wanderNote = freezed,
    Object? wasInterrupted = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      completedAt: null == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      wanderNote: freezed == wanderNote
          ? _value.wanderNote
          : wanderNote // ignore: cast_nullable_to_non_nullable
              as String?,
      wasInterrupted: null == wasInterrupted
          ? _value.wasInterrupted
          : wasInterrupted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SukoonSessionImplCopyWith<$Res>
    implements $SukoonSessionCopyWith<$Res> {
  factory _$$SukoonSessionImplCopyWith(
          _$SukoonSessionImpl value, $Res Function(_$SukoonSessionImpl) then) =
      __$$SukoonSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      int durationMinutes,
      DateTime completedAt,
      String? wanderNote,
      bool wasInterrupted});
}

/// @nodoc
class __$$SukoonSessionImplCopyWithImpl<$Res>
    extends _$SukoonSessionCopyWithImpl<$Res, _$SukoonSessionImpl>
    implements _$$SukoonSessionImplCopyWith<$Res> {
  __$$SukoonSessionImplCopyWithImpl(
      _$SukoonSessionImpl _value, $Res Function(_$SukoonSessionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? durationMinutes = null,
    Object? completedAt = null,
    Object? wanderNote = freezed,
    Object? wasInterrupted = null,
  }) {
    return _then(_$SukoonSessionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      completedAt: null == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      wanderNote: freezed == wanderNote
          ? _value.wanderNote
          : wanderNote // ignore: cast_nullable_to_non_nullable
              as String?,
      wasInterrupted: null == wasInterrupted
          ? _value.wasInterrupted
          : wasInterrupted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SukoonSessionImpl implements _SukoonSession {
  const _$SukoonSessionImpl(
      {required this.id,
      required this.durationMinutes,
      required this.completedAt,
      this.wanderNote,
      this.wasInterrupted = false});

  factory _$SukoonSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SukoonSessionImplFromJson(json);

  @override
  final String id;
  @override
  final int durationMinutes;
  @override
  final DateTime completedAt;
  @override
  final String? wanderNote;
  @override
  @JsonKey()
  final bool wasInterrupted;

  @override
  String toString() {
    return 'SukoonSession(id: $id, durationMinutes: $durationMinutes, completedAt: $completedAt, wanderNote: $wanderNote, wasInterrupted: $wasInterrupted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SukoonSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.wanderNote, wanderNote) ||
                other.wanderNote == wanderNote) &&
            (identical(other.wasInterrupted, wasInterrupted) ||
                other.wasInterrupted == wasInterrupted));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, durationMinutes, completedAt,
      wanderNote, wasInterrupted);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SukoonSessionImplCopyWith<_$SukoonSessionImpl> get copyWith =>
      __$$SukoonSessionImplCopyWithImpl<_$SukoonSessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SukoonSessionImplToJson(
      this,
    );
  }
}

abstract class _SukoonSession implements SukoonSession {
  const factory _SukoonSession(
      {required final String id,
      required final int durationMinutes,
      required final DateTime completedAt,
      final String? wanderNote,
      final bool wasInterrupted}) = _$SukoonSessionImpl;

  factory _SukoonSession.fromJson(Map<String, dynamic> json) =
      _$SukoonSessionImpl.fromJson;

  @override
  String get id;
  @override
  int get durationMinutes;
  @override
  DateTime get completedAt;
  @override
  String? get wanderNote;
  @override
  bool get wasInterrupted;
  @override
  @JsonKey(ignore: true)
  _$$SukoonSessionImplCopyWith<_$SukoonSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
