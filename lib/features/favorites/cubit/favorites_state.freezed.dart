// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorites_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FavoritesState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoritesState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FavoritesState()';
}


}

/// @nodoc
class $FavoritesStateCopyWith<$Res>  {
$FavoritesStateCopyWith(FavoritesState _, $Res Function(FavoritesState) __);
}


/// Adds pattern-matching-related methods to [FavoritesState].
extension FavoritesStatePatterns on FavoritesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FavoritesLoading value)?  loading,TResult Function( FavoritesEmpty value)?  empty,TResult Function( FavoritesLoaded value)?  loaded,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FavoritesLoading() when loading != null:
return loading(_that);case FavoritesEmpty() when empty != null:
return empty(_that);case FavoritesLoaded() when loaded != null:
return loaded(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FavoritesLoading value)  loading,required TResult Function( FavoritesEmpty value)  empty,required TResult Function( FavoritesLoaded value)  loaded,}){
final _that = this;
switch (_that) {
case FavoritesLoading():
return loading(_that);case FavoritesEmpty():
return empty(_that);case FavoritesLoaded():
return loaded(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FavoritesLoading value)?  loading,TResult? Function( FavoritesEmpty value)?  empty,TResult? Function( FavoritesLoaded value)?  loaded,}){
final _that = this;
switch (_that) {
case FavoritesLoading() when loading != null:
return loading(_that);case FavoritesEmpty() when empty != null:
return empty(_that);case FavoritesLoaded() when loaded != null:
return loaded(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function()?  empty,TResult Function( List<Movie> movies)?  loaded,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FavoritesLoading() when loading != null:
return loading();case FavoritesEmpty() when empty != null:
return empty();case FavoritesLoaded() when loaded != null:
return loaded(_that.movies);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function()  empty,required TResult Function( List<Movie> movies)  loaded,}) {final _that = this;
switch (_that) {
case FavoritesLoading():
return loading();case FavoritesEmpty():
return empty();case FavoritesLoaded():
return loaded(_that.movies);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function()?  empty,TResult? Function( List<Movie> movies)?  loaded,}) {final _that = this;
switch (_that) {
case FavoritesLoading() when loading != null:
return loading();case FavoritesEmpty() when empty != null:
return empty();case FavoritesLoaded() when loaded != null:
return loaded(_that.movies);case _:
  return null;

}
}

}

/// @nodoc


class FavoritesLoading implements FavoritesState {
  const FavoritesLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoritesLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FavoritesState.loading()';
}


}




/// @nodoc


class FavoritesEmpty implements FavoritesState {
  const FavoritesEmpty();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoritesEmpty);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'FavoritesState.empty()';
}


}




/// @nodoc


class FavoritesLoaded implements FavoritesState {
  const FavoritesLoaded( List<Movie> movies): _movies = movies;
  

 final  List<Movie> _movies;
 List<Movie> get movies {
  if (_movies is EqualUnmodifiableListView) return _movies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_movies);
}


/// Create a copy of FavoritesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoritesLoadedCopyWith<FavoritesLoaded> get copyWith => _$FavoritesLoadedCopyWithImpl<FavoritesLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoritesLoaded&&const DeepCollectionEquality().equals(other.movies, _movies));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_movies));
}

@override
String toString() {
    return 'FavoritesState.loaded(movies: $movies)';
}


}

/// @nodoc
abstract mixin class $FavoritesLoadedCopyWith<$Res> implements $FavoritesStateCopyWith<$Res> {
  factory $FavoritesLoadedCopyWith(FavoritesLoaded value, $Res Function(FavoritesLoaded) _then) = _$FavoritesLoadedCopyWithImpl;
@useResult
$Res call({
 List<Movie> movies
});




}
/// @nodoc
class _$FavoritesLoadedCopyWithImpl<$Res>
    implements $FavoritesLoadedCopyWith<$Res> {
  _$FavoritesLoadedCopyWithImpl(this._self, this._then);

  final FavoritesLoaded _self;
  final $Res Function(FavoritesLoaded) _then;

/// Create a copy of FavoritesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? movies = null,}) {
  return _then(FavoritesLoaded(
null == movies ? _self._movies : movies // ignore: cast_nullable_to_non_nullable
as List<Movie>,
  ));
}


}

// dart format on
