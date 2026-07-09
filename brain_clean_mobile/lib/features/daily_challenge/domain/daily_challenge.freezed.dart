// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_challenge.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DailyChallenge _$DailyChallengeFromJson(Map<String, dynamic> json) {
  return _DailyChallenge.fromJson(json);
}

/// @nodoc
mixin _$DailyChallenge {
  DateTime get date => throw _privateConstructorUsedError;
  String get gameKey => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DailyChallengeCopyWith<DailyChallenge> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyChallengeCopyWith<$Res> {
  factory $DailyChallengeCopyWith(
          DailyChallenge value, $Res Function(DailyChallenge) then) =
      _$DailyChallengeCopyWithImpl<$Res, DailyChallenge>;
  @useResult
  $Res call(
      {DateTime date, String gameKey, bool isCompleted, DateTime? completedAt});
}

/// @nodoc
class _$DailyChallengeCopyWithImpl<$Res, $Val extends DailyChallenge>
    implements $DailyChallengeCopyWith<$Res> {
  _$DailyChallengeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? gameKey = null,
    Object? isCompleted = null,
    Object? completedAt = freezed,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      gameKey: null == gameKey
          ? _value.gameKey
          : gameKey // ignore: cast_nullable_to_non_nullable
              as String,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyChallengeImplCopyWith<$Res>
    implements $DailyChallengeCopyWith<$Res> {
  factory _$$DailyChallengeImplCopyWith(_$DailyChallengeImpl value,
          $Res Function(_$DailyChallengeImpl) then) =
      __$$DailyChallengeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date, String gameKey, bool isCompleted, DateTime? completedAt});
}

/// @nodoc
class __$$DailyChallengeImplCopyWithImpl<$Res>
    extends _$DailyChallengeCopyWithImpl<$Res, _$DailyChallengeImpl>
    implements _$$DailyChallengeImplCopyWith<$Res> {
  __$$DailyChallengeImplCopyWithImpl(
      _$DailyChallengeImpl _value, $Res Function(_$DailyChallengeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? gameKey = null,
    Object? isCompleted = null,
    Object? completedAt = freezed,
  }) {
    return _then(_$DailyChallengeImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      gameKey: null == gameKey
          ? _value.gameKey
          : gameKey // ignore: cast_nullable_to_non_nullable
              as String,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyChallengeImpl implements _DailyChallenge {
  const _$DailyChallengeImpl(
      {required this.date,
      required this.gameKey,
      this.isCompleted = false,
      this.completedAt});

  factory _$DailyChallengeImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyChallengeImplFromJson(json);

  @override
  final DateTime date;
  @override
  final String gameKey;
  @override
  @JsonKey()
  final bool isCompleted;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'DailyChallenge(date: $date, gameKey: $gameKey, isCompleted: $isCompleted, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyChallengeImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.gameKey, gameKey) || other.gameKey == gameKey) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, date, gameKey, isCompleted, completedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyChallengeImplCopyWith<_$DailyChallengeImpl> get copyWith =>
      __$$DailyChallengeImplCopyWithImpl<_$DailyChallengeImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyChallengeImplToJson(
      this,
    );
  }
}

abstract class _DailyChallenge implements DailyChallenge {
  const factory _DailyChallenge(
      {required final DateTime date,
      required final String gameKey,
      final bool isCompleted,
      final DateTime? completedAt}) = _$DailyChallengeImpl;

  factory _DailyChallenge.fromJson(Map<String, dynamic> json) =
      _$DailyChallengeImpl.fromJson;

  @override
  DateTime get date;
  @override
  String get gameKey;
  @override
  bool get isCompleted;
  @override
  DateTime? get completedAt;
  @override
  @JsonKey(ignore: true)
  _$$DailyChallengeImplCopyWith<_$DailyChallengeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
