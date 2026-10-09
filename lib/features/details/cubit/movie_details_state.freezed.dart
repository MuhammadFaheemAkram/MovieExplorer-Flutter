// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movie_details_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MovieDetailsState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MovieDetailsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MovieDetailsState()';
}


}

/// @nodoc
class $MovieDetailsStateCopyWith<$Res>  {
$MovieDetailsStateCopyWith(MovieDetailsState _, $Res Function(MovieDetailsState) __);
}


/// Adds pattern-matching-related methods to [MovieDetailsState].
extension MovieDetailsStatePatterns on MovieDetailsState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MovieDetailsLoading value)?  loading,TResult Function( MovieDetailsLoaded value)?  loaded,TResult Function( MovieDetailsError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MovieDetailsLoading() when loading != null:
return loading(_that);case MovieDetailsLoaded() when loaded != null:
return loaded(_that);case MovieDetailsError() when error != null:
return error(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MovieDetailsLoading value)  loading,required TResult Function( MovieDetailsLoaded value)  loaded,required TResult Function( MovieDetailsError value)  error,}){
final _that = this;
switch (_that) {
case MovieDetailsLoading():
return loading(_that);case MovieDetailsLoaded():
return loaded(_that);case MovieDetailsError():
return error(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MovieDetailsLoading value)?  loading,TResult? Function( MovieDetailsLoaded value)?  loaded,TResult? Function( MovieDetailsError value)?  error,}){
final _that = this;
switch (_that) {
case MovieDetailsLoading() when loading != null:
return loading(_that);case MovieDetailsLoaded() when loaded != null:
return loaded(_that);case MovieDetailsError() when error != null:
return error(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( Movie movie)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case MovieDetailsLoading() when loading != null:
return loading();case MovieDetailsLoaded() when loaded != null:
return loaded(_that.movie);case MovieDetailsError() when error != null:
return error(_that.message);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( Movie movie)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case MovieDetailsLoading():
return loading();case MovieDetailsLoaded():
return loaded(_that.movie);case MovieDetailsError():
return error(_that.message);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( Movie movie)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case MovieDetailsLoading() when loading != null:
return loading();case MovieDetailsLoaded() when loaded != null:
return loaded(_that.movie);case MovieDetailsError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class MovieDetailsLoading implements MovieDetailsState {
  const MovieDetailsLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MovieDetailsLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MovieDetailsState.loading()';
}


}




/// @nodoc


class MovieDetailsLoaded implements MovieDetailsState {
  const MovieDetailsLoaded(this.movie);
  

 final  Movie movie;

/// Create a copy of MovieDetailsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovieDetailsLoadedCopyWith<MovieDetailsLoaded> get copyWith => _$MovieDetailsLoadedCopyWithImpl<MovieDetailsLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MovieDetailsLoaded&&(identical(other.movie, movie) || other.movie == movie));
}


@override
int get hashCode {
    return Object.hash(runtimeType,movie);
}

@override
String toString() {
    return 'MovieDetailsState.loaded(movie: $movie)';
}


}

/// @nodoc
abstract mixin class $MovieDetailsLoadedCopyWith<$Res> implements $MovieDetailsStateCopyWith<$Res> {
  factory $MovieDetailsLoadedCopyWith(MovieDetailsLoaded value, $Res Function(MovieDetailsLoaded) _then) = _$MovieDetailsLoadedCopyWithImpl;
@useResult
$Res call({
 Movie movie
});


$MovieCopyWith<$Res> get movie;

}
/// @nodoc
class _$MovieDetailsLoadedCopyWithImpl<$Res>
    implements $MovieDetailsLoadedCopyWith<$Res> {
  _$MovieDetailsLoadedCopyWithImpl(this._self, this._then);

  final MovieDetailsLoaded _self;
  final $Res Function(MovieDetailsLoaded) _then;

/// Create a copy of MovieDetailsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? movie = null,}) {
  return _then(MovieDetailsLoaded(
null == movie ? _self.movie : movie // ignore: cast_nullable_to_non_nullable
as Movie,
  ));
}

/// Create a copy of MovieDetailsState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MovieCopyWith<$Res> get movie {
  
  return $MovieCopyWith<$Res>(_self.movie, (value) {
    return _then(_self.copyWith(movie: value));
  });
}
}

/// @nodoc


class MovieDetailsError implements MovieDetailsState {
  const MovieDetailsError(this.message);
  

 final  String message;

/// Create a copy of MovieDetailsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovieDetailsErrorCopyWith<MovieDetailsError> get copyWith => _$MovieDetailsErrorCopyWithImpl<MovieDetailsError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MovieDetailsError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'MovieDetailsState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $MovieDetailsErrorCopyWith<$Res> implements $MovieDetailsStateCopyWith<$Res> {
  factory $MovieDetailsErrorCopyWith(MovieDetailsError value, $Res Function(MovieDetailsError) _then) = _$MovieDetailsErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$MovieDetailsErrorCopyWithImpl<$Res>
    implements $MovieDetailsErrorCopyWith<$Res> {
  _$MovieDetailsErrorCopyWithImpl(this._self, this._then);

  final MovieDetailsError _self;
  final $Res Function(MovieDetailsError) _then;

/// Create a copy of MovieDetailsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(MovieDetailsError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
