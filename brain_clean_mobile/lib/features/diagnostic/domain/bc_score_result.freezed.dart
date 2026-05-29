// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bc_score_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BcScoreResult {
  /// Normalized Brain Clarity / Focus score \[0, 100\].
  double get bcScore => throw _privateConstructorUsedError;
  double get rawScore => throw _privateConstructorUsedError;

  /// (S1 + A2) × 1.5
  double get positiveArm => throw _privateConstructorUsedError;

  /// (F3 + D4 + T5 + B6) × 0.8
  double get negativeArm => throw _privateConstructorUsedError;
  DateTime get calculatedAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BcScoreResultCopyWith<BcScoreResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BcScoreResultCopyWith<$Res> {
  factory $BcScoreResultCopyWith(
          BcScoreResult value, $Res Function(BcScoreResult) then) =
      _$BcScoreResultCopyWithImpl<$Res, BcScoreResult>;
  @useResult
  $Res call(
      {double bcScore,
      double rawScore,
      double positiveArm,
      double negativeArm,
      DateTime calculatedAt});
}

/// @nodoc
class _$BcScoreResultCopyWithImpl<$Res, $Val extends BcScoreResult>
    implements $BcScoreResultCopyWith<$Res> {
  _$BcScoreResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bcScore = null,
    Object? rawScore = null,
    Object? positiveArm = null,
    Object? negativeArm = null,
    Object? calculatedAt = null,
  }) {
    return _then(_value.copyWith(
      bcScore: null == bcScore
          ? _value.bcScore
          : bcScore // ignore: cast_nullable_to_non_nullable
              as double,
      rawScore: null == rawScore
          ? _value.rawScore
          : rawScore // ignore: cast_nullable_to_non_nullable
              as double,
      positiveArm: null == positiveArm
          ? _value.positiveArm
          : positiveArm // ignore: cast_nullable_to_non_nullable
              as double,
      negativeArm: null == negativeArm
          ? _value.negativeArm
          : negativeArm // ignore: cast_nullable_to_non_nullable
              as double,
      calculatedAt: null == calculatedAt
          ? _value.calculatedAt
          : calculatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BcScoreResultImplCopyWith<$Res>
    implements $BcScoreResultCopyWith<$Res> {
  factory _$$BcScoreResultImplCopyWith(
          _$BcScoreResultImpl value, $Res Function(_$BcScoreResultImpl) then) =
      __$$BcScoreResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double bcScore,
      double rawScore,
      double positiveArm,
      double negativeArm,
      DateTime calculatedAt});
}

/// @nodoc
class __$$BcScoreResultImplCopyWithImpl<$Res>
    extends _$BcScoreResultCopyWithImpl<$Res, _$BcScoreResultImpl>
    implements _$$BcScoreResultImplCopyWith<$Res> {
  __$$BcScoreResultImplCopyWithImpl(
      _$BcScoreResultImpl _value, $Res Function(_$BcScoreResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bcScore = null,
    Object? rawScore = null,
    Object? positiveArm = null,
    Object? negativeArm = null,
    Object? calculatedAt = null,
  }) {
    return _then(_$BcScoreResultImpl(
      bcScore: null == bcScore
          ? _value.bcScore
          : bcScore // ignore: cast_nullable_to_non_nullable
              as double,
      rawScore: null == rawScore
          ? _value.rawScore
          : rawScore // ignore: cast_nullable_to_non_nullable
              as double,
      positiveArm: null == positiveArm
          ? _value.positiveArm
          : positiveArm // ignore: cast_nullable_to_non_nullable
              as double,
      negativeArm: null == negativeArm
          ? _value.negativeArm
          : negativeArm // ignore: cast_nullable_to_non_nullable
              as double,
      calculatedAt: null == calculatedAt
          ? _value.calculatedAt
          : calculatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$BcScoreResultImpl extends _BcScoreResult {
  const _$BcScoreResultImpl(
      {required this.bcScore,
      required this.rawScore,
      required this.positiveArm,
      required this.negativeArm,
      required this.calculatedAt})
      : super._();

  /// Normalized Brain Clarity / Focus score \[0, 100\].
  @override
  final double bcScore;
  @override
  final double rawScore;

  /// (S1 + A2) × 1.5
  @override
  final double positiveArm;

  /// (F3 + D4 + T5 + B6) × 0.8
  @override
  final double negativeArm;
  @override
  final DateTime calculatedAt;

  @override
  String toString() {
    return 'BcScoreResult(bcScore: $bcScore, rawScore: $rawScore, positiveArm: $positiveArm, negativeArm: $negativeArm, calculatedAt: $calculatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BcScoreResultImpl &&
            (identical(other.bcScore, bcScore) || other.bcScore == bcScore) &&
            (identical(other.rawScore, rawScore) ||
                other.rawScore == rawScore) &&
            (identical(other.positiveArm, positiveArm) ||
                other.positiveArm == positiveArm) &&
            (identical(other.negativeArm, negativeArm) ||
                other.negativeArm == negativeArm) &&
            (identical(other.calculatedAt, calculatedAt) ||
                other.calculatedAt == calculatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, bcScore, rawScore, positiveArm, negativeArm, calculatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BcScoreResultImplCopyWith<_$BcScoreResultImpl> get copyWith =>
      __$$BcScoreResultImplCopyWithImpl<_$BcScoreResultImpl>(this, _$identity);
}

abstract class _BcScoreResult extends BcScoreResult {
  const factory _BcScoreResult(
      {required final double bcScore,
      required final double rawScore,
      required final double positiveArm,
      required final double negativeArm,
      required final DateTime calculatedAt}) = _$BcScoreResultImpl;
  const _BcScoreResult._() : super._();

  @override

  /// Normalized Brain Clarity / Focus score \[0, 100\].
  double get bcScore;
  @override
  double get rawScore;
  @override

  /// (S1 + A2) × 1.5
  double get positiveArm;
  @override

  /// (F3 + D4 + T5 + B6) × 0.8
  double get negativeArm;
  @override
  DateTime get calculatedAt;
  @override
  @JsonKey(ignore: true)
  _$$BcScoreResultImplCopyWith<_$BcScoreResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
