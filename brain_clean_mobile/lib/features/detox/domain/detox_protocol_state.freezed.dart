// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'detox_protocol_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DetoxProtocolState {
  bool get boredomBefriended => throw _privateConstructorUsedError;
  int get delayedGratificationCount => throw _privateConstructorUsedError;
  bool get bodyActivated => throw _privateConstructorUsedError;

  /// Weighted detox habit score (0–100), recalculated via [DetoxHabitScorer]
  /// on every check-in before state is committed.
  double get detoxHabitScore => throw _privateConstructorUsedError;
  DateTime? get lastSyncedAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DetoxProtocolStateCopyWith<DetoxProtocolState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DetoxProtocolStateCopyWith<$Res> {
  factory $DetoxProtocolStateCopyWith(
          DetoxProtocolState value, $Res Function(DetoxProtocolState) then) =
      _$DetoxProtocolStateCopyWithImpl<$Res, DetoxProtocolState>;
  @useResult
  $Res call(
      {bool boredomBefriended,
      int delayedGratificationCount,
      bool bodyActivated,
      double detoxHabitScore,
      DateTime? lastSyncedAt});
}

/// @nodoc
class _$DetoxProtocolStateCopyWithImpl<$Res, $Val extends DetoxProtocolState>
    implements $DetoxProtocolStateCopyWith<$Res> {
  _$DetoxProtocolStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boredomBefriended = null,
    Object? delayedGratificationCount = null,
    Object? bodyActivated = null,
    Object? detoxHabitScore = null,
    Object? lastSyncedAt = freezed,
  }) {
    return _then(_value.copyWith(
      boredomBefriended: null == boredomBefriended
          ? _value.boredomBefriended
          : boredomBefriended // ignore: cast_nullable_to_non_nullable
              as bool,
      delayedGratificationCount: null == delayedGratificationCount
          ? _value.delayedGratificationCount
          : delayedGratificationCount // ignore: cast_nullable_to_non_nullable
              as int,
      bodyActivated: null == bodyActivated
          ? _value.bodyActivated
          : bodyActivated // ignore: cast_nullable_to_non_nullable
              as bool,
      detoxHabitScore: null == detoxHabitScore
          ? _value.detoxHabitScore
          : detoxHabitScore // ignore: cast_nullable_to_non_nullable
              as double,
      lastSyncedAt: freezed == lastSyncedAt
          ? _value.lastSyncedAt
          : lastSyncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DetoxProtocolStateImplCopyWith<$Res>
    implements $DetoxProtocolStateCopyWith<$Res> {
  factory _$$DetoxProtocolStateImplCopyWith(_$DetoxProtocolStateImpl value,
          $Res Function(_$DetoxProtocolStateImpl) then) =
      __$$DetoxProtocolStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool boredomBefriended,
      int delayedGratificationCount,
      bool bodyActivated,
      double detoxHabitScore,
      DateTime? lastSyncedAt});
}

/// @nodoc
class __$$DetoxProtocolStateImplCopyWithImpl<$Res>
    extends _$DetoxProtocolStateCopyWithImpl<$Res, _$DetoxProtocolStateImpl>
    implements _$$DetoxProtocolStateImplCopyWith<$Res> {
  __$$DetoxProtocolStateImplCopyWithImpl(_$DetoxProtocolStateImpl _value,
      $Res Function(_$DetoxProtocolStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? boredomBefriended = null,
    Object? delayedGratificationCount = null,
    Object? bodyActivated = null,
    Object? detoxHabitScore = null,
    Object? lastSyncedAt = freezed,
  }) {
    return _then(_$DetoxProtocolStateImpl(
      boredomBefriended: null == boredomBefriended
          ? _value.boredomBefriended
          : boredomBefriended // ignore: cast_nullable_to_non_nullable
              as bool,
      delayedGratificationCount: null == delayedGratificationCount
          ? _value.delayedGratificationCount
          : delayedGratificationCount // ignore: cast_nullable_to_non_nullable
              as int,
      bodyActivated: null == bodyActivated
          ? _value.bodyActivated
          : bodyActivated // ignore: cast_nullable_to_non_nullable
              as bool,
      detoxHabitScore: null == detoxHabitScore
          ? _value.detoxHabitScore
          : detoxHabitScore // ignore: cast_nullable_to_non_nullable
              as double,
      lastSyncedAt: freezed == lastSyncedAt
          ? _value.lastSyncedAt
          : lastSyncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$DetoxProtocolStateImpl implements _DetoxProtocolState {
  const _$DetoxProtocolStateImpl(
      {this.boredomBefriended = false,
      this.delayedGratificationCount = 0,
      this.bodyActivated = false,
      this.detoxHabitScore = 0.0,
      this.lastSyncedAt});

  @override
  @JsonKey()
  final bool boredomBefriended;
  @override
  @JsonKey()
  final int delayedGratificationCount;
  @override
  @JsonKey()
  final bool bodyActivated;

  /// Weighted detox habit score (0–100), recalculated via [DetoxHabitScorer]
  /// on every check-in before state is committed.
  @override
  @JsonKey()
  final double detoxHabitScore;
  @override
  final DateTime? lastSyncedAt;

  @override
  String toString() {
    return 'DetoxProtocolState(boredomBefriended: $boredomBefriended, delayedGratificationCount: $delayedGratificationCount, bodyActivated: $bodyActivated, detoxHabitScore: $detoxHabitScore, lastSyncedAt: $lastSyncedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DetoxProtocolStateImpl &&
            (identical(other.boredomBefriended, boredomBefriended) ||
                other.boredomBefriended == boredomBefriended) &&
            (identical(other.delayedGratificationCount,
                    delayedGratificationCount) ||
                other.delayedGratificationCount == delayedGratificationCount) &&
            (identical(other.bodyActivated, bodyActivated) ||
                other.bodyActivated == bodyActivated) &&
            (identical(other.detoxHabitScore, detoxHabitScore) ||
                other.detoxHabitScore == detoxHabitScore) &&
            (identical(other.lastSyncedAt, lastSyncedAt) ||
                other.lastSyncedAt == lastSyncedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, boredomBefriended,
      delayedGratificationCount, bodyActivated, detoxHabitScore, lastSyncedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DetoxProtocolStateImplCopyWith<_$DetoxProtocolStateImpl> get copyWith =>
      __$$DetoxProtocolStateImplCopyWithImpl<_$DetoxProtocolStateImpl>(
          this, _$identity);
}

abstract class _DetoxProtocolState implements DetoxProtocolState {
  const factory _DetoxProtocolState(
      {final bool boredomBefriended,
      final int delayedGratificationCount,
      final bool bodyActivated,
      final double detoxHabitScore,
      final DateTime? lastSyncedAt}) = _$DetoxProtocolStateImpl;

  @override
  bool get boredomBefriended;
  @override
  int get delayedGratificationCount;
  @override
  bool get bodyActivated;
  @override

  /// Weighted detox habit score (0–100), recalculated via [DetoxHabitScorer]
  /// on every check-in before state is committed.
  double get detoxHabitScore;
  @override
  DateTime? get lastSyncedAt;
  @override
  @JsonKey(ignore: true)
  _$$DetoxProtocolStateImplCopyWith<_$DetoxProtocolStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
