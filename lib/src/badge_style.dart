/// Controls how a badge is displayed on a [NavigationDestination] icon.
///
/// [dot] and [hidden] apply to all three badge input types
/// ([NavigationDestination.badge], [NavigationDestination.badgeLabel], and
/// [NavigationDestination.customBadge]).
///
/// [exact] only applies when [NavigationDestination.badge] (`int`) is set;
/// combining it with [NavigationDestination.badgeLabel] or
/// [NavigationDestination.customBadge] will throw an assertion error.
///
/// [count] is also valid with [NavigationDestination.badgeLabel] and
/// [NavigationDestination.customBadge], where it behaves as a neutral/default
/// style and does not alter the provided badge content.
///
/// See also:
///
///  * [NavigationDestination.badge], which is the numeric count the badge
///    represents.
///  * [NavigationDestination.badgeStyle], which uses this enum.
enum NavigationBadgeStyle {
  /// Displays the numeric [NavigationDestination.badge] (`int`) value, capped at 99.
  ///
  /// Values of 1–99 are shown as their string equivalent (e.g. `"3"`).
  /// Values greater than 99 are shown as `"99+"`.
  ///
  /// With [NavigationDestination.badgeLabel] or
  /// [NavigationDestination.customBadge], this style is allowed and leaves the
  /// provided label/custom badge content unchanged.
  ///
  /// This is the default style.
  count,

  /// Displays the numeric [NavigationDestination.badge] (`int`) value without
  /// capping.
  ///
  /// The raw integer is shown regardless of its magnitude
  /// (e.g. `badge: 150` renders as `"150"`).
  ///
  /// **Applies to**: [NavigationDestination.badge] (`int`) only.
  /// Setting this style alongside [NavigationDestination.badgeLabel] or
  /// [NavigationDestination.customBadge] will throw an assertion error.
  exact,

  /// Displays a small dot indicator, overriding any badge content.
  ///
  /// Works with all three badge input types:
  /// - [NavigationDestination.badge] (`int`) — numeric value is ignored.
  /// - [NavigationDestination.badgeLabel] (`String`) — label text is ignored.
  /// - [NavigationDestination.customBadge] (`Badge`) — custom widget is
  ///   ignored; a themed dot is shown instead.
  dot,

  /// Suppresses the badge visual entirely, regardless of which badge input is
  /// set.
  ///
  /// Works with all three badge input types:
  /// - [NavigationDestination.badge] (`int`)
  /// - [NavigationDestination.badgeLabel] (`String`)
  /// - [NavigationDestination.customBadge] (`Badge`)
  ///
  /// Useful for temporarily hiding a badge while retaining its value in the
  /// widget tree — for example, while an in-app notification banner is already
  /// visible.
  hidden,
}
