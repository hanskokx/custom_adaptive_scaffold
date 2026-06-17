// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import "../../navigation_bar_theme.dart";
import "../material.dart";
import "../navigation_destination.dart";
import "navigation_bar_destination.dart";
import "navigation_bar_theme_defaults.dart";
import "navigation_destination_info.dart";
import "selectable_animated_builder.dart";

typedef CustomNavigationBarDestination = NavigationDestination;
typedef CustomNavigationBar = NavigationBar;

// Examples can assume:
// late BuildContext context;
// late bool _isDrawerOpen;

/// Material 3 Navigation Bar component.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=DVGYddFaLv0}
///
/// Navigation bars offer a persistent and convenient way to switch between
/// primary destinations in an app.
///
/// This widget does not adjust its size with the [ThemeData.visualDensity].
///
/// The [MediaQueryData.textScaler] does not adjust the size of this widget but
/// rather the size of the [Tooltip]s displayed on long presses of the
/// destinations.
///
/// The style for the icons and text are not affected by parent
/// [DefaultTextStyle]s or [IconTheme]s but rather controlled by parameters or
/// the [NavigationBarThemeData].
///
/// This widget holds a collection of destinations (usually
/// [NavigationDestination]s).
///
/// {@tool dartpad}
/// This example shows a [CustomNavigationBar] as it is used within a [Scaffold]
/// widget. The [CustomNavigationBar] has three [NavigationDestination] widgets and
/// the initial [selectedIndex] is set to index 0. The [onDestinationSelected]
/// callback changes the selected item's index and displays a corresponding
/// widget in the body of the [Scaffold].
///
/// ** See code in examples/api/lib/material/navigation_bar/navigation_bar.0.dart **
/// {@end-tool}
///
/// {@tool dartpad}
/// This example showcases [CustomNavigationBar] label behaviors. When tapping on one
/// of the label behavior options, the [labelBehavior] of the [CustomNavigationBar]
/// will be updated.
///
/// ** See code in examples/api/lib/material/navigation_bar/navigation_bar.1.dart **
/// {@end-tool}
///
/// {@tool dartpad}
/// This example shows a [CustomNavigationBar] within a main [Scaffold]
/// widget that's used to control the visibility of destination pages.
/// Each destination has its own scaffold and a nested navigator that
/// provides local navigation. The example's [NavigationDestination] has four
/// [NavigationDestination] widgets with different color schemes. Its
/// [onDestinationSelected] callback changes the selected
/// destination's index and displays a corresponding page with its own
/// local navigator and scaffold - all within the body of the main
/// scaffold. The destination pages are organized in a [Stack] and
/// switching destinations fades out the current page and
/// fades in the new one. Destinations that aren't visible or animating
/// are kept [Offstage].
///
/// ** See code in examples/api/lib/material/navigation_bar/navigation_bar.2.dart **
/// {@end-tool}
/// See also:
///
///  * [NavigationDestination]
///  * [BottomNavigationBar]
///  * <https://api.flutter.dev/flutter/material/NavigationDestination-class.html>
///  * <https://m3.material.io/components/navigation-bar>
class NavigationBar extends StatelessWidget {
  /// Creates a Material 3 Navigation Bar component.
  ///
  /// The value of [destinations] must be a list of two or more
  /// [NavigationDestination] values.
  const NavigationBar({
    required this.destinations,
    super.key,
    this.animationDuration,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.backgroundColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.indicatorColor,
    this.indicatorShape,
    this.height,
    this.labelBehavior,
    this.overlayColor,
    this.labelPadding,
    this.maintainBottomViewPadding = false,
  })  : assert(destinations.length >= 2),
        assert(0 <= selectedIndex && selectedIndex < destinations.length);

  /// Determines the transition time for each destination as it goes between
  /// selected and unselected.
  final Duration? animationDuration;

  /// Determines which one of the [destinations] is currently selected.
  ///
  /// When this is updated, the destination (from [destinations]) at
  /// [selectedIndex] goes from unselected to selected.
  final int selectedIndex;

  /// The list of destinations (usually [NavigationDestination]s) in this
  /// [CustomNavigationBar].
  ///
  /// When [selectedIndex] is updated, the destination from this list at
  /// [selectedIndex] will animate from 0 (unselected) to 1.0 (selected). When
  /// the animation is increasing or completed, the destination is considered
  /// selected, when the animation is decreasing or dismissed, the destination
  /// is considered unselected.
  final List<NavigationDestination> destinations;

  /// Called when one of the [destinations] is selected.
  ///
  /// This callback usually updates the int passed to [selectedIndex].
  ///
  /// Upon updating [selectedIndex], the [CustomNavigationBar] will be rebuilt.
  final ValueChanged<int>? onDestinationSelected;

  /// The color of the [CustomNavigationBar] itself.
  ///
  /// If null, [NavigationBarThemeData.backgroundColor] is used. If that
  /// is also null, then if [ThemeData.useMaterial3] is true, the value is
  /// [ColorScheme.surfaceContainer]. If that is false, the default blends [ColorScheme.surface]
  /// and [ColorScheme.onSurface] using an [ElevationOverlay].
  final Color? backgroundColor;

  /// The elevation of the [CustomNavigationBar] itself.
  ///
  /// If null, [NavigationBarThemeData.elevation] is used. If that
  /// is also null, then if [ThemeData.useMaterial3] is true then it will
  /// be 3.0 otherwise 0.0.
  final double? elevation;

  /// The color used for the drop shadow to indicate elevation.
  ///
  /// If null, [NavigationBarThemeData.shadowColor] is used. If that
  /// is also null, the default value is [Colors.transparent] which
  /// indicates that no drop shadow will be displayed.
  ///
  /// See [Material.shadowColor] for more details on drop shadows.
  final Color? shadowColor;

  /// The color used as an overlay on [backgroundColor] to indicate elevation.
  ///
  /// This is not recommended for use. [Material 3 spec](https://m3.material.io/styles/color/the-color-system/color-roles)
  /// introduced a set of tone-based surfaces and surface containers in its [ColorScheme],
  /// which provide more flexibility. The intention is to eventually remove surface tint color from
  /// the framework.
  ///
  /// If null, [NavigationBarThemeData.surfaceTintColor] is used. If that
  /// is also null, the default value is [Colors.transparent].
  ///
  /// See [Material.surfaceTintColor] for more details on how this
  /// overlay is applied.
  final Color? surfaceTintColor;

  /// The color of the [indicatorShape] when this destination is selected.
  ///
  /// If null, [NavigationBarThemeData.indicatorColor] is used. If that
  /// is also null and [ThemeData.useMaterial3] is true, [ColorScheme.secondaryContainer]
  /// is used. Otherwise, [ColorScheme.secondary] with an opacity of 0.24 is used.
  final Color? indicatorColor;

  /// The shape of the selected indicator.
  ///
  /// If null, [NavigationBarThemeData.indicatorShape] is used. If that
  /// is also null and [ThemeData.useMaterial3] is true, [StadiumBorder] is used.
  /// Otherwise, [RoundedRectangleBorder] with a circular border radius of 16 is used.
  final ShapeBorder? indicatorShape;

  /// The height of the [CustomNavigationBar] itself.
  ///
  /// If this is used in [Scaffold.bottomNavigationBar] and the scaffold is
  /// full-screen, the safe area padding is also added to the height
  /// automatically.
  ///
  /// The height does not adjust with [ThemeData.visualDensity] or
  /// [MediaQueryData.textScaler] as this component loses usability at
  /// larger and smaller sizes due to the truncating of labels or smaller tap
  /// targets.
  ///
  /// If null, [NavigationBarThemeData.height] is used. If that
  /// is also null, the default is 80.
  final double? height;

  /// Defines how the [destinations]' labels will be laid out and when they'll
  /// be displayed.
  ///
  /// Can be used to show all labels, show only the selected label, or hide all
  /// labels.
  ///
  /// If null, [NavigationBarThemeData.labelBehavior] is used. If that
  /// is also null, the default is
  /// [NavigationDestinationLabelBehavior.alwaysShow].
  final NavigationDestinationLabelBehavior? labelBehavior;

  /// The highlight color that's typically used to indicate that
  /// the [NavigationDestination] is focused, hovered, or pressed.
  final WidgetStateProperty<Color?>? overlayColor;

  /// The padding around the [NavigationDestination.label] widget.
  ///
  /// When [labelPadding] is null, [NavigationBarThemeData.labelPadding]
  /// is used. If that is also null, the default padding is 4 pixels on
  /// the top.
  final EdgeInsetsGeometry? labelPadding;

  /// Whether the underlying [SafeArea] should maintain bottom view padding.
  ///
  /// When true, this prevents the bar from shifting when opening an IME.
  /// Defaults to false.
  final bool maintainBottomViewPadding;

  VoidCallback _handleTap(int index) {
    return onDestinationSelected != null
        ? () => onDestinationSelected!(index)
        : () {};
  }

  @override
  Widget build(BuildContext context) {
    final NavigationBarThemeData defaults = navigationBarDefaultsFor(context);

    final NavigationBarThemeData navigationBarTheme =
        NavigationBarTheme.of(context);
    final double effectiveHeight =
        height ?? navigationBarTheme.height ?? defaults.height!;
    final NavigationDestinationLabelBehavior effectiveLabelBehavior =
        labelBehavior ??
            navigationBarTheme.labelBehavior ??
            defaults.labelBehavior!;
    final ShapeBorder effectiveIndicatorShape = indicatorShape ??
        navigationBarTheme.indicatorShape ??
        defaults.indicatorShape!;

    return Material(
      color: backgroundColor ??
          navigationBarTheme.backgroundColor ??
          defaults.backgroundColor!,
      elevation:
          elevation ?? navigationBarTheme.elevation ?? defaults.elevation!,
      shadowColor:
          shadowColor ?? navigationBarTheme.shadowColor ?? defaults.shadowColor,
      surfaceTintColor: surfaceTintColor ??
          navigationBarTheme.surfaceTintColor ??
          defaults.surfaceTintColor,
      child: SafeArea(
        maintainBottomViewPadding: maintainBottomViewPadding,
        child: SizedBox(
          height: effectiveHeight,
          child: Row(
            children: List<Widget>.generate(destinations.length, (int i) {
              final NavigationBarDestination destination =
                  destinations[i].toBarDestination();

              return Expanded(
                child: SelectableAnimatedBuilder(
                  duration:
                      animationDuration ?? const Duration(milliseconds: 500),
                  isSelected: i == selectedIndex,
                  builder: (BuildContext context, Animation<double> animation) {
                    return NavigationDestinationInfo(
                      index: i,
                      selectedIndex: selectedIndex,
                      totalNumberOfDestinations: destinations.length,
                      selectedAnimation: animation,
                      labelBehavior: effectiveLabelBehavior,
                      indicatorColor: indicatorColor,
                      indicatorShape: effectiveIndicatorShape,
                      overlayColor: overlayColor,
                      labelPadding: labelPadding,
                      onTap: _handleTap.call(i),
                      child: destination,
                    );
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
