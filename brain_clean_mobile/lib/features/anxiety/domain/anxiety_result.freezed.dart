// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'anxiety_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AnxietyResult _$AnxietyResultFromJson(Map<String, dynamic> json) {
  return _AnxietyResult.fromJson(json);
}

/// @nodoc
mixin _$AnxietyResult {
  List<int> get answers => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;
  AnxietyLevel get level => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AnxietyResultCopyWith<AnxietyResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnxietyResultCopyWith<$Res> {
  factory $AnxietyResultCopyWith(
          AnxietyResult value, $Res Function(AnxietyResult) then) =
      _$AnxietyResultCopyWithImpl<$Res, AnxietyResult>;
  @useResult
  $Res call(
      {List<int> answers,
      double score,
      AnxietyLevel level,
      DateTime timestamp});
}

/// @nodoc
class _$AnxietyResultCopyWithImpl<$Res, $Val extends AnxietyResult>
    implements $AnxietyResultCopyWith<$Res> {
  _$AnxietyResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? answers = null,
    Object? score = null,
    Object? level = null,
    Object? timestamp = null,
  }) {
    return _then(_value.copyWith(
      answers: null == answers
          ? _value.answers
          : answers // ignore: cast_nullable_to_non_nullable
              as List<int>,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as AnxietyLevel,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AnxietyResultImplCopyWith<$Res>
    implements $AnxietyResultCopyWith<$Res> {
  factory _$$AnxietyResultImplCopyWith(
          _$AnxietyResultImpl value, $Res Function(_$AnxietyResultImpl) then) =
      __$$AnxietyResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<int> answers,
      double score,
      AnxietyLevel level,
      DateTime timestamp});
}

/// @nodoc
class __$$AnxietyResultImplCopyWithImpl<$Res>
    extends _$AnxietyResultCopyWithImpl<$Res, _$AnxietyResultImpl>
    implements _$$AnxietyResultImplCopyWith<$Res> {
  __$$AnxietyResultImplCopyWithImpl(
      _$AnxietyResultImpl _value, $Res Function(_$AnxietyResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? answers = null,
    Object? score = null,
    Object? level = null,
    Object? timestamp = null,
  }) {
    return _then(_$AnxietyResultImpl(
      answers: null == answers
          ? _value._answers
          : answers // ignore: cast_nullable_to_non_nullable
              as List<int>,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as AnxietyLevel,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AnxietyResultImpl implements _AnxietyResult {
  const _$AnxietyResultImpl(
      {required final List<int> answers,
      required this.score,
      required this.level,
      required this.timestamp})
      : _answers = answers;

  factory _$AnxietyResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnxietyResultImplFromJson(json);

  final List<int> _answers;
  @override
  List<int> get answers {
    if (_answers is EqualUnmodifiableListView) return _answers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_answers);
  }

  @override
  final double score;
  @override
  final AnxietyLevel level;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'AnxietyResult(answers: $answers, score: $score, level: $level, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnxietyResultImpl &&
            const DeepCollectionEquality().equals(other._answers, _answers) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_answers), score, level, timestamp);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AnxietyResultImplCopyWith<_$AnxietyResultImpl> get copyWith =>
      __$$AnxietyResultImplCopyWithImpl<_$AnxietyResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnxietyResultImplToJson(
      this,
    );
  }
}

abstract class _AnxietyResult implements AnxietyResult {
  const factory _AnxietyResult(
      {required final List<int> answers,
      required final double score,
      required final AnxietyLevel level,
      required final DateTime timestamp}) = _$AnxietyResultImpl;

  factory _AnxietyResult.fromJson(Map<String, dynamic> json) =
      _$AnxietyResultImpl.fromJson;

  @override
  List<int> get answers;
  @override
  double get score;
  @override
  AnxietyLevel get level;
  @override
  DateTime get timestamp;
  @override
  @JsonKey(ignore: true)
  _$$AnxietyResultImplCopyWith<_$AnxietyResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
