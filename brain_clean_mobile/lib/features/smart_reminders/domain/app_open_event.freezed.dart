// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_open_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppOpenEvent _$AppOpenEventFromJson(Map<String, dynamic> json) {
  return _AppOpenEvent.fromJson(json);
}

/// @nodoc
mixin _$AppOpenEvent {
  DateTime get openedAt => throw _privateConstructorUsedError;
  int get hourOfDay => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AppOpenEventCopyWith<AppOpenEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppOpenEventCopyWith<$Res> {
  factory $AppOpenEventCopyWith(
          AppOpenEvent value, $Res Function(AppOpenEvent) then) =
      _$AppOpenEventCopyWithImpl<$Res, AppOpenEvent>;
  @useResult
  $Res call({DateTime openedAt, int hourOfDay});
}

/// @nodoc
class _$AppOpenEventCopyWithImpl<$Res, $Val extends AppOpenEvent>
    implements $AppOpenEventCopyWith<$Res> {
  _$AppOpenEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? openedAt = null,
    Object? hourOfDay = null,
  }) {
    return _then(_value.copyWith(
      openedAt: null == openedAt
          ? _value.openedAt
          : openedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      hourOfDay: null == hourOfDay
          ? _value.hourOfDay
          : hourOfDay // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppOpenEventImplCopyWith<$Res>
    implements $AppOpenEventCopyWith<$Res> {
  factory _$$AppOpenEventImplCopyWith(
          _$AppOpenEventImpl value, $Res Function(_$AppOpenEventImpl) then) =
      __$$AppOpenEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime openedAt, int hourOfDay});
}

/// @nodoc
class __$$AppOpenEventImplCopyWithImpl<$Res>
    extends _$AppOpenEventCopyWithImpl<$Res, _$AppOpenEventImpl>
    implements _$$AppOpenEventImplCopyWith<$Res> {
  __$$AppOpenEventImplCopyWithImpl(
      _$AppOpenEventImpl _value, $Res Function(_$AppOpenEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? openedAt = null,
    Object? hourOfDay = null,
  }) {
    return _then(_$AppOpenEventImpl(
      openedAt: null == openedAt
          ? _value.openedAt
          : openedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      hourOfDay: null == hourOfDay
          ? _value.hourOfDay
          : hourOfDay // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppOpenEventImpl implements _AppOpenEvent {
  const _$AppOpenEventImpl({required this.openedAt, required this.hourOfDay});

  factory _$AppOpenEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppOpenEventImplFromJson(json);

  @override
  final DateTime openedAt;
  @override
  final int hourOfDay;

  @override
  String toString() {
    return 'AppOpenEvent(openedAt: $openedAt, hourOfDay: $hourOfDay)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppOpenEventImpl &&
            (identical(other.openedAt, openedAt) ||
                other.openedAt == openedAt) &&
            (identical(other.hourOfDay, hourOfDay) ||
                other.hourOfDay == hourOfDay));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, openedAt, hourOfDay);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppOpenEventImplCopyWith<_$AppOpenEventImpl> get copyWith =>
      __$$AppOpenEventImplCopyWithImpl<_$AppOpenEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppOpenEventImplToJson(
      this,
    );
  }
}

abstract class _AppOpenEvent implements AppOpenEvent {
  const factory _AppOpenEvent(
      {required final DateTime openedAt,
      required final int hourOfDay}) = _$AppOpenEventImpl;

  factory _AppOpenEvent.fromJson(Map<String, dynamic> json) =
      _$AppOpenEventImpl.fromJson;

  @override
  DateTime get openedAt;
  @override
  int get hourOfDay;
  @override
  @JsonKey(ignore: true)
  _$$AppOpenEventImplCopyWith<_$AppOpenEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
