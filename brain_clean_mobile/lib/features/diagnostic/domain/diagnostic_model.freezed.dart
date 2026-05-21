// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diagnostic_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DiagnosticMetrics {
  /// S1 — sleep quality
  int get sleepQuality => throw _privateConstructorUsedError;

  /// A2 — sustained attention
  int get sustainedAttention => throw _privateConstructorUsedError;

  /// F3 — fragmentation
  int get fragmentation => throw _privateConstructorUsedError;

  /// D4 — dopamine seeking
  int get dopamineSeeking => throw _privateConstructorUsedError;

  /// T5 — task switching
  int get taskSwitching => throw _privateConstructorUsedError;

  /// B6 — burnout
  int get burnout => throw _privateConstructorUsedError;

  /// Create a copy of DiagnosticMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiagnosticMetricsCopyWith<DiagnosticMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiagnosticMetricsCopyWith<$Res> {
  factory $DiagnosticMetricsCopyWith(
          DiagnosticMetrics value, $Res Function(DiagnosticMetrics) then) =
      _$DiagnosticMetricsCopyWithImpl<$Res, DiagnosticMetrics>;
  @useResult
  $Res call(
      {int sleepQuality,
      int sustainedAttention,
      int fragmentation,
      int dopamineSeeking,
      int taskSwitching,
      int burnout});
}

/// @nodoc
class _$DiagnosticMetricsCopyWithImpl<$Res, $Val extends DiagnosticMetrics>
    implements $DiagnosticMetricsCopyWith<$Res> {
  _$DiagnosticMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiagnosticMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sleepQuality = null,
    Object? sustainedAttention = null,
    Object? fragmentation = null,
    Object? dopamineSeeking = null,
    Object? taskSwitching = null,
    Object? burnout = null,
  }) {
    return _then(_value.copyWith(
      sleepQuality: null == sleepQuality
          ? _value.sleepQuality
          : sleepQuality // ignore: cast_nullable_to_non_nullable
              as int,
      sustainedAttention: null == sustainedAttention
          ? _value.sustainedAttention
          : sustainedAttention // ignore: cast_nullable_to_non_nullable
              as int,
      fragmentation: null == fragmentation
          ? _value.fragmentation
          : fragmentation // ignore: cast_nullable_to_non_nullable
              as int,
      dopamineSeeking: null == dopamineSeeking
          ? _value.dopamineSeeking
          : dopamineSeeking // ignore: cast_nullable_to_non_nullable
              as int,
      taskSwitching: null == taskSwitching
          ? _value.taskSwitching
          : taskSwitching // ignore: cast_nullable_to_non_nullable
              as int,
      burnout: null == burnout
          ? _value.burnout
          : burnout // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DiagnosticMetricsImplCopyWith<$Res>
    implements $DiagnosticMetricsCopyWith<$Res> {
  factory _$$DiagnosticMetricsImplCopyWith(_$DiagnosticMetricsImpl value,
          $Res Function(_$DiagnosticMetricsImpl) then) =
      __$$DiagnosticMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int sleepQuality,
      int sustainedAttention,
      int fragmentation,
      int dopamineSeeking,
      int taskSwitching,
      int burnout});
}

/// @nodoc
class __$$DiagnosticMetricsImplCopyWithImpl<$Res>
    extends _$DiagnosticMetricsCopyWithImpl<$Res, _$DiagnosticMetricsImpl>
    implements _$$DiagnosticMetricsImplCopyWith<$Res> {
  __$$DiagnosticMetricsImplCopyWithImpl(_$DiagnosticMetricsImpl _value,
      $Res Function(_$DiagnosticMetricsImpl) _then)
      : super(_value, _then);

  /// Create a copy of DiagnosticMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sleepQuality = null,
    Object? sustainedAttention = null,
    Object? fragmentation = null,
    Object? dopamineSeeking = null,
    Object? taskSwitching = null,
    Object? burnout = null,
  }) {
    return _then(_$DiagnosticMetricsImpl(
      sleepQuality: null == sleepQuality
          ? _value.sleepQuality
          : sleepQuality // ignore: cast_nullable_to_non_nullable
              as int,
      sustainedAttention: null == sustainedAttention
          ? _value.sustainedAttention
          : sustainedAttention // ignore: cast_nullable_to_non_nullable
              as int,
      fragmentation: null == fragmentation
          ? _value.fragmentation
          : fragmentation // ignore: cast_nullable_to_non_nullable
              as int,
      dopamineSeeking: null == dopamineSeeking
          ? _value.dopamineSeeking
          : dopamineSeeking // ignore: cast_nullable_to_non_nullable
              as int,
      taskSwitching: null == taskSwitching
          ? _value.taskSwitching
          : taskSwitching // ignore: cast_nullable_to_non_nullable
              as int,
      burnout: null == burnout
          ? _value.burnout
          : burnout // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$DiagnosticMetricsImpl extends _DiagnosticMetrics {
  const _$DiagnosticMetricsImpl(
      {this.sleepQuality = 0,
      this.sustainedAttention = 0,
      this.fragmentation = 0,
      this.dopamineSeeking = 0,
      this.taskSwitching = 0,
      this.burnout = 0})
      : super._();

  /// S1 — sleep quality
  @override
  @JsonKey()
  final int sleepQuality;

  /// A2 — sustained attention
  @override
  @JsonKey()
  final int sustainedAttention;

  /// F3 — fragmentation
  @override
  @JsonKey()
  final int fragmentation;

  /// D4 — dopamine seeking
  @override
  @JsonKey()
  final int dopamineSeeking;

  /// T5 — task switching
  @override
  @JsonKey()
  final int taskSwitching;

  /// B6 — burnout
  @override
  @JsonKey()
  final int burnout;

  @override
  String toString() {
    return 'DiagnosticMetrics(sleepQuality: $sleepQuality, sustainedAttention: $sustainedAttention, fragmentation: $fragmentation, dopamineSeeking: $dopamineSeeking, taskSwitching: $taskSwitching, burnout: $burnout)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiagnosticMetricsImpl &&
            (identical(other.sleepQuality, sleepQuality) ||
                other.sleepQuality == sleepQuality) &&
            (identical(other.sustainedAttention, sustainedAttention) ||
                other.sustainedAttention == sustainedAttention) &&
            (identical(other.fragmentation, fragmentation) ||
                other.fragmentation == fragmentation) &&
            (identical(other.dopamineSeeking, dopamineSeeking) ||
                other.dopamineSeeking == dopamineSeeking) &&
            (identical(other.taskSwitching, taskSwitching) ||
                other.taskSwitching == taskSwitching) &&
            (identical(other.burnout, burnout) || other.burnout == burnout));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sleepQuality, sustainedAttention,
      fragmentation, dopamineSeeking, taskSwitching, burnout);

  /// Create a copy of DiagnosticMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiagnosticMetricsImplCopyWith<_$DiagnosticMetricsImpl> get copyWith =>
      __$$DiagnosticMetricsImplCopyWithImpl<_$DiagnosticMetricsImpl>(
          this, _$identity);
}

abstract class _DiagnosticMetrics extends DiagnosticMetrics {
  const factory _DiagnosticMetrics(
      {final int sleepQuality,
      final int sustainedAttention,
      final int fragmentation,
      final int dopamineSeeking,
      final int taskSwitching,
      final int burnout}) = _$DiagnosticMetricsImpl;
  const _DiagnosticMetrics._() : super._();

  /// S1 — sleep quality
  @override
  int get sleepQuality;

  /// A2 — sustained attention
  @override
  int get sustainedAttention;

  /// F3 — fragmentation
  @override
  int get fragmentation;

  /// D4 — dopamine seeking
  @override
  int get dopamineSeeking;

  /// T5 — task switching
  @override
  int get taskSwitching;

  /// B6 — burnout
  @override
  int get burnout;

  /// Create a copy of DiagnosticMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiagnosticMetricsImplCopyWith<_$DiagnosticMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
