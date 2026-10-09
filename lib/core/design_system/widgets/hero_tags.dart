/// Tags shared by the two ends of a `Hero` animation. A list's poster and the
/// Details poster use the same tag, and Flutter flies the image between them.
abstract final class HeroTags {
  static String poster(int movieId) => 'poster-$movieId';
}
