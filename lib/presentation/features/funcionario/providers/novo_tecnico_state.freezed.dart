// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'novo_tecnico_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$NovoTecnicoState {
  bool get isSubmitting => throw _privateConstructorUsedError;
  String? get submissionError => throw _privateConstructorUsedError;

  /// Create a copy of NovoTecnicoState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NovoTecnicoStateCopyWith<NovoTecnicoState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NovoTecnicoStateCopyWith<$Res> {
  factory $NovoTecnicoStateCopyWith(
          NovoTecnicoState value, $Res Function(NovoTecnicoState) then) =
      _$NovoTecnicoStateCopyWithImpl<$Res, NovoTecnicoState>;
  @useResult
  $Res call({bool isSubmitting, String? submissionError});
}

/// @nodoc
class _$NovoTecnicoStateCopyWithImpl<$Res, $Val extends NovoTecnicoState>
    implements $NovoTecnicoStateCopyWith<$Res> {
  _$NovoTecnicoStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NovoTecnicoState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSubmitting = null,
    Object? submissionError = freezed,
  }) {
    return _then(_value.copyWith(
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      submissionError: freezed == submissionError
          ? _value.submissionError
          : submissionError // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NovoTecnicoStateImplCopyWith<$Res>
    implements $NovoTecnicoStateCopyWith<$Res> {
  factory _$$NovoTecnicoStateImplCopyWith(_$NovoTecnicoStateImpl value,
          $Res Function(_$NovoTecnicoStateImpl) then) =
      __$$NovoTecnicoStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isSubmitting, String? submissionError});
}

/// @nodoc
class __$$NovoTecnicoStateImplCopyWithImpl<$Res>
    extends _$NovoTecnicoStateCopyWithImpl<$Res, _$NovoTecnicoStateImpl>
    implements _$$NovoTecnicoStateImplCopyWith<$Res> {
  __$$NovoTecnicoStateImplCopyWithImpl(_$NovoTecnicoStateImpl _value,
      $Res Function(_$NovoTecnicoStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of NovoTecnicoState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSubmitting = null,
    Object? submissionError = freezed,
  }) {
    return _then(_$NovoTecnicoStateImpl(
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      submissionError: freezed == submissionError
          ? _value.submissionError
          : submissionError // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$NovoTecnicoStateImpl implements _NovoTecnicoState {
  const _$NovoTecnicoStateImpl(
      {this.isSubmitting = false, this.submissionError});

  @override
  @JsonKey()
  final bool isSubmitting;
  @override
  final String? submissionError;

  @override
  String toString() {
    return 'NovoTecnicoState(isSubmitting: $isSubmitting, submissionError: $submissionError)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NovoTecnicoStateImpl &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.submissionError, submissionError) ||
                other.submissionError == submissionError));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isSubmitting, submissionError);

  /// Create a copy of NovoTecnicoState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NovoTecnicoStateImplCopyWith<_$NovoTecnicoStateImpl> get copyWith =>
      __$$NovoTecnicoStateImplCopyWithImpl<_$NovoTecnicoStateImpl>(
          this, _$identity);
}

abstract class _NovoTecnicoState implements NovoTecnicoState {
  const factory _NovoTecnicoState(
      {final bool isSubmitting,
      final String? submissionError}) = _$NovoTecnicoStateImpl;

  @override
  bool get isSubmitting;
  @override
  String? get submissionError;

  /// Create a copy of NovoTecnicoState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NovoTecnicoStateImplCopyWith<_$NovoTecnicoStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
