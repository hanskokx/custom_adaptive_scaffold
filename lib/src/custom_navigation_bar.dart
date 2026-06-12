// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import "dart:async";
import "dart:ui" show SemanticsRole;

import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter/material.dart";

import "compact_destination_layout.dart";
import "interaction_shape_resolver.dart";
import "navigation_destination_types.dart";

const double _kIndicatorHeight = 32;
const double _kIndicatorWidth = 64;
const double _kMaxLabelTextScaleFactor = 1.3;
const double _horizontalDestinationPadding = 8.0;

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
/// This widget holds a collection of destinations (typically
/// [NavigationDestination]s; use [CustomNavigationDestination] for advanced
/// destination customization).
///
/// {@tool dartpad}
/// This example shows a [CustomNavigationBar] as it is used within a [Scaffold]
/// widget. The [CustomNavigationBar] has three [CustomNavigationDestination] widgets and
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
/// provides local navigation. The example's [CustomNavigationBar] has four
/// [CustomNavigationDestination] widgets with different color schemes. Its
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
///  * [CustomNavigationDestination]
///  * [BottomNavigationBar]
///  * <https://api.flutter.dev/flutter/material/NavigationDestination-class.html>
///  * <https://m3.material.io/components/navigation-bar>
class CustomNavigationBar extends StatelessWidget {
  /// Creates a Material 3 Navigation Bar component.
  ///
  /// The value of [destinations] must be a list of two or more destination
  /// widgets, usually [NavigationDestination] values.
  const CustomNavigationBar({
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
    this.labelTextStyle,
    this.labelPadding,
    this.margin,
    this.padding = EdgeInsets.zero,
    this.border,
    this.tooltipVerticalOffset,
    this.destinationFillRegion,
    this.destinationHoverRegion,
    this.shape,
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

  /// The list of destinations in this [CustomNavigationBar].
  ///
  /// Most apps should use [NavigationDestination]. Use
  /// [CustomNavigationDestination] only when advanced per-destination
  /// customization is needed.
  ///
  /// When [selectedIndex] is updated, the destination from this list at
  /// [selectedIndex] will animate from 0 (unselected) to 1.0 (selected). When
  /// the animation is increasing or completed, the destination is considered
  /// selected, when the animation is decreasing or dismissed, the destination
  /// is considered unselected.
  final List<Widget> destinations;

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
  /// the [CustomNavigationDestination] is focused, hovered, or pressed.
  final WidgetStateProperty<Color?>? overlayColor;

  /// The text style of the label.
  ///
  /// If null, [NavigationBarThemeData.labelTextStyle] is used.
  final WidgetStateProperty<TextStyle?>? labelTextStyle;

  /// The padding around the [NavigationDestination.label] widget.
  ///
  /// When [labelPadding] is null, [NavigationBarThemeData.labelPadding]
  /// is used.
  final EdgeInsetsGeometry? labelPadding;

  /// Applies a margin around navigation items.
  final EdgeInsetsGeometry? margin;

  /// Applies padding around navigation item content.
  final EdgeInsetsGeometry padding;

  /// Optional border around the outer navigation bar surface.
  final BorderSide? border;

  /// Defines the vertical offset of tooltip popovers.
  final double? tooltipVerticalOffset;

  /// Controls where destination selected fill/highlight is painted.
  ///
  /// When null, this widget follows Flutter's default indicator path.
  /// Passing [NavigationDestinationRegion.icon] behaves the same as null.
  ///
  /// Pass [NavigationDestinationRegion.none] to explicitly disable custom
  /// fill/highlight behavior.
  final NavigationDestinationRegion? destinationFillRegion;

  /// Controls where destination hover and pressed interaction effects are
  /// painted.
  ///
  /// When null, this follows [destinationFillRegion].
  final NavigationDestinationRegion? destinationHoverRegion;

  /// Optional stateful shape for destination fill and interaction highlights.
  ///
  /// Selected fill resolves with [WidgetState.selected]. Interaction shape
  /// resolves with [WidgetState.hovered], then [WidgetState.pressed], then
  /// [WidgetState.focused], and then falls back to the selected shape.
  ///
  /// If unresolved for a given state, the resolved navigation bar indicator
  /// shape is used, and then [StadiumBorder] as a final fallback.
  final WidgetStateProperty<ShapeBorder?>? shape;

  /// Specifies whether [SafeArea] should maintain bottom view padding.
  final bool maintainBottomViewPadding;

  VoidCallback _handleTap(int index) {
    return onDestinationSelected != null
        ? () => onDestinationSelected!(index)
        : () {};
  }

  @override
  Widget build(BuildContext context) {
    final NavigationBarThemeData defaults = _defaultsFor(context);

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
      shape: border == null
          ? null
          : Border.fromBorderSide(
              border!,
            ),
      child: SafeArea(
        maintainBottomViewPadding: maintainBottomViewPadding,
        child: Semantics(
          role: SemanticsRole.tabBar,
          explicitChildNodes: true,
          container: true,
          child: SizedBox(
            height: effectiveHeight,
            child: Row(
              children: <Widget>[
                for (int i = 0; i < destinations.length; i++)
                  Expanded(
                    child: MergeSemantics(
                      child: Semantics(
                        role: SemanticsRole.tab,
                        selected: i == selectedIndex,
                        child: _SelectableAnimatedBuilder(
                          duration: animationDuration ??
                              const Duration(milliseconds: 500),
                          isSelected: i == selectedIndex,
                          builder: (
                            BuildContext context,
                            Animation<double> animation,
                          ) {
                            return _NavigationDestinationInfo(
                              index: i,
                              selectedIndex: selectedIndex,
                              totalNumberOfDestinations: destinations.length,
                              selectedAnimation: animation,
                              labelBehavior: effectiveLabelBehavior,
                              indicatorColor: indicatorColor,
                              indicatorShape: effectiveIndicatorShape,
                              overlayColor: overlayColor,
                              labelTextStyle: labelTextStyle,
                              labelPadding: labelPadding,
                              margin: margin,
                              padding: padding,
                              tooltipVerticalOffset: tooltipVerticalOffset,
                              destinationFillRegion: destinationFillRegion,
                              destinationHoverRegion: destinationHoverRegion,
                              shape: shape,
                              onTap: _handleTap(i),
                              child: destinations[i],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// An advanced Material 3 destination for [CustomNavigationBar].
///
/// Displays a label below an icon. Use [NavigationDestination] by default,
/// and use this class with [CustomNavigationBar.destinations] when you need
/// advanced per-destination customization.
///
/// See also:
///
///  * [CustomNavigationBar], for an interactive code sample.
class CustomNavigationDestination extends NavigationDestination {
  /// Creates an advanced navigation bar destination with an icon and a label,
  /// to be used in [CustomNavigationBar.destinations].
  const CustomNavigationDestination({
    required super.icon,
    required super.label,
    super.key,
    super.selectedIcon,
    super.tooltip,
    super.enabled = true,
    this.hideLabel = false,
    this.transitionAnimation = NavigationDestinationAnimation.none,
    this.transitionCurve = Curves.easeInOut,
    this.transitionDuration,
    this.iconBuilder,
    this.transitionBuilder,
    this.iconIndicatorShape,
    this.labelIndicatorShape,
  });

  /// When true the label is not rendered, leaving only the icon visible.
  ///
  /// Coexists with [NavigationDestinationLabelBehavior]: setting
  /// [hideLabel] to true on an individual destination suppresses its label
  /// regardless of the bar-level label behavior.
  final bool hideLabel;

  /// Controls how the icon animates when this destination transitions between
  /// selected and unselected states.
  ///
  /// Ignored when [iconBuilder] is non-null.
  ///
  /// Defaults to [NavigationDestinationAnimation.none].
  final NavigationDestinationAnimation transitionAnimation;

  /// The curve applied to the icon transition animation.
  ///
  /// Defaults to [Curves.easeInOut].
  final Curve transitionCurve;

  /// Duration of the icon transition animation.
  ///
  /// When null, the [CustomNavigationBar.animationDuration] is used.
  final Duration? transitionDuration;

  /// A fully custom icon builder that receives the selection [Animation] and
  /// both the unselected and selected icon widgets (already themed).
  ///
  /// When set, [transitionAnimation] is ignored.
  final NavigationDestinationIconBuilder? iconBuilder;

  /// A custom transition builder with access to both icon and label state
  /// widgets.
  ///
  /// When set, this takes precedence over [iconBuilder] and
  /// [transitionAnimation].
  final NavigationDestinationTransitionBuilder? transitionBuilder;

  /// When non-null, the selection indicator is drawn around the icon only,
  /// sized to the icon widget, instead of spanning the full destination.
  ///
  /// Setting either [iconIndicatorShape] or [labelIndicatorShape] suppresses
  /// the default full-item indicator.
  final ShapeBorder? iconIndicatorShape;

  /// When non-null, the selection indicator is drawn around the label only,
  /// sized to the label widget, instead of spanning the full destination.
  ///
  /// Setting either [iconIndicatorShape] or [labelIndicatorShape] suppresses
  /// the default full-item indicator.
  final ShapeBorder? labelIndicatorShape;

  @override
  Widget build(BuildContext context) {
    final _NavigationDestinationInfo info =
        _NavigationDestinationInfo.of(context);
    const Set<WidgetState> selectedState = <WidgetState>{
      WidgetState.selected,
    };
    const Set<WidgetState> unselectedState = <WidgetState>{};
    const Set<WidgetState> disabledState = <WidgetState>{
      WidgetState.disabled,
    };

    final NavigationBarThemeData navigationBarTheme =
        NavigationBarTheme.of(context);
    final NavigationBarThemeData defaults = _defaultsFor(context);
    final Animation<double> animation = info.selectedAnimation;
    final WidgetStateProperty<TextStyle?>? labelTextStyleOverride =
        info.labelTextStyle;
    final EdgeInsetsGeometry effectiveLabelPadding = info.labelPadding ??
        navigationBarTheme.labelPadding ??
        defaults.labelPadding!;

    final Color indicatorColor = info.indicatorColor ??
        navigationBarTheme.indicatorColor ??
        defaults.indicatorColor!;
    final ShapeBorder indicatorShape = info.indicatorShape ??
        navigationBarTheme.indicatorShape ??
        defaults.indicatorShape!;

    return Container(
      margin: info.margin ?? EdgeInsets.zero,
      child: _NavigationDestinationBuilder(
        label: label,
        tooltip: tooltip,
        enabled: enabled,
        animation: animation,
        color: indicatorColor,
        shape: indicatorShape,
        padding: info.padding,
        iconIndicatorShape: iconIndicatorShape,
        labelIndicatorShape: labelIndicatorShape,
        buildIcon: (BuildContext context) {
          final IconThemeData selectedIconTheme =
              navigationBarTheme.iconTheme?.resolve(selectedState) ??
                  defaults.iconTheme!.resolve(selectedState)!;
          final IconThemeData unselectedIconTheme =
              navigationBarTheme.iconTheme?.resolve(unselectedState) ??
                  defaults.iconTheme!.resolve(unselectedState)!;
          final IconThemeData disabledIconTheme =
              navigationBarTheme.iconTheme?.resolve(disabledState) ??
                  defaults.iconTheme!.resolve(disabledState)!;

          final Widget selectedIconWidget = IconTheme.merge(
            data: enabled ? selectedIconTheme : disabledIconTheme,
            child: selectedIcon ?? icon,
          );
          final Widget unselectedIconWidget = IconTheme.merge(
            data: enabled ? unselectedIconTheme : disabledIconTheme,
            child: icon,
          );

          if (transitionBuilder != null) {
            return transitionBuilder!(
              context,
              animation,
              animation.isForwardOrCompleted,
              unselectedIconWidget,
              selectedIconWidget,
              const SizedBox.shrink(),
              const SizedBox.shrink(),
            );
          }

          if (iconBuilder != null) {
            return iconBuilder!(
              context,
              animation,
              animation.isForwardOrCompleted,
              unselectedIconWidget,
              selectedIconWidget,
            );
          }

          final Duration effectiveDuration =
              transitionDuration ?? const Duration(milliseconds: 200);

          switch (transitionAnimation) {
            case NavigationDestinationAnimation.none:
              return animation.isForwardOrCompleted
                  ? selectedIconWidget
                  : unselectedIconWidget;
            case NavigationDestinationAnimation.fadeSwap:
              return AnimatedSwitcher(
                duration: effectiveDuration,
                switchInCurve: transitionCurve,
                switchOutCurve: transitionCurve,
                transitionBuilder: (Widget child, Animation<double> anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: animation.isForwardOrCompleted
                    ? KeyedSubtree(
                        key: const ValueKey<String>("selected"),
                        child: selectedIconWidget,
                      )
                    : KeyedSubtree(
                        key: const ValueKey<String>("unselected"),
                        child: unselectedIconWidget,
                      ),
              );
            case NavigationDestinationAnimation.scale:
              return AnimatedSwitcher(
                duration: effectiveDuration,
                switchInCurve: transitionCurve,
                switchOutCurve: transitionCurve,
                transitionBuilder: (Widget child, Animation<double> anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: animation.isForwardOrCompleted
                    ? KeyedSubtree(
                        key: const ValueKey<String>("selected"),
                        child: selectedIconWidget,
                      )
                    : KeyedSubtree(
                        key: const ValueKey<String>("unselected"),
                        child: unselectedIconWidget,
                      ),
              );
          }
        },
        buildLabel: (BuildContext context) {
          if (hideLabel) return const SizedBox.shrink();
          final TextStyle? effectiveSelectedLabelTextStyle =
              labelTextStyleOverride?.resolve(selectedState) ??
                  navigationBarTheme.labelTextStyle?.resolve(selectedState) ??
                  defaults.labelTextStyle!.resolve(selectedState);
          final TextStyle? effectiveUnselectedLabelTextStyle =
              labelTextStyleOverride?.resolve(unselectedState) ??
                  navigationBarTheme.labelTextStyle?.resolve(unselectedState) ??
                  defaults.labelTextStyle!.resolve(unselectedState);
          final TextStyle? effectiveDisabledLabelTextStyle =
              labelTextStyleOverride?.resolve(disabledState) ??
                  navigationBarTheme.labelTextStyle?.resolve(disabledState) ??
                  defaults.labelTextStyle!.resolve(disabledState);

          final TextStyle? textStyle = (enabled
              ? animation.isForwardOrCompleted
                  ? effectiveSelectedLabelTextStyle
                  : effectiveUnselectedLabelTextStyle
              : effectiveDisabledLabelTextStyle);

          return Padding(
            padding: effectiveLabelPadding,
            child: MediaQuery.withClampedTextScaling(
              // Set maximum text scale factor to _kMaxLabelTextScaleFactor for the
              // label to keep the visual hierarchy the same even with larger font
              // sizes. To opt out, wrap the [label] widget in a [MediaQuery] widget
              // with a different `TextScaler`.
              maxScaleFactor: _kMaxLabelTextScaleFactor,
              child: Text(label, style: textStyle),
            ),
          );
        },
        buildContent: transitionBuilder == null
            ? null
            : (BuildContext context) {
                const Set<WidgetState> selectedState = <WidgetState>{
                  WidgetState.selected,
                };
                const Set<WidgetState> unselectedState = <WidgetState>{};
                const Set<WidgetState> disabledState = <WidgetState>{
                  WidgetState.disabled,
                };

                final IconThemeData selectedIconTheme =
                    navigationBarTheme.iconTheme?.resolve(selectedState) ??
                        defaults.iconTheme!.resolve(selectedState)!;
                final IconThemeData unselectedIconTheme =
                    navigationBarTheme.iconTheme?.resolve(unselectedState) ??
                        defaults.iconTheme!.resolve(unselectedState)!;
                final IconThemeData disabledIconTheme =
                    navigationBarTheme.iconTheme?.resolve(disabledState) ??
                        defaults.iconTheme!.resolve(disabledState)!;

                final Widget selectedIconWidget = IconTheme.merge(
                  data: enabled ? selectedIconTheme : disabledIconTheme,
                  child: selectedIcon ?? icon,
                );
                final Widget unselectedIconWidget = IconTheme.merge(
                  data: enabled ? unselectedIconTheme : disabledIconTheme,
                  child: icon,
                );

                if (hideLabel) {
                  return transitionBuilder!(
                    context,
                    animation,
                    animation.isForwardOrCompleted,
                    unselectedIconWidget,
                    selectedIconWidget,
                    const SizedBox.shrink(),
                    const SizedBox.shrink(),
                  );
                }

                final TextStyle? effectiveSelectedLabelTextStyle =
                    labelTextStyleOverride?.resolve(selectedState) ??
                        navigationBarTheme.labelTextStyle
                            ?.resolve(selectedState) ??
                        defaults.labelTextStyle!.resolve(selectedState);
                final TextStyle? effectiveUnselectedLabelTextStyle =
                    labelTextStyleOverride?.resolve(unselectedState) ??
                        navigationBarTheme.labelTextStyle
                            ?.resolve(unselectedState) ??
                        defaults.labelTextStyle!.resolve(unselectedState);
                final TextStyle? effectiveDisabledLabelTextStyle =
                    labelTextStyleOverride?.resolve(disabledState) ??
                        navigationBarTheme.labelTextStyle
                            ?.resolve(disabledState) ??
                        defaults.labelTextStyle!.resolve(disabledState);

                final TextStyle? selectedTextStyle = enabled
                    ? effectiveSelectedLabelTextStyle
                    : effectiveDisabledLabelTextStyle;
                final TextStyle? unselectedTextStyle = enabled
                    ? effectiveUnselectedLabelTextStyle
                    : effectiveDisabledLabelTextStyle;

                final Widget selectedLabelWidget = Padding(
                  padding: effectiveLabelPadding,
                  child: MediaQuery.withClampedTextScaling(
                    maxScaleFactor: _kMaxLabelTextScaleFactor,
                    child: Text(label, style: selectedTextStyle),
                  ),
                );
                final Widget unselectedLabelWidget = Padding(
                  padding: effectiveLabelPadding,
                  child: MediaQuery.withClampedTextScaling(
                    maxScaleFactor: _kMaxLabelTextScaleFactor,
                    child: Text(label, style: unselectedTextStyle),
                  ),
                );

                return transitionBuilder!(
                  context,
                  animation,
                  animation.isForwardOrCompleted,
                  unselectedIconWidget,
                  selectedIconWidget,
                  unselectedLabelWidget,
                  selectedLabelWidget,
                );
              },
      ),
    );
  }
}

/// Widget that handles the semantics and layout of a navigation bar
/// destination.
///
/// Prefer [CustomNavigationDestination] over this widget, as it is a simpler
/// (although less customizable) way to get navigation bar destinations.
///
/// The icon and label of this destination are built with [buildIcon] and
/// [buildLabel]. They should build the unselected and selected icon and label
/// according to [_NavigationDestinationInfo.selectedAnimation], where an
/// animation value of 0 is unselected and 1 is selected.
///
/// See [CustomNavigationDestination] for an example.
class _NavigationDestinationBuilder extends StatefulWidget {
  /// Builds a destination (icon + label) to use in a Material 3 [NavigationBar].
  const _NavigationDestinationBuilder({
    required this.buildIcon,
    required this.buildLabel,
    required this.label,
    required this.animation,
    this.color,
    this.shape,
    this.tooltip,
    this.enabled = true,
    this.padding = EdgeInsets.zero,
    this.iconIndicatorShape,
    this.labelIndicatorShape,
    this.buildContent,
  });

  /// Builds the icon for a destination in a [NavigationBar].
  ///
  /// To animate between unselected and selected, build the icon based on
  /// [_NavigationDestinationInfo.selectedAnimation]. When the animation is 0,
  /// the destination is unselected, when the animation is 1, the destination is
  /// selected.
  ///
  /// The destination is considered selected as soon as the animation is
  /// increasing or completed, and it is considered unselected as soon as the
  /// animation is decreasing or dismissed.
  final WidgetBuilder buildIcon;

  /// Builds the label for a destination in a [NavigationBar].
  ///
  /// To animate between unselected and selected, build the icon based on
  /// [_NavigationDestinationInfo.selectedAnimation]. When the animation is
  /// 0, the destination is unselected, when the animation is 1, the destination
  /// is selected.
  ///
  /// The destination is considered selected as soon as the animation is
  /// increasing or completed, and it is considered unselected as soon as the
  /// animation is decreasing or dismissed.
  final WidgetBuilder buildLabel;

  /// The text value of what is in the label widget, this is required for
  /// semantics so that screen readers and tooltips can read the proper label.
  final String label;

  /// The text to display in the tooltip for this [CustomNavigationDestination], when
  /// the user long presses the destination.
  ///
  /// If [tooltip] is an empty string, no tooltip will be used.
  ///
  /// Defaults to null, in which case the [label] text will be used.
  final String? tooltip;

  /// Indicates that this destination is selectable.
  ///
  /// Defaults to true.
  final bool enabled;

  final Animation<double> animation;
  final Color? color;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry padding;

  /// When non-null, a scoped selection indicator is drawn around the icon
  /// widget only. Suppresses the default full-item indicator.
  final ShapeBorder? iconIndicatorShape;

  /// When non-null, a scoped selection indicator is drawn around the label
  /// widget only. Suppresses the default full-item indicator.
  final ShapeBorder? labelIndicatorShape;

  /// Optional builder that replaces the default icon+label content pipeline.
  final WidgetBuilder? buildContent;

  @override
  State<_NavigationDestinationBuilder> createState() =>
      _NavigationDestinationBuilderState();
}

class _NavigationDestinationBuilderState
    extends State<_NavigationDestinationBuilder> {
  final GlobalKey _destinationRegionKey = GlobalKey();
  final GlobalKey _iconRegionKey = GlobalKey();
  final GlobalKey _labelRegionKey = GlobalKey();
  bool _isHovered = false;
  bool _isPressed = false;
  bool _isFocused = false;

  void _setHovered(bool value) {
    if (_isHovered == value || !mounted) return;
    setState(() {
      _isHovered = value;
    });
  }

  void _setPressed(bool value) {
    if (_isPressed == value || !mounted) return;
    setState(() {
      _isPressed = value;
    });
  }

  void _setFocused(bool value) {
    if (_isFocused == value || !mounted) return;
    setState(() {
      _isFocused = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _NavigationDestinationInfo info =
        _NavigationDestinationInfo.of(context);
    final NavigationBarThemeData navigationBarTheme =
        NavigationBarTheme.of(context);
    final ThemeData theme = Theme.of(context);
    final bool isSelected = widget.animation.isForwardOrCompleted;
    final NavigationDestinationRegion? destinationFillRegion =
        info.destinationFillRegion;
    final NavigationDestinationRegion? destinationHoverRegion =
        info.destinationHoverRegion ?? destinationFillRegion;
    final bool isDefaultFillPath = destinationFillRegion == null ||
        destinationFillRegion == NavigationDestinationRegion.icon;
    final bool isNoneFillMode =
        destinationFillRegion == NavigationDestinationRegion.none;
    final bool isNoneHoverMode =
        destinationHoverRegion == NavigationDestinationRegion.none;
    final bool isCustomFillMode = !isDefaultFillPath && !isNoneFillMode;
    final bool shouldPaintSelectedFill = isSelected &&
        isCustomFillMode &&
        widget.iconIndicatorShape == null &&
        widget.labelIndicatorShape == null;
    final ShapeBorder? statefulSelectedShape =
        info.shape?.resolve(selectedShapeStates);
    final ShapeBorder effectiveFillShape =
        statefulSelectedShape ?? widget.shape ?? const StadiumBorder();
    final ShapeBorder effectiveHoverShape = resolveInteractionShape(
          shape: info.shape,
          isSelected: isSelected,
          isHovered: _isHovered,
          isPressed: _isPressed,
          isFocused: _isFocused,
        ) ??
        statefulSelectedShape ??
        widget.shape ??
        const StadiumBorder();
    final TextDirection textDirection = Directionality.of(context);
    final EdgeInsets fillPadding = widget.padding.resolve(textDirection);
    final bool hasVisibleText = switch (info.labelBehavior) {
      NavigationDestinationLabelBehavior.alwaysHide => false,
      NavigationDestinationLabelBehavior.alwaysShow => true,
      NavigationDestinationLabelBehavior.onlyShowSelected => isSelected,
    };
    final bool material3 = theme.useMaterial3;
    final ColorScheme colors = theme.colorScheme;
    final bool primaryColorAlphaModified =
        (colors.primary.a * 255.0).round().clamp(0, 255) < 255;
    final Color effectiveSplashColor = primaryColorAlphaModified
        ? colors.primary
        : colors.primary.withValues(alpha: 0.12);
    final Color effectiveHoverColor = primaryColorAlphaModified
        ? colors.primary
        : colors.primary.withValues(alpha: 0.04);

    final WidgetStateProperty<Color?>? baseOverlayColor =
        info.overlayColor ?? navigationBarTheme.overlayColor;
    final WidgetStateProperty<Color?>? effectiveOverlayColor =
        isSelected && isCustomFillMode
            ? WidgetStateProperty.resolveWith((Set<WidgetState> states) {
                if (states.contains(WidgetState.hovered) ||
                    states.contains(WidgetState.focused) ||
                    states.contains(WidgetState.pressed)) {
                  return Colors.transparent;
                }
                return baseOverlayColor?.resolve(states);
              })
            : baseOverlayColor;

    return _NavigationBarDestinationSemantics(
      enabled: widget.enabled,
      child: _NavigationBarDestinationTooltip(
        message: widget.tooltip?.isNotEmpty == true ? widget.tooltip : null,
        child: ClipRect(
          child: Stack(
            key: _destinationRegionKey,
            alignment: Alignment.center,
            children: <Widget>[
              if (shouldPaintSelectedFill && widget.color != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: _DestinationSelectionFill(
                      color: widget.color!,
                      shape: effectiveFillShape,
                      animation: widget.animation,
                      mode: destinationFillRegion,
                      textDirection: textDirection,
                      hasVisibleText: hasVisibleText,
                      destinationRegionKey: _destinationRegionKey,
                      iconRegionKey: _iconRegionKey,
                      labelRegionKey: _labelRegionKey,
                      fillPadding: fillPadding,
                    ),
                  ),
                ),
              _NavigationBarIndicatorInkWell(
                onTap: widget.enabled ? info.onTap : null,
                onHover: _setHovered,
                onHighlightChanged: _setPressed,
                onFocusChange: _setFocused,
                overlayColor: effectiveOverlayColor,
                customBorder: effectiveHoverShape,
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                splashColor: isNoneHoverMode ? null : effectiveSplashColor,
                hoverColor: isNoneHoverMode ? null : effectiveHoverColor,
                useMaterial3: material3,
                destinationHoverRegion: destinationHoverRegion,
                textDirection: textDirection,
                hasVisibleText: hasVisibleText,
                iconRegionKey: _iconRegionKey,
                labelRegionKey: _labelRegionKey,
                fillPadding: fillPadding,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    _StatusTransitionWidgetBuilder(
                      animation: widget.animation,
                      builder: (context, child) {
                        if (widget.buildContent != null) {
                          return Row(
                            children: <Widget>[
                              Expanded(child: widget.buildContent!(context)),
                            ],
                          );
                        }

                        Widget iconWidget = widget.buildIcon(context);
                        Widget labelWidget = widget.buildLabel(context);

                        // Match Flutter default/icon behavior by anchoring the
                        // indicator to the icon layer instead of centering it in
                        // the full destination region.
                        if (widget.iconIndicatorShape == null &&
                            widget.labelIndicatorShape == null &&
                            isDefaultFillPath) {
                          iconWidget = Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              NavigationIndicator(
                                animation: widget.animation,
                                color: widget.color,
                                shape: effectiveFillShape,
                              ),
                              iconWidget,
                            ],
                          );
                        }

                        if (widget.iconIndicatorShape != null) {
                          iconWidget = Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              NavigationIndicator(
                                animation: widget.animation,
                                color: widget.color,
                                shape: widget.iconIndicatorShape,
                              ),
                              iconWidget,
                            ],
                          );
                        }

                        if (widget.labelIndicatorShape != null) {
                          labelWidget = Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              NavigationIndicator(
                                animation: widget.animation,
                                color: widget.color,
                                shape: widget.labelIndicatorShape,
                              ),
                              labelWidget,
                            ],
                          );
                        }

                        return Row(
                          children: <Widget>[
                            Expanded(
                              child: _NavigationBarDestinationLayout(
                                icon: iconWidget,
                                iconKey: _iconRegionKey,
                                labelKey: _labelRegionKey,
                                padding: widget.padding,
                                label: labelWidget,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inherited widget for passing data from [CustomNavigationBar] to destination
/// children widgets.
///
/// Useful for building navigation destinations using:
/// `_NavigationDestinationInfo.of(context)`.
class _NavigationDestinationInfo extends InheritedWidget {
  /// Adds the information needed to build a navigation destination to the
  /// [child] and descendants.
  const _NavigationDestinationInfo({
    required this.index,
    required this.selectedIndex,
    required this.totalNumberOfDestinations,
    required this.selectedAnimation,
    required this.labelBehavior,
    required this.indicatorColor,
    required this.indicatorShape,
    required this.overlayColor,
    required this.labelTextStyle,
    required this.labelPadding,
    required this.margin,
    required this.padding,
    required this.tooltipVerticalOffset,
    required this.destinationFillRegion,
    required this.destinationHoverRegion,
    required this.shape,
    required this.onTap,
    required super.child,
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
  /// This is required for `_IndicatorInkWell` to apply label padding to ripple animations
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
  /// the [CustomNavigationDestination] is focused, hovered, or pressed.
  ///
  /// This is used by destinations to override the overlay color.
  final WidgetStateProperty<Color?>? overlayColor;

  /// Optional label text style override for destination labels.
  final WidgetStateProperty<TextStyle?>? labelTextStyle;

  /// Optional label padding override for destination labels.
  final EdgeInsetsGeometry? labelPadding;

  /// Optional margin override for the destination container.
  final EdgeInsetsGeometry? margin;

  /// Padding around destination item content.
  final EdgeInsetsGeometry padding;

  /// Tooltip offset override for this navigation bar.
  final double? tooltipVerticalOffset;

  /// Where destination selected fill/highlight is painted.
  final NavigationDestinationRegion? destinationFillRegion;

  /// Where destination hover/ink interaction effects are painted.
  final NavigationDestinationRegion? destinationHoverRegion;

  /// Optional stateful shape override for destination fill and interactions.
  ///
  /// Selected fill resolves with [WidgetState.selected]. Interaction shape
  /// resolves with [WidgetState.hovered], then [WidgetState.pressed], then
  /// [WidgetState.focused], and then falls back to the selected shape.
  ///
  /// If unresolved, [indicatorShape] is used, and then [StadiumBorder] as a
  /// final fallback.
  final WidgetStateProperty<ShapeBorder?>? shape;

  /// The callback that should be called when this destination is tapped.
  ///
  /// This is computed by calling [CustomNavigationBar.onDestinationSelected]
  /// with [index] passed in.
  final VoidCallback onTap;

  /// Returns a non null [_NavigationDestinationInfo].
  ///
  /// This will return an error if called with no [_NavigationDestinationInfo]
  /// ancestor.
  ///
  /// Used by widgets that are implementing a navigation destination info to
  /// get information like the selected animation and destination number.
  static _NavigationDestinationInfo of(BuildContext context) {
    final _NavigationDestinationInfo? result = context
        .dependOnInheritedWidgetOfExactType<_NavigationDestinationInfo>();
    assert(
      result != null,
      "Navigation destinations need a _NavigationDestinationInfo parent, "
      "which is usually provided by CustomNavigationBar.",
    );
    return result!;
  }

  @override
  bool updateShouldNotify(_NavigationDestinationInfo oldWidget) {
    return index != oldWidget.index ||
        totalNumberOfDestinations != oldWidget.totalNumberOfDestinations ||
        selectedAnimation != oldWidget.selectedAnimation ||
        labelBehavior != oldWidget.labelBehavior ||
        labelTextStyle != oldWidget.labelTextStyle ||
        labelPadding != oldWidget.labelPadding ||
        margin != oldWidget.margin ||
        padding != oldWidget.padding ||
        tooltipVerticalOffset != oldWidget.tooltipVerticalOffset ||
        destinationFillRegion != oldWidget.destinationFillRegion ||
        destinationHoverRegion != oldWidget.destinationHoverRegion ||
        shape != oldWidget.shape ||
        onTap != oldWidget.onTap;
  }
}

/// Selection indicator for Material 3 [CustomNavigationBar] and
/// [CustomNavigationRail] components.
///
/// When [animation] is 0, the indicator is not present. As [animation] grows
/// from 0 to 1, the indicator scales in on the x axis.
///
/// Used in a [Stack] widget behind the icons in the Material 3 Navigation Bar
/// to illuminate the selected destination.
class NavigationIndicator extends StatelessWidget {
  /// Builds an indicator, usually used in a stack behind the icon of a
  /// navigation bar destination.
  const NavigationIndicator({
    required this.animation,
    super.key,
    this.color,
    this.width = _kIndicatorWidth,
    this.height = _kIndicatorHeight,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.shape,
  });

  /// Determines the scale of the indicator.
  ///
  /// When [animation] is 0, the indicator is not present. The indicator scales
  /// in as [animation] grows from 0 to 1.
  final Animation<double> animation;

  /// The fill color of this indicator.
  ///
  /// If null, defaults to [ColorScheme.secondary].
  final Color? color;

  /// The width of this indicator.
  ///
  /// Defaults to `64`.
  final double width;

  /// The height of this indicator.
  ///
  /// Defaults to `32`.
  final double height;

  /// The border radius of the shape of the indicator.
  ///
  /// This is used to create a [RoundedRectangleBorder] shape for the indicator.
  /// This is ignored if [shape] is non-null.
  ///
  /// Defaults to `BorderRadius.circular(16)`.
  final BorderRadius borderRadius;

  /// The shape of the indicator.
  ///
  /// If non-null this is used as the shape used to draw the background
  /// of the indicator. If null then a [RoundedRectangleBorder] with the
  /// [borderRadius] is used.
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        // The scale should be 0 when the animation is unselected, as soon as
        // the animation starts, the scale jumps to 40%, and then animates to
        // 100% along a curve.
        final double scale = animation.isDismissed
            ? 0.0
            : Tween<double>(begin: .4, end: 1.0).transform(
                CurveTween(curve: Curves.easeInOutCubicEmphasized)
                    .transform(animation.value),
              );

        return Transform(
          alignment: Alignment.center,
          // Scale in the X direction only.
          transform: Matrix4.diagonal3Values(
            scale,
            1.0,
            1.0,
          ),
          child: child,
        );
      },
      // Fade should be a 100ms animation whenever the parent animation changes
      // direction.
      child: _StatusTransitionWidgetBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          return _SelectableAnimatedBuilder(
            isSelected: animation.isForwardOrCompleted,
            duration: const Duration(milliseconds: 100),
            alwaysDoFullAnimation: true,
            builder: (BuildContext context, Animation<double> fadeAnimation) {
              return FadeTransition(
                opacity: fadeAnimation,
                child: Ink(
                  width: width,
                  height: height,
                  // This is the selected item background
                  decoration: ShapeDecoration(
                    shape: shape ??
                        RoundedRectangleBorder(borderRadius: borderRadius),
                    color: color ?? Theme.of(context).colorScheme.secondary,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Widget that handles the layout of the icon + label in a navigation bar
/// destination, based on [_NavigationDestinationInfo.labelBehavior] and
/// [_NavigationDestinationInfo.selectedAnimation].
///
/// Depending on the [_NavigationDestinationInfo.labelBehavior], the labels
/// will shift and fade accordingly.
class _NavigationBarDestinationLayout extends StatelessWidget {
  /// Builds a widget to layout an icon + label for a destination in a Material
  /// 3 [NavigationBar].
  const _NavigationBarDestinationLayout({
    required this.icon,
    required this.iconKey,
    required this.labelKey,
    required this.label,
    this.padding = EdgeInsets.zero,
  });

  /// The icon widget that sits on top of the label.
  ///
  /// See [CustomNavigationDestination.icon].
  final Widget icon;

  /// The global key for the icon in this destination.
  final GlobalKey iconKey;

  /// The global key for the label in this destination.
  final GlobalKey labelKey;

  /// The label widget that sits below the icon.
  ///
  /// This widget will sometimes be faded out, depending on
  /// [_NavigationDestinationInfo.selectedAnimation].
  ///
  /// See [CustomNavigationDestination.label].
  final Widget label;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return _DestinationLayoutAnimationBuilder(
      builder: (BuildContext context, Animation<double> animation) {
        final _NavigationDestinationInfo info =
            _NavigationDestinationInfo.of(context);
        // For onlyShowSelected, freeze the icon y-position so icons don't
        // shift up/down as labels appear. The label still fades via the
        // selection animation below.
        final Animation<double> positionAnimation = info.labelBehavior ==
                NavigationDestinationLabelBehavior.onlyShowSelected
            ? kAlwaysDismissedAnimation
            : animation;
        return RepaintBoundary(
          child: CompactDestinationLayout(
            icon: icon,
            iconKey: iconKey,
            labelKey: labelKey,
            label: label,
            positionAnimation: positionAnimation,
            labelOpacity: animation,
            padding: padding,
          ),
        );
      },
    );
  }
}

/// Determines the appropriate [Curve] and [Animation] to use for laying out the
/// [CustomNavigationDestination], based on
/// [_NavigationDestinationInfo.labelBehavior].
///
/// The animation controlling the position and fade of the labels differs
/// from the selection animation, depending on the
/// [NavigationDestinationLabelBehavior]. This widget determines what
/// animation should be used for the position and fade of the labels.
class _DestinationLayoutAnimationBuilder extends StatelessWidget {
  /// Builds a child with the appropriate animation [Curve] based on the
  /// [_NavigationDestinationInfo.labelBehavior].
  const _DestinationLayoutAnimationBuilder({required this.builder});

  /// Builds the child of this widget.
  ///
  /// The [Animation] will be the appropriate [Animation] to use for the layout
  /// and fade of the [CustomNavigationDestination], either a curve, always
  /// showing (1), or always hiding (0).
  final Widget Function(BuildContext, Animation<double>) builder;

  @override
  Widget build(BuildContext context) {
    final _NavigationDestinationInfo info =
        _NavigationDestinationInfo.of(context);
    switch (info.labelBehavior) {
      case NavigationDestinationLabelBehavior.alwaysShow:
        return builder(context, kAlwaysCompleteAnimation);
      case NavigationDestinationLabelBehavior.alwaysHide:
        return builder(context, kAlwaysDismissedAnimation);
      case NavigationDestinationLabelBehavior.onlyShowSelected:
        return _CurvedAnimationBuilder(
          animation: info.selectedAnimation,
          curve: Curves.easeInOutCubicEmphasized,
          reverseCurve: Curves.easeInOutCubicEmphasized.flipped,
          builder: builder,
        );
    }
  }
}

class _NavigationBarIndicatorInkWell extends InkResponse {
  const _NavigationBarIndicatorInkWell({
    required this.useMaterial3,
    required this.destinationHoverRegion,
    required this.textDirection,
    required this.hasVisibleText,
    required this.iconRegionKey,
    required this.labelRegionKey,
    required this.fillPadding,
    super.child,
    super.onTap,
    super.onHover,
    super.onHighlightChanged,
    super.onFocusChange,
    super.overlayColor,
    ShapeBorder? customBorder,
    BorderRadius? borderRadius,
    super.splashColor,
    super.hoverColor,
  }) : super(
          containedInkWell: true,
          highlightShape: BoxShape.rectangle,
          borderRadius: useMaterial3 ? null : borderRadius,
          customBorder: useMaterial3 ? customBorder : null,
        );

  final bool useMaterial3;
  final NavigationDestinationRegion? destinationHoverRegion;
  final TextDirection textDirection;
  final bool hasVisibleText;
  final GlobalKey iconRegionKey;
  final GlobalKey labelRegionKey;
  final EdgeInsets fillPadding;

  @override
  RectCallback? getRectCallback(RenderBox referenceBox) {
    return () => _navigationBarDestinationHighlightRect(
          size: referenceBox.size,
          textDirection: textDirection,
          mode: destinationHoverRegion,
          hasVisibleText: hasVisibleText,
          fillPadding: fillPadding,
          referenceBox: referenceBox,
          iconRegionKey: iconRegionKey,
          labelRegionKey: labelRegionKey,
        );
  }
}

Rect _navigationBarDestinationHighlightRect({
  required Size size,
  required TextDirection textDirection,
  required NavigationDestinationRegion? mode,
  required bool hasVisibleText,
  required EdgeInsets fillPadding,
  RenderBox? referenceBox,
  GlobalKey? iconRegionKey,
  GlobalKey? labelRegionKey,
}) {
  final Rect fullRect = Offset.zero & size;

  final Rect fallbackIconRect = Rect.fromLTWH(
    (size.width - _kIndicatorWidth) / 2,
    (size.height - _kIndicatorHeight) / 2,
    _kIndicatorWidth,
    _kIndicatorHeight,
  );

  final Rect? measuredIconRect = referenceBox != null && iconRegionKey != null
      ? _resolveRegionRect(iconRegionKey, referenceBox)
      : null;
  final Rect? measuredLabelRect = referenceBox != null && labelRegionKey != null
      ? _resolveRegionRect(labelRegionKey, referenceBox)
      : null;
  final Rect effectiveIconRect = measuredIconRect ?? fallbackIconRect;
  final bool isDefaultFillPath =
      mode == null || mode == NavigationDestinationRegion.icon;
  if (isDefaultFillPath) {
    return effectiveIconRect;
  }
  if (mode == NavigationDestinationRegion.full) {
    return fullRect;
  }
  final bool hasLabelBounds = measuredLabelRect != null &&
      measuredLabelRect.width > 0 &&
      measuredLabelRect.height > 0;
  final bool shouldUseLabelBounds = hasVisibleText && hasLabelBounds;

  final bool hasExplicitHorizontalFillPadding =
      fillPadding.left > 0 || fillPadding.right > 0;
  final bool useFallbackHorizontalPadding = !hasExplicitHorizontalFillPadding &&
      (mode == NavigationDestinationRegion.content ||
          mode == NavigationDestinationRegion.label);
  final double horizontalPadding = useFallbackHorizontalPadding
      ? _horizontalDestinationPadding
      : fillPadding.left;
  final double topPadding = fillPadding.top;
  final double bottomPadding = fillPadding.bottom;

  Rect expandAndClamp(
    Rect rect, {
    double leftPadding = 0,
    double rightPadding = 0,
  }) {
    double left = rect.left - leftPadding;
    double right = rect.right + rightPadding;

    if (left < fullRect.left) {
      final double delta = fullRect.left - left;
      left += delta;
      right += delta;
    }
    if (right > fullRect.right) {
      final double delta = right - fullRect.right;
      left -= delta;
      right -= delta;
    }

    left = left.clamp(fullRect.left, fullRect.right);
    right = right.clamp(fullRect.left, fullRect.right);
    if (right < left) {
      right = left;
    }

    return Rect.fromLTRB(
      left,
      (rect.top - topPadding).clamp(0.0, fullRect.bottom),
      right,
      (rect.bottom + bottomPadding).clamp(0.0, fullRect.bottom),
    );
  }

  switch (mode) {
    case NavigationDestinationRegion.none:
      return Rect.zero;
    case NavigationDestinationRegion.icon:
      return effectiveIconRect;
    case NavigationDestinationRegion.content:
      const double contentExtraHorizontalPadding = 4.0;
      const double contentExtraVerticalPadding = 4.0;
      final double contentHorizontalPadding =
          horizontalPadding + contentExtraHorizontalPadding;
      if (!shouldUseLabelBounds) {
        final Rect iconContentRect =
            effectiveIconRect.inflate(contentExtraVerticalPadding);
        return expandAndClamp(
          iconContentRect,
          leftPadding: contentHorizontalPadding,
          rightPadding: contentHorizontalPadding,
        );
      }
      final Rect combined =
          effectiveIconRect.expandToInclude(measuredLabelRect);
      final Rect contentRect = combined.inflate(contentExtraVerticalPadding);
      return expandAndClamp(
        contentRect,
        leftPadding: contentHorizontalPadding,
        rightPadding: contentHorizontalPadding,
      );
    case NavigationDestinationRegion.label:
      if (!shouldUseLabelBounds) {
        return Rect.zero;
      }
      final Rect labelBand = measuredLabelRect;
      double targetWidth = labelBand.width + (horizontalPadding * 2);
      final double minimumWidth = _kIndicatorWidth + (horizontalPadding * 2);
      if (targetWidth < minimumWidth) {
        targetWidth = minimumWidth;
      }

      double left = labelBand.center.dx - (targetWidth / 2);
      double right = labelBand.center.dx + (targetWidth / 2);

      if (left < fullRect.left) {
        final double delta = fullRect.left - left;
        left += delta;
        right += delta;
      }
      if (right > fullRect.right) {
        final double delta = right - fullRect.right;
        left -= delta;
        right -= delta;
      }

      left = left.clamp(fullRect.left, fullRect.right);
      right = right.clamp(fullRect.left, fullRect.right);
      if (right < left) {
        right = left;
      }
      final double desiredTop = labelBand.center.dy - (_kIndicatorHeight / 2);
      double top = desiredTop;
      top = top.clamp(
        0.0,
        (fullRect.bottom - _kIndicatorHeight).clamp(0.0, fullRect.bottom),
      );
      final double bottom =
          (top + _kIndicatorHeight).clamp(0.0, fullRect.bottom);
      return Rect.fromLTRB(
        left,
        top,
        right,
        bottom,
      );
    case NavigationDestinationRegion.full:
      return fullRect;
  }
}

class _DestinationSelectionFill extends StatelessWidget {
  const _DestinationSelectionFill({
    required this.color,
    required this.shape,
    required this.animation,
    required this.mode,
    required this.textDirection,
    required this.hasVisibleText,
    required this.destinationRegionKey,
    required this.iconRegionKey,
    required this.labelRegionKey,
    required this.fillPadding,
  });

  final Color color;
  final ShapeBorder shape;
  final Animation<double> animation;
  final NavigationDestinationRegion mode;
  final TextDirection textDirection;
  final bool hasVisibleText;
  final GlobalKey destinationRegionKey;
  final GlobalKey iconRegionKey;
  final GlobalKey labelRegionKey;
  final EdgeInsets fillPadding;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double scale = animation.isDismissed
            ? 0.0
            : Tween<double>(begin: .4, end: 1.0).transform(
                CurveTween(curve: Curves.easeInOutCubicEmphasized)
                    .transform(animation.value),
              );
        return Opacity(
          opacity: animation.value,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(scale, 1.0, 1.0),
            child: child,
          ),
        );
      },
      child: CustomPaint(
        painter: _DestinationSelectionFillPainter(
          color: color,
          shape: shape,
          mode: mode,
          textDirection: textDirection,
          hasVisibleText: hasVisibleText,
          destinationRegionKey: destinationRegionKey,
          iconRegionKey: iconRegionKey,
          labelRegionKey: labelRegionKey,
          fillPadding: fillPadding,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _DestinationSelectionFillPainter extends CustomPainter {
  const _DestinationSelectionFillPainter({
    required this.color,
    required this.shape,
    required this.mode,
    required this.textDirection,
    required this.hasVisibleText,
    required this.destinationRegionKey,
    required this.iconRegionKey,
    required this.labelRegionKey,
    required this.fillPadding,
  });

  final Color color;
  final ShapeBorder shape;
  final NavigationDestinationRegion mode;
  final TextDirection textDirection;
  final bool hasVisibleText;
  final GlobalKey destinationRegionKey;
  final GlobalKey iconRegionKey;
  final GlobalKey labelRegionKey;
  final EdgeInsets fillPadding;

  @override
  void paint(Canvas canvas, Size size) {
    final RenderBox? destinationBox =
        _resolveReferenceBox(destinationRegionKey);
    final Rect rect = _navigationBarDestinationHighlightRect(
      size: size,
      textDirection: textDirection,
      mode: mode,
      hasVisibleText: hasVisibleText,
      fillPadding: fillPadding,
      referenceBox: destinationBox,
      iconRegionKey: iconRegionKey,
      labelRegionKey: labelRegionKey,
    );
    final Path path = shape.getOuterPath(rect, textDirection: textDirection);
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_DestinationSelectionFillPainter oldDelegate) {
    return color != oldDelegate.color ||
        shape != oldDelegate.shape ||
        mode != oldDelegate.mode ||
        textDirection != oldDelegate.textDirection ||
        hasVisibleText != oldDelegate.hasVisibleText ||
        destinationRegionKey != oldDelegate.destinationRegionKey ||
        iconRegionKey != oldDelegate.iconRegionKey ||
        labelRegionKey != oldDelegate.labelRegionKey ||
        fillPadding != oldDelegate.fillPadding;
  }
}

RenderBox? _resolveReferenceBox(GlobalKey key) {
  final BuildContext? context = key.currentContext;
  if (context == null) return null;
  final RenderObject? renderObject = context.findRenderObject();
  if (renderObject is! RenderBox || !renderObject.attached) return null;
  return renderObject;
}

Rect? _resolveRegionRect(GlobalKey key, RenderBox referenceBox) {
  final BuildContext? context = key.currentContext;
  if (context == null) return null;

  final RenderObject? renderObject = context.findRenderObject();
  if (renderObject is! RenderBox || !renderObject.attached) return null;

  final Offset topLeft = renderObject.localToGlobal(
    Offset.zero,
    ancestor: referenceBox,
  );
  return topLeft & renderObject.size;
}

/// Semantics widget for a [CustomNavigationBar] destination.
///
/// Requires a [_NavigationDestinationInfo] parent (normally provided by the
/// [CustomNavigationBar] by default).
///
/// Provides localized semantic labels to the destination, for example, it will
/// read "Home, Tab 1 of 3".
///
/// Used by [_NavigationDestinationBuilder].
class _NavigationBarDestinationSemantics extends StatelessWidget {
  /// Adds the appropriate semantics for navigation bar destinations to the
  /// [child].
  const _NavigationBarDestinationSemantics({
    required this.enabled,
    required this.child,
  });

  /// Whether this widget is enabled.
  final bool enabled;

  /// The widget that should receive the destination semantics.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final _NavigationDestinationInfo destinationInfo =
        _NavigationDestinationInfo.of(context);
    // The AnimationStatusBuilder will make sure that the semantics update to
    // "selected" when the animation status changes.
    return _StatusTransitionWidgetBuilder(
      animation: destinationInfo.selectedAnimation,
      builder: (BuildContext context, Widget? child) {
        return Semantics(enabled: enabled, button: true, child: child);
      },
      child: kIsWeb
          ? child
          : Stack(
              alignment: Alignment.center,
              children: <Widget>[
                child,
                Semantics(
                  label: localizations.tabLabel(
                    tabIndex: destinationInfo.index + 1,
                    tabCount: destinationInfo.totalNumberOfDestinations,
                  ),
                ),
              ],
            ),
    );
  }
}

/// Tooltip widget for use in a [CustomNavigationBar].
///
/// It appears just above the navigation bar when one of the destinations is
/// long pressed.
class _NavigationBarDestinationTooltip extends StatelessWidget {
  /// Adds a tooltip to the [child] widget.
  ///
  /// When [message] is null no [Tooltip] is rendered and [child] is returned
  /// directly, so passing `tooltip: null` on a
  /// [CustomNavigationDestination] truly suppresses the tooltip.
  const _NavigationBarDestinationTooltip({
    required this.message,
    required this.child,
  });

  /// The explicit text rendered in the tooltip.
  final String? message;

  /// The widget that, when long-pressed, will show the tooltip.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) return child;

    final double tooltipVerticalOffset =
        _NavigationDestinationInfo.of(context).tooltipVerticalOffset ?? 42;

    return _NavigationBarTooltipGestureTarget(
      message: message!,
      verticalOffset: tooltipVerticalOffset,
      child: child,
    );
  }
}

class _NavigationBarTooltipGestureTarget extends StatefulWidget {
  const _NavigationBarTooltipGestureTarget({
    required this.message,
    required this.verticalOffset,
    required this.child,
  });

  final String message;
  final double verticalOffset;
  final Widget child;

  @override
  State<_NavigationBarTooltipGestureTarget> createState() =>
      _NavigationBarTooltipGestureTargetState();
}

class _NavigationBarTooltipGestureTargetState
    extends State<_NavigationBarTooltipGestureTarget> {
  static const Duration _manualTooltipShowDuration = Duration(seconds: 2);

  final GlobalKey<TooltipState> _tooltipKey = GlobalKey<TooltipState>();
  Timer? _hideTimer;
  bool _tooltipVisible = false;

  void _showTooltip() {
    _hideTimer?.cancel();

    if (!_tooltipVisible && mounted) {
      setState(() {
        _tooltipVisible = true;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _tooltipKey.currentState?.ensureTooltipVisible();
    });

    _hideTimer = Timer(_manualTooltipShowDuration, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _tooltipVisible = false;
      });
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TooltipVisibility(
      visible: _tooltipVisible,
      child: Tooltip(
        key: _tooltipKey,
        message: widget.message,
        triggerMode: TooltipTriggerMode.manual,
        verticalOffset: widget.verticalOffset,
        showDuration: _manualTooltipShowDuration,
        excludeFromSemantics: true,
        preferBelow: false,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onLongPress: _showTooltip,
          onSecondaryTapDown: (_) => _showTooltip(),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Widget that listens to an animation, and rebuilds when the animation changes
/// [AnimationStatus].
///
/// This can be more efficient than just using an [AnimatedBuilder] when you
/// only need to rebuild when the [Animation.status] changes, since
/// [AnimatedBuilder] rebuilds every time the animation ticks.
class _StatusTransitionWidgetBuilder extends StatusTransitionWidget {
  /// Creates a widget that rebuilds when the given animation changes status.
  const _StatusTransitionWidgetBuilder({
    required super.animation,
    required this.builder,
    this.child,
  });

  /// Called every time the [animation] changes [AnimationStatus].
  final TransitionBuilder builder;

  /// The child widget to pass to the [builder].
  ///
  /// If a [builder] callback's return value contains a subtree that does not
  /// depend on the animation, it's more efficient to build that subtree once
  /// instead of rebuilding it on every animation status change.
  ///
  /// Using this pre-built child is entirely optional, but can improve
  /// performance in some cases and is therefore a good practice.
  ///
  /// See: [AnimatedBuilder.child]
  final Widget? child;

  @override
  Widget build(BuildContext context) => builder(context, child);
}

// Builder widget for widgets that need to be animated from 0 (unselected) to
// 1.0 (selected).
//
// This widget creates and manages an [AnimationController] that it passes down
// to the child through the [builder] function.
//
// When [isSelected] is `true`, the animation controller will animate from
// 0 to 1 (for [duration] time).
//
// When [isSelected] is `false`, the animation controller will animate from
// 1 to 0 (for [duration] time).
//
// If [isSelected] is updated while the widget is animating, the animation will
// be reversed until it is either 0 or 1 again. If [alwaysDoFullAnimation] is
// true, the animation will reset to 0 or 1 before beginning the animation, so
// that the full animation is done.
//
// Usage:
// ```dart
// _SelectableAnimatedBuilder(
//   isSelected: _isDrawerOpen,
//   builder: (context, animation) {
//     return AnimatedIcon(
//       icon: AnimatedIcons.menu_arrow,
//       progress: animation,
//       semanticLabel: 'Show menu',
//     );
//   }
// )
// ```
class _SelectableAnimatedBuilder extends StatefulWidget {
  /// Builds and maintains an [AnimationController] that will animate from 0 to
  /// 1 and back depending on when [isSelected] is true.
  const _SelectableAnimatedBuilder({
    required this.isSelected,
    required this.builder,
    this.duration = const Duration(milliseconds: 200),
    this.alwaysDoFullAnimation = false,
  });

  /// When true, the widget will animate an animation controller from 0 to 1.
  ///
  /// The animation controller is passed to the child widget through [builder].
  final bool isSelected;

  /// How long the animation controller should animate for when [isSelected] is
  /// updated.
  ///
  /// If the animation is currently running and [isSelected] is updated, only
  /// the [duration] left to finish the animation will be run.
  final Duration duration;

  /// If true, the animation will always go all the way from 0 to 1 when
  /// [isSelected] is true, and from 1 to 0 when [isSelected] is false, even
  /// when the status changes mid animation.
  ///
  /// If this is false and the status changes mid animation, the animation will
  /// reverse direction from it's current point.
  ///
  /// Defaults to false.
  final bool alwaysDoFullAnimation;

  /// Builds the child widget based on the current animation status.
  ///
  /// When [isSelected] is updated to true, this builder will be called and the
  /// animation will animate up to 1. When [isSelected] is updated to
  /// `false`, this will be called and the animation will animate down to 0.
  final Widget Function(BuildContext, Animation<double>) builder;

  @override
  _SelectableAnimatedBuilderState createState() =>
      _SelectableAnimatedBuilderState();
}

/// State that manages the [AnimationController] that is passed to
/// [_SelectableAnimatedBuilder.builder].
class _SelectableAnimatedBuilderState extends State<_SelectableAnimatedBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.duration = widget.duration;
    _controller.value = widget.isSelected ? 1.0 : 0.0;
  }

  @override
  void didUpdateWidget(_SelectableAnimatedBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.isSelected != widget.isSelected) {
      if (widget.isSelected) {
        _controller.forward(from: widget.alwaysDoFullAnimation ? 0 : null);
      } else {
        _controller.reverse(from: widget.alwaysDoFullAnimation ? 1 : null);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _controller,
    );
  }
}

/// Watches [animation] and calls [builder] with the appropriate [Curve]
/// depending on the direction of the [animation] status.
///
/// If [animation.status] is forward or complete, [curve] is used. If
/// [animation.status] is reverse or dismissed, [reverseCurve] is used.
///
/// If the [animation] changes direction while it is already running, the curve
/// used will not change, this will keep the animations smooth until it
/// completes.
///
/// This is similar to [CurvedAnimation] except the animation status listeners
/// are removed when this widget is disposed.
class _CurvedAnimationBuilder extends StatefulWidget {
  const _CurvedAnimationBuilder({
    required this.animation,
    required this.curve,
    required this.reverseCurve,
    required this.builder,
  });

  final Animation<double> animation;
  final Curve curve;
  final Curve reverseCurve;
  final Widget Function(BuildContext, Animation<double>) builder;

  @override
  _CurvedAnimationBuilderState createState() => _CurvedAnimationBuilderState();
}

class _CurvedAnimationBuilderState extends State<_CurvedAnimationBuilder> {
  late AnimationStatus _animationDirection;
  AnimationStatus? _preservedDirection;

  @override
  void initState() {
    super.initState();
    _animationDirection = widget.animation.status;
    _updateStatus(widget.animation.status);
    widget.animation.addStatusListener(_updateStatus);
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_updateStatus);
    super.dispose();
  }

  // Keeps track of the current animation status, as well as the "preserved
  // direction" when the animation changes direction mid animation.
  //
  // The preserved direction is reset when the animation finishes in either
  // direction.
  void _updateStatus(AnimationStatus status) {
    if (_animationDirection != status) {
      setState(() {
        _animationDirection = status;
      });
    }
    switch (status) {
      case AnimationStatus.forward || AnimationStatus.reverse
          when _preservedDirection != null:
        break;
      case AnimationStatus.forward || AnimationStatus.reverse:
        setState(() {
          _preservedDirection = status;
        });
      case AnimationStatus.completed || AnimationStatus.dismissed:
        setState(() {
          _preservedDirection = null;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldUseForwardCurve =
        (_preservedDirection ?? _animationDirection) != AnimationStatus.reverse;

    final Animation<double> curvedAnimation = CurveTween(
      curve: shouldUseForwardCurve ? widget.curve : widget.reverseCurve,
    ).animate(widget.animation);

    return widget.builder(context, curvedAnimation);
  }
}

NavigationBarThemeData _defaultsFor(BuildContext context) {
  return Theme.of(context).useMaterial3
      ? _NavigationBarDefaultsM3(context)
      : _NavigationBarDefaultsM2(context);
}

// Hand coded defaults based on Material Design 2.
class _NavigationBarDefaultsM2 extends NavigationBarThemeData {
  _NavigationBarDefaultsM2(BuildContext context)
      : _theme = Theme.of(context),
        _colors = Theme.of(context).colorScheme,
        super(
          height: 80.0,
          elevation: 0.0,
          indicatorShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        );

  final ThemeData _theme;
  final ColorScheme _colors;

  // With Material 2, the NavigationBar uses an overlay blend for the
  // default color regardless of light/dark mode.
  @override
  Color? get backgroundColor => ElevationOverlay.colorWithOverlay(
        _colors.surface,
        _colors.onSurface,
        3.0,
      );

  @override
  WidgetStateProperty<IconThemeData?>? get iconTheme {
    return WidgetStatePropertyAll<IconThemeData>(
      IconThemeData(
        size: 24,
        color: _colors.onSurface,
      ),
    );
  }

  @override
  Color? get indicatorColor => _colors.secondary.withValues(alpha: 0.24);

  @override
  WidgetStateProperty<TextStyle?>? get labelTextStyle =>
      WidgetStatePropertyAll<TextStyle?>(
        _theme.textTheme.labelSmall!.copyWith(color: _colors.onSurface),
      );

  @override
  EdgeInsetsGeometry? get labelPadding => const EdgeInsets.only(top: 4);
}

// BEGIN GENERATED TOKEN PROPERTIES - NavigationBar

// Do not edit by hand. The code between the "BEGIN GENERATED" and
// "END GENERATED" comments are generated from data in the Material
// Design token database by the script:
//   dev/tools/gen_defaults/bin/gen_defaults.dart.

class _NavigationBarDefaultsM3 extends NavigationBarThemeData {
  _NavigationBarDefaultsM3(this.context)
      : super(
          height: 80.0,
          elevation: 3.0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => _colors.surfaceContainer;

  @override
  Color? get shadowColor => Colors.transparent;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  WidgetStateProperty<IconThemeData?>? get iconTheme {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      return IconThemeData(
        size: 24.0,
        color: states.contains(WidgetState.disabled)
            ? _colors.onSurfaceVariant.withValues(alpha: 0.38)
            : states.contains(WidgetState.selected)
                ? _colors.onSecondaryContainer
                : _colors.onSurfaceVariant,
      );
    });
  }

  @override
  Color? get indicatorColor => _colors.secondaryContainer;
  @override
  ShapeBorder? get indicatorShape => const StadiumBorder();

  @override
  WidgetStateProperty<TextStyle?>? get labelTextStyle {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      final TextStyle style = _textTheme.labelMedium!;
      return style.apply(
        color: states.contains(WidgetState.disabled)
            ? _colors.onSurfaceVariant.withValues(alpha: 0.38)
            : states.contains(WidgetState.selected)
                ? _colors.onSurface
                : _colors.onSurfaceVariant,
      );
    });
  }

  @override
  EdgeInsetsGeometry? get labelPadding => const EdgeInsets.only(top: 4);
}

// END GENERATED TOKEN PROPERTIES - NavigationBar
