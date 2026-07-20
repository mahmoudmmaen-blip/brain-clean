// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_program_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DailyStepEntry _$DailyStepEntryFromJson(Map<String, dynamic> json) {
  return _DailyStepEntry.fromJson(json);
}

/// @nodoc
mixin _$DailyStepEntry {
  DailyStep get step => throw _privateConstructorUsedError;
  DailyStepStatus get status => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DailyStepEntryCopyWith<DailyStepEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyStepEntryCopyWith<$Res> {
  factory $DailyStepEntryCopyWith(
          DailyStepEntry value, $Res Function(DailyStepEntry) then) =
      _$DailyStepEntryCopyWithImpl<$Res, DailyStepEntry>;
  @useResult
  $Res call({DailyStep step, DailyStepStatus status, DateTime? completedAt});
}

/// @nodoc
class _$DailyStepEntryCopyWithImpl<$Res, $Val extends DailyStepEntry>
    implements $DailyStepEntryCopyWith<$Res> {
  _$DailyStepEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? step = null,
    Object? status = null,
    Object? completedAt = freezed,
  }) {
    return _then(_value.copyWith(
      step: null == step
          ? _value.step
          : step // ignore: cast_nullable_to_non_nullable
              as DailyStep,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DailyStepStatus,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyStepEntryImplCopyWith<$Res>
    implements $DailyStepEntryCopyWith<$Res> {
  factory _$$DailyStepEntryImplCopyWith(_$DailyStepEntryImpl value,
          $Res Function(_$DailyStepEntryImpl) then) =
      __$$DailyStepEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DailyStep step, DailyStepStatus status, DateTime? completedAt});
}

/// @nodoc
class __$$DailyStepEntryImplCopyWithImpl<$Res>
    extends _$DailyStepEntryCopyWithImpl<$Res, _$DailyStepEntryImpl>
    implements _$$DailyStepEntryImplCopyWith<$Res> {
  __$$DailyStepEntryImplCopyWithImpl(
      _$DailyStepEntryImpl _value, $Res Function(_$DailyStepEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? step = null,
    Object? status = null,
    Object? completedAt = freezed,
  }) {
    return _then(_$DailyStepEntryImpl(
      step: null == step
          ? _value.step
          : step // ignore: cast_nullable_to_non_nullable
              as DailyStep,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DailyStepStatus,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyStepEntryImpl implements _DailyStepEntry {
  const _$DailyStepEntryImpl(
      {required this.step, required this.status, this.completedAt});

  factory _$DailyStepEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyStepEntryImplFromJson(json);

  @override
  final DailyStep step;
  @override
  final DailyStepStatus status;
  @override
  final DateTime? completedAt;

  @override
  String toString() {
    return 'DailyStepEntry(step: $step, status: $status, completedAt: $completedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyStepEntryImpl &&
            (identical(other.step, step) || other.step == step) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, step, status, completedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyStepEntryImplCopyWith<_$DailyStepEntryImpl> get copyWith =>
      __$$DailyStepEntryImplCopyWithImpl<_$DailyStepEntryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyStepEntryImplToJson(
      this,
    );
  }
}

abstract class _DailyStepEntry implements DailyStepEntry {
  const factory _DailyStepEntry(
      {required final DailyStep step,
      required final DailyStepStatus status,
      final DateTime? completedAt}) = _$DailyStepEntryImpl;

  factory _DailyStepEntry.fromJson(Map<String, dynamic> json) =
      _$DailyStepEntryImpl.fromJson;

  @override
  DailyStep get step;
  @override
  DailyStepStatus get status;
  @override
  DateTime? get completedAt;
  @override
  @JsonKey(ignore: true)
  _$$DailyStepEntryImplCopyWith<_$DailyStepEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyProgramState _$DailyProgramStateFromJson(Map<String, dynamic> json) {
  return _DailyProgramState.fromJson(json);
}

/// @nodoc
mixin _$DailyProgramState {
  DateTime get date => throw _privateConstructorUsedError;
  int get dayNumber => throw _privateConstructorUsedError;
  List<DailyStepEntry> get steps => throw _privateConstructorUsedError;
  String? get reflectionNote => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DailyProgramStateCopyWith<DailyProgramState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyProgramStateCopyWith<$Res> {
  factory $DailyProgramStateCopyWith(
          DailyProgramState value, $Res Function(DailyProgramState) then) =
      _$DailyProgramStateCopyWithImpl<$Res, DailyProgramState>;
  @useResult
  $Res call(
      {DateTime date,
      int dayNumber,
      List<DailyStepEntry> steps,
      String? reflectionNote});
}

/// @nodoc
class _$DailyProgramStateCopyWithImpl<$Res, $Val extends DailyProgramState>
    implements $DailyProgramStateCopyWith<$Res> {
  _$DailyProgramStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? dayNumber = null,
    Object? steps = null,
    Object? reflectionNote = freezed,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dayNumber: null == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int,
      steps: null == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<DailyStepEntry>,
      reflectionNote: freezed == reflectionNote
          ? _value.reflectionNote
          : reflectionNote // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyProgramStateImplCopyWith<$Res>
    implements $DailyProgramStateCopyWith<$Res> {
  factory _$$DailyProgramStateImplCopyWith(_$DailyProgramStateImpl value,
          $Res Function(_$DailyProgramStateImpl) then) =
      __$$DailyProgramStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      int dayNumber,
      List<DailyStepEntry> steps,
      String? reflectionNote});
}

/// @nodoc
class __$$DailyProgramStateImplCopyWithImpl<$Res>
    extends _$DailyProgramStateCopyWithImpl<$Res, _$DailyProgramStateImpl>
    implements _$$DailyProgramStateImplCopyWith<$Res> {
  __$$DailyProgramStateImplCopyWithImpl(_$DailyProgramStateImpl _value,
      $Res Function(_$DailyProgramStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? dayNumber = null,
    Object? steps = null,
    Object? reflectionNote = freezed,
  }) {
    return _then(_$DailyProgramStateImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dayNumber: null == dayNumber
          ? _value.dayNumber
          : dayNumber // ignore: cast_nullable_to_non_nullable
              as int,
      steps: null == steps
          ? _value._steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<DailyStepEntry>,
      reflectionNote: freezed == reflectionNote
          ? _value.reflectionNote
          : reflectionNote // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$DailyProgramStateImpl extends _DailyProgramState {
  const _$DailyProgramStateImpl(
      {required this.date,
      required this.dayNumber,
      required final List<DailyStepEntry> steps,
      this.reflectionNote})
      : _steps = steps,
        super._();

  factory _$DailyProgramStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyProgramStateImplFromJson(json);

  @override
  final DateTime date;
  @override
  final int dayNumber;
  final List<DailyStepEntry> _steps;
  @override
  List<DailyStepEntry> get steps {
    if (_steps is EqualUnmodifiableListView) return _steps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_steps);
  }

  @override
  final String? reflectionNote;

  @override
  String toString() {
    return 'DailyProgramState(date: $date, dayNumber: $dayNumber, steps: $steps, reflectionNote: $reflectionNote)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyProgramStateImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.dayNumber, dayNumber) ||
                other.dayNumber == dayNumber) &&
            const DeepCollectionEquality().equals(other._steps, _steps) &&
            (identical(other.reflectionNote, reflectionNote) ||
                other.reflectionNote == reflectionNote));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, date, dayNumber,
      const DeepCollectionEquality().hash(_steps), reflectionNote);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyProgramStateImplCopyWith<_$DailyProgramStateImpl> get copyWith =>
      __$$DailyProgramStateImplCopyWithImpl<_$DailyProgramStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyProgramStateImplToJson(
      this,
    );
  }
}

abstract class _DailyProgramState extends DailyProgramState {
  const factory _DailyProgramState(
      {required final DateTime date,
      required final int dayNumber,
      required final List<DailyStepEntry> steps,
      final String? reflectionNote}) = _$DailyProgramStateImpl;
  const _DailyProgramState._() : super._();

  factory _DailyProgramState.fromJson(Map<String, dynamic> json) =
      _$DailyProgramStateImpl.fromJson;

  @override
  DateTime get date;
  @override
  int get dayNumber;
  @override
  List<DailyStepEntry> get steps;
  @override
  String? get reflectionNote;
  @override
  @JsonKey(ignore: true)
  _$$DailyProgramStateImplCopyWith<_$DailyProgramStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
