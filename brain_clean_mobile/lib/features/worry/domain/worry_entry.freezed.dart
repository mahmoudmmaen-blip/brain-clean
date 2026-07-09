// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'worry_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WorryEntry _$WorryEntryFromJson(Map<String, dynamic> json) {
  return _WorryEntry.fromJson(json);
}

/// @nodoc
mixin _$WorryEntry {
  String get id => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get sessionMinutes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WorryEntryCopyWith<WorryEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorryEntryCopyWith<$Res> {
  factory $WorryEntryCopyWith(
          WorryEntry value, $Res Function(WorryEntry) then) =
      _$WorryEntryCopyWithImpl<$Res, WorryEntry>;
  @useResult
  $Res call(
      {String id, String content, DateTime createdAt, int sessionMinutes});
}

/// @nodoc
class _$WorryEntryCopyWithImpl<$Res, $Val extends WorryEntry>
    implements $WorryEntryCopyWith<$Res> {
  _$WorryEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? createdAt = null,
    Object? sessionMinutes = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sessionMinutes: null == sessionMinutes
          ? _value.sessionMinutes
          : sessionMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorryEntryImplCopyWith<$Res>
    implements $WorryEntryCopyWith<$Res> {
  factory _$$WorryEntryImplCopyWith(
          _$WorryEntryImpl value, $Res Function(_$WorryEntryImpl) then) =
      __$$WorryEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id, String content, DateTime createdAt, int sessionMinutes});
}

/// @nodoc
class __$$WorryEntryImplCopyWithImpl<$Res>
    extends _$WorryEntryCopyWithImpl<$Res, _$WorryEntryImpl>
    implements _$$WorryEntryImplCopyWith<$Res> {
  __$$WorryEntryImplCopyWithImpl(
      _$WorryEntryImpl _value, $Res Function(_$WorryEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? createdAt = null,
    Object? sessionMinutes = null,
  }) {
    return _then(_$WorryEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sessionMinutes: null == sessionMinutes
          ? _value.sessionMinutes
          : sessionMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorryEntryImpl implements _WorryEntry {
  const _$WorryEntryImpl(
      {required this.id,
      required this.content,
      required this.createdAt,
      this.sessionMinutes = 0});

  factory _$WorryEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorryEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String content;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final int sessionMinutes;

  @override
  String toString() {
    return 'WorryEntry(id: $id, content: $content, createdAt: $createdAt, sessionMinutes: $sessionMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorryEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.sessionMinutes, sessionMinutes) ||
                other.sessionMinutes == sessionMinutes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, content, createdAt, sessionMinutes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorryEntryImplCopyWith<_$WorryEntryImpl> get copyWith =>
      __$$WorryEntryImplCopyWithImpl<_$WorryEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorryEntryImplToJson(
      this,
    );
  }
}

abstract class _WorryEntry implements WorryEntry {
  const factory _WorryEntry(
      {required final String id,
      required final String content,
      required final DateTime createdAt,
      final int sessionMinutes}) = _$WorryEntryImpl;

  factory _WorryEntry.fromJson(Map<String, dynamic> json) =
      _$WorryEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get content;
  @override
  DateTime get createdAt;
  @override
  int get sessionMinutes;
  @override
  @JsonKey(ignore: true)
  _$$WorryEntryImplCopyWith<_$WorryEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
