import "package:flutter/material.dart";

/// Inherited widget for passing data from the [NavigationBar] to the
/// [NavigationBar.destinations] children widgets.
///
/// Useful for building navigation destinations using:
/// `NavigationDestinationInfo.of(context)`.
class NavigationDestinationInfo extends InheritedWidget {
  /// Adds the information needed to build a navigation destination to the
  /// [child] and descendants.
  const NavigationDestinationInfo({
    required this.index,
    required this.selectedIndex,
    required this.totalNumberOfDestinations,
    required this.selectedAnimation,
    required this.labelBehavior,
    required this.indicatorColor,
    required this.indicatorShape,
    required this.overlayColor,
    required this.onTap,
    required super.child,
    this.labelTextStyle,
    this.labelPadding,
    super.key,
  });

  /// Which destination index is this in the navigation bar.
  ///
  /// For example:
  ///
  /// ```dart
  /// NavigationBar(
  ///   destinations: const <Widget>[
  ///     NavigationDestination(
  ///       // This is destination index 0.
  ///       icon: Icon(Icons.surfing),
  ///       label: 'Surfing',
  ///     ),
  ///     NavigationDestination(
  ///       // This is destination index 1.
  ///       icon: Icon(Icons.support),
  ///       label: 'Support',
  ///     ),
  ///     NavigationDestination(
  ///       // This is destination index 2.
  ///       icon: Icon(Icons.local_hospital),
  ///       label: 'Hospital',
  ///     ),
  ///   ]
  /// )
  /// ```
  ///
  /// This is required for semantics, so that each destination can have a label
  /// "Tab 1 of 3", for example.
  final int index;

  /// This is the index of the currently selected destination.
  ///
  /// This is required for [IndicatorInkWell] to apply label padding to ripple animations
  /// when label behavior is [NavigationDestinationLabelBehavior.onlyShowSelected].
  final int selectedIndex;

  /// How many total destinations are in this navigation bar.
  ///
  /// This is required for semantics, so that each destination can have a label
  /// "Tab 1 of 4", for example.
  final int totalNumberOfDestinations;

  /// Indicates whether or not this destination is selected, from 0 (unselected)
  /// to 1 (selected).
  final Animation<double> selectedAnimation;

  /// Determines the behavior for how the labels will layout.
  ///
  /// Can be used to show all labels (the default), show only the selected
  /// label, or hide all labels.
  final NavigationDestinationLabelBehavior labelBehavior;

  /// The color of the selection indicator.
  ///
  /// This is used by destinations to override the indicator color.
  final Color? indicatorColor;

  /// The shape of the selection indicator.
  ///
  /// This is used by destinations to override the indicator shape.
  final ShapeBorder? indicatorShape;

  /// The highlight color that's typically used to indicate that
  /// the [NavigationDestination] is focused, hovered, or pressed.
  ///
  /// This is used by destinations to override the overlay color.
  final WidgetStateProperty<Color?>? overlayColor;

  /// The text style of the label.
  final WidgetStateProperty<TextStyle?>? labelTextStyle;

  /// The padding around the destination label.
  final EdgeInsetsGeometry? labelPadding;

  /// The callback that should be called when this destination is tapped.
  ///
  /// This is computed by calling [NavigationBar.onDestinationSelected]
  /// with [index] passed in.
  final VoidCallback onTap;

  /// Returns a non null [NavigationDestinationInfo].
  ///
  /// This will return an error if called with no [NavigationDestinationInfo]
  /// ancestor.
  ///
  /// Used by widgets that are implementing a navigation destination info to
  /// get information like the selected animation and destination number.
  static NavigationDestinationInfo of(BuildContext context) {
    final NavigationDestinationInfo? result =
        context.dependOnInheritedWidgetOfExactType<NavigationDestinationInfo>();
    assert(
      result != null,
      "Navigation destinations need a NavigationDestinationInfo parent, "
      "which is usually provided by NavigationBar.",
    );
    return result!;
  }

  @override
  bool updateShouldNotify(NavigationDestinationInfo oldWidget) {
    return index != oldWidget.index ||
        selectedIndex != oldWidget.selectedIndex ||
        totalNumberOfDestinations != oldWidget.totalNumberOfDestinations ||
        selectedAnimation != oldWidget.selectedAnimation ||
        labelBehavior != oldWidget.labelBehavior ||
        indicatorColor != oldWidget.indicatorColor ||
        indicatorShape != oldWidget.indicatorShape ||
        overlayColor != oldWidget.overlayColor ||
        labelTextStyle != oldWidget.labelTextStyle ||
        labelPadding != oldWidget.labelPadding ||
        onTap != oldWidget.onTap;
  }
}
