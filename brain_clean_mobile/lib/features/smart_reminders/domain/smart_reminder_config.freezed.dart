// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'smart_reminder_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SmartReminderConfig _$SmartReminderConfigFromJson(Map<String, dynamic> json) {
  return _SmartReminderConfig.fromJson(json);
}

/// @nodoc
mixin _$SmartReminderConfig {
  bool get isEnabled => throw _privateConstructorUsedError;
  int? get detectedHour => throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SmartReminderConfigCopyWith<SmartReminderConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SmartReminderConfigCopyWith<$Res> {
  factory $SmartReminderConfigCopyWith(
          SmartReminderConfig value, $Res Function(SmartReminderConfig) then) =
      _$SmartReminderConfigCopyWithImpl<$Res, SmartReminderConfig>;
  @useResult
  $Res call({bool isEnabled, int? detectedHour, DateTime? lastUpdated});
}

/// @nodoc
class _$SmartReminderConfigCopyWithImpl<$Res, $Val extends SmartReminderConfig>
    implements $SmartReminderConfigCopyWith<$Res> {
  _$SmartReminderConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isEnabled = null,
    Object? detectedHour = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      detectedHour: freezed == detectedHour
          ? _value.detectedHour
          : detectedHour // ignore: cast_nullable_to_non_nullable
              as int?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SmartReminderConfigImplCopyWith<$Res>
    implements $SmartReminderConfigCopyWith<$Res> {
  factory _$$SmartReminderConfigImplCopyWith(_$SmartReminderConfigImpl value,
          $Res Function(_$SmartReminderConfigImpl) then) =
      __$$SmartReminderConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isEnabled, int? detectedHour, DateTime? lastUpdated});
}

/// @nodoc
class __$$SmartReminderConfigImplCopyWithImpl<$Res>
    extends _$SmartReminderConfigCopyWithImpl<$Res, _$SmartReminderConfigImpl>
    implements _$$SmartReminderConfigImplCopyWith<$Res> {
  __$$SmartReminderConfigImplCopyWithImpl(_$SmartReminderConfigImpl _value,
      $Res Function(_$SmartReminderConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isEnabled = null,
    Object? detectedHour = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$SmartReminderConfigImpl(
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      detectedHour: freezed == detectedHour
          ? _value.detectedHour
          : detectedHour // ignore: cast_nullable_to_non_nullable
              as int?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SmartReminderConfigImpl implements _SmartReminderConfig {
  const _$SmartReminderConfigImpl(
      {this.isEnabled = false, this.detectedHour, this.lastUpdated});

  factory _$SmartReminderConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$SmartReminderConfigImplFromJson(json);

  @override
  @JsonKey()
  final bool isEnabled;
  @override
  final int? detectedHour;
  @override
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'SmartReminderConfig(isEnabled: $isEnabled, detectedHour: $detectedHour, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SmartReminderConfigImpl &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            (identical(other.detectedHour, detectedHour) ||
                other.detectedHour == detectedHour) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, isEnabled, detectedHour, lastUpdated);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SmartReminderConfigImplCopyWith<_$SmartReminderConfigImpl> get copyWith =>
      __$$SmartReminderConfigImplCopyWithImpl<_$SmartReminderConfigImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SmartReminderConfigImplToJson(
      this,
    );
  }
}

abstract class _SmartReminderConfig implements SmartReminderConfig {
  const factory _SmartReminderConfig(
      {final bool isEnabled,
      final int? detectedHour,
      final DateTime? lastUpdated}) = _$SmartReminderConfigImpl;

  factory _SmartReminderConfig.fromJson(Map<String, dynamic> json) =
      _$SmartReminderConfigImpl.fromJson;

  @override
  bool get isEnabled;
  @override
  int? get detectedHour;
  @override
  DateTime? get lastUpdated;
  @override
  @JsonKey(ignore: true)
  _$$SmartReminderConfigImplCopyWith<_$SmartReminderConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
