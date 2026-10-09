/// The user's preferred content language.
///
/// The app persists the choice and shows it as a label. It deliberately does
/// not translate the UI yet (see the roadmap). The list is the union of the
/// Android and iOS editions.
enum ContentLanguage {
  en('English'),
  es('Español'),
  de('Deutsch'),
  ar('العربية'),
  ur('اردو');

  const ContentLanguage(this.displayName);

  /// The language's name in its own script.
  final String displayName;

  /// Short code shown in the Home app bar, e.g. `EN`.
  String get code => name.toUpperCase();
}
