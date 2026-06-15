part of "../navigation_bar_destination.dart";

/// Custom layout delegate for shifting navigation bar destinations.
///
/// This will lay out the icon + label according to the [animation].
///
/// When the [animation] is 0, the icon will be centered, and the label will be
/// positioned directly below it.
///
/// When the [animation] is 1, the label will still be positioned directly below
/// the icon, but the icon + label combination will be centered.
///
/// Used in a [CustomMultiChildLayout] widget in the
/// [_NavigationDestinationBuilder].
class _NavigationDestinationLayoutDelegate extends MultiChildLayoutDelegate {
  _NavigationDestinationLayoutDelegate({required this.animation})
      : super(relayout: animation);

  /// The selection animation that indicates whether or not this destination is
  /// selected.
  ///
  /// See [NavigationDestinationInfo.selectedAnimation].
  final Animation<double> animation;

  /// ID for the icon widget child.
  ///
  /// This is used by the [LayoutId] when this delegate is used in a
  /// [CustomMultiChildLayout].
  ///
  /// See [_NavigationDestinationBuilder].
  static const int iconId = 1;

  /// ID for the label widget child.
  ///
  /// This is used by the [LayoutId] when this delegate is used in a
  /// [CustomMultiChildLayout].
  ///
  /// See [_NavigationDestinationBuilder].
  static const int labelId = 2;

  @override
  void performLayout(Size size) {
    double halfWidth(Size size) => size.width / 2;
    double halfHeight(Size size) => size.height / 2;

    final Size iconSize = layoutChild(iconId, BoxConstraints.loose(size));
    final Size labelSize = layoutChild(labelId, BoxConstraints.loose(size));

    final double yPositionOffset = Tween<double>(
      // When unselected, the icon is centered vertically.
      begin: halfHeight(iconSize),
      // When selected, the icon and label are centered vertically.
      end: halfHeight(iconSize) + halfHeight(labelSize),
    ).transform(animation.value);
    final double iconYPosition = halfHeight(size) - yPositionOffset;

    // Position the icon.
    positionChild(
      iconId,
      Offset(
        // Center the icon horizontally.
        halfWidth(size) - halfWidth(iconSize),
        iconYPosition,
      ),
    );

    // Position the label.
    positionChild(
      labelId,
      Offset(
        // Center the label horizontally.
        halfWidth(size) - halfWidth(labelSize),
        // Label always appears directly below the icon.
        iconYPosition + iconSize.height,
      ),
    );
  }

  @override
  bool shouldRelayout(_NavigationDestinationLayoutDelegate oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
