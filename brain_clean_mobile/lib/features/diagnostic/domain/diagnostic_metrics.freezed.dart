// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diagnostic_metrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DiagnosticMetrics _$DiagnosticMetricsFromJson(Map<String, dynamic> json) {
  return _DiagnosticMetrics.fromJson(json);
}

/// @nodoc
mixin _$DiagnosticMetrics {
  int get sleepQuality => throw _privateConstructorUsedError;
  int get sustainedAttention => throw _privateConstructorUsedError;
  int get fragmentation => throw _privateConstructorUsedError;
  int get dopamineSeeking => throw _privateConstructorUsedError;
  int get taskSwitching => throw _privateConstructorUsedError;
  int get burnout => throw _privateConstructorUsedError;

  /// Serializes this DiagnosticMetrics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

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
@JsonSerializable()
class _$DiagnosticMetricsImpl implements _DiagnosticMetrics {
  const _$DiagnosticMetricsImpl(
      {this.sleepQuality = 5,
      this.sustainedAttention = 5,
      this.fragmentation = 5,
      this.dopamineSeeking = 5,
      this.taskSwitching = 5,
      this.burnout = 5});

  factory _$DiagnosticMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiagnosticMetricsImplFromJson(json);

  @override
  @JsonKey()
  final int sleepQuality;
  @override
  @JsonKey()
  final int sustainedAttention;
  @override
  @JsonKey()
  final int fragmentation;
  @override
  @JsonKey()
  final int dopamineSeeking;
  @override
  @JsonKey()
  final int taskSwitching;
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

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  @override
  Map<String, dynamic> toJson() {
    return _$$DiagnosticMetricsImplToJson(
      this,
    );
  }
}

abstract class _DiagnosticMetrics implements DiagnosticMetrics {
  const factory _DiagnosticMetrics(
      {final int sleepQuality,
      final int sustainedAttention,
      final int fragmentation,
      final int dopamineSeeking,
      final int taskSwitching,
      final int burnout}) = _$DiagnosticMetricsImpl;

  factory _DiagnosticMetrics.fromJson(Map<String, dynamic> json) =
      _$DiagnosticMetricsImpl.fromJson;

  @override
  int get sleepQuality;
  @override
  int get sustainedAttention;
  @override
  int get fragmentation;
  @override
  int get dopamineSeeking;
  @override
  int get taskSwitching;
  @override
  int get burnout;

  /// Create a copy of DiagnosticMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiagnosticMetricsImplCopyWith<_$DiagnosticMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
