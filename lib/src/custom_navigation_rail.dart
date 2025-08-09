// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import "dart:ui";

import "package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart";
import "package:flutter/material.dart";

part "rail_destination.dart";

/// A Material Design widget that is meant to be displayed at the left or right of an
/// app to navigate between a small number of views, typically between three and
/// five.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=y9xchtVTtqQ}
///
/// The navigation rail is meant for layouts with wide viewports, such as a
/// desktop web or tablet landscape layout. For smaller layouts, like mobile
/// portrait, a [BottomNavigationBar] should be used instead.
///
/// A navigation rail is usually used as the first or last element of a [Row]
/// which defines the app's [Scaffold] body.
///
/// The appearance of all of the [CustomNavigationRail]s within an app can be
/// specified with [NavigationRailTheme]. The default values for null theme
/// properties are based on the [Theme]'s [ThemeData.textTheme],
/// [ThemeData.iconTheme], and [ThemeData.colorScheme].
///
/// Adaptive layouts can build different instances of the [Scaffold] in order to
/// have a navigation rail for more horizontal layouts and a bottom navigation
/// bar for more vertical layouts. See
/// [the adaptive_scaffold.dart sample](https://github.com/flutter/samples/blob/main/experimental/web_dashboard/lib/src/widgets/third_party/adaptive_scaffold.dart)
/// for an example.
///
/// {@tool dartpad}
/// This example shows a [CustomNavigationRail] used within a Scaffold with 3
/// [NavigationRailDestination]s. The main content is separated by a divider
/// (although elevation on the navigation rail can be used instead). The
/// `_selectedIndex` is updated by the `onDestinationSelected` callback.
///
/// ** See code in examples/api/lib/material/navigation_rail/navigation_rail.0.dart **
/// {@end-tool}
///
/// {@tool dartpad}
/// This sample shows the creation of [CustomNavigationRail] widget used within a Scaffold with 3
/// [NavigationRailDestination]s, as described in: https://m3.material.io/components/navigation-rail/overview
///
/// ** See code in examples/api/lib/material/navigation_rail/navigation_rail.1.dart **
/// {@end-tool}
///
/// See also:
///
///  * [Scaffold], which can display the navigation rail within a [Row] of the
///    [Scaffold.body] slot.
///  * [NavigationRailDestination], which is used as a model to create tappable
///    destinations in the navigation rail.
///  * [BottomNavigationBar], which is a similar navigation widget that's laid
///     out horizontally.
///  * <https://material.io/components/navigation-rail/>
///  * <https://m3.material.io/components/navigation-rail>
class CustomNavigationRail extends StatefulWidget implements NavigationRail {
  /// Creates a Material Design navigation rail.
  ///
  /// The value of [destinations] must be a list of two or more
  /// [NavigationRailDestination] values.
  ///
  /// If [elevation] is specified, it must be non-negative.
  ///
  /// If [minWidth] is specified, it must be non-negative, and if
  /// [minExtendedWidth] is specified, it must be non-negative and greater than
  /// [minWidth].
  ///
  /// The [extended] argument can only be set to true when the [labelType] is
  /// null or [NavigationRailLabelType.none].
  ///
  /// If [backgroundColor], [elevation], [groupAlignment], [labelType],
  /// [unselectedLabelTextStyle], [selectedLabelTextStyle],
  /// [unselectedIconTheme], or [selectedIconTheme] are null, then their
  /// [NavigationRailThemeData] values will be used. If the corresponding
  /// [NavigationRailThemeData] property is null, then the navigation rail
  /// defaults are used. See the individual properties for more information.
  ///
  /// Typically used within a [Row] that defines the [Scaffold.body] property.
  const CustomNavigationRail({
    required this.destinations,
    required this.selectedIndex,
    super.key,
    this.backgroundColor,
    this.extended = false,
    this.leading,
    this.trailing,
    this.onDestinationSelected,
    this.elevation,
    this.groupAlignment,
    this.labelType,
    this.unselectedLabelTextStyle,
    this.selectedLabelTextStyle,
    this.unselectedIconTheme,
    this.selectedIconTheme,
    this.minWidth,
    this.minExtendedWidth,
    this.useIndicator,
    this.indicatorColor,
    this.indicatorShape,
    this.leadingAtTop = true,
    this.trailingAtBottom = false,
    this.scrollable = false,
  })  : assert(destinations.length >= 2),
        assert(
          selectedIndex == null ||
              (0 <= selectedIndex && selectedIndex < destinations.length),
        ),
        assert(elevation == null || elevation > 0),
        assert(minWidth == null || minWidth > 0),
        assert(minExtendedWidth == null || minExtendedWidth > 0),
        assert(
          (minWidth == null || minExtendedWidth == null) ||
              minExtendedWidth >= minWidth,
        ),
        assert(
          !extended ||
              (labelType == null || labelType == NavigationRailLabelType.none),
        );

  /// Sets the color of the Container that holds all of the [CustomNavigationRail]'s
  /// contents.
  ///
  /// The default value is [NavigationRailThemeData.backgroundColor]. If
  /// [NavigationRailThemeData.backgroundColor] is null, then the default value
  /// is based on [ColorScheme.surface] of [ThemeData.colorScheme].
  @override
  final Color? backgroundColor;

  /// Indicates that the [CustomNavigationRail] should be in the extended state.
  ///
  /// The extended state has a wider rail container, and the labels are
  /// positioned next to the icons. [minExtendedWidth] can be used to set the
  /// minimum width of the rail when it is in this state.
  ///
  /// The rail will implicitly animate between the extended and normal state.
  ///
  /// If the rail is going to be in the extended state, then the [labelType]
  /// must be set to [NavigationRailLabelType.none].
  ///
  /// The default value is false.
  @override
  final bool extended;

  /// The leading widget in the rail that is placed above the destinations.
  ///
  /// It is placed at the top of the rail, above the [destinations]. Its
  /// location is not affected by [groupAlignment].
  ///
  /// This is commonly a [FloatingActionButton], but may also be a non-button,
  /// such as a logo.
  ///
  /// The default value is null.
  @override
  final Widget? leading;

  /// The trailing widget in the rail that is placed below the destinations.
  ///
  /// The trailing widget is placed below the last [NavigationRailDestination].
  /// It's location is affected by [groupAlignment].
  ///
  /// This is commonly a list of additional options or destinations that is
  /// usually only rendered when [extended] is true.
  ///
  /// The default value is null.
  @override
  final Widget? trailing;

  /// Defines the appearance of the button items that are arrayed within the
  /// navigation rail.
  ///
  /// The value must be a list of two or more [NavigationRailDestination]
  /// values.
  @override
  final List<NavigationRailDestination> destinations;

  /// The index into [destinations] for the current selected
  /// [NavigationRailDestination] or null if no destination is selected.
  @override
  final int? selectedIndex;

  /// Called when one of the [destinations] is selected.
  ///
  /// The stateful widget that creates the navigation rail needs to keep
  /// track of the index of the selected [NavigationRailDestination] and call
  /// `setState` to rebuild the navigation rail with the new [selectedIndex].
  @override
  final ValueChanged<int>? onDestinationSelected;

  /// The rail's elevation or z-coordinate.
  ///
  /// If [Directionality] is [intl.TextDirection.LTR], the inner side is the
  /// right side, and if [Directionality] is [intl.TextDirection.RTL], it is
  /// the left side.
  ///
  /// The default value is 0.
  @override
  final double? elevation;

  /// The vertical alignment for the group of [destinations] within the rail.
  ///
  /// The [NavigationRailDestination]s are grouped together with the [trailing]
  /// widget, between the [leading] widget and the bottom of the rail.
  ///
  /// The value must be between -1.0 and 1.0.
  ///
  /// If [groupAlignment] is -1.0, then the items are aligned to the top. If
  /// [groupAlignment] is 0.0, then the items are aligned to the center. If
  /// [groupAlignment] is 1.0, then the items are aligned to the bottom.
  ///
  /// The default is -1.0.
  ///
  /// See also:
  ///   * [Alignment.y]
  ///
  @override
  final double? groupAlignment;

  /// Defines the layout and behavior of the labels for the default, unextended
  /// [CustomNavigationRail].
  ///
  /// When a navigation rail is [extended], the labels are always shown.
  ///
  /// The default value is [NavigationRailThemeData.labelType]. If
  /// [NavigationRailThemeData.labelType] is null, then the default value is
  /// [NavigationRailLabelType.none].
  ///
  /// See also:
  ///
  ///   * [NavigationRailLabelType] for information on the meaning of different
  ///   types.
  @override
  final NavigationRailLabelType? labelType;

  /// The [TextStyle] of a destination's label when it is unselected.
  ///
  /// When one of the [destinations] is selected the [selectedLabelTextStyle]
  /// will be used instead.
  ///
  /// The default value is based on the [Theme]'s [TextTheme.bodyLarge]. The
  /// default color is based on the [Theme]'s [ColorScheme.onSurface].
  ///
  /// Properties from this text style, or
  /// [NavigationRailThemeData.unselectedLabelTextStyle] if this is null, are
  /// merged into the defaults.
  @override
  final TextStyle? unselectedLabelTextStyle;

  /// The [TextStyle] of a destination's label when it is selected.
  ///
  /// When a [NavigationRailDestination] is not selected,
  /// [unselectedLabelTextStyle] will be used.
  ///
  /// The default value is based on the [TextTheme.bodyLarge] of
  /// [ThemeData.textTheme]. The default color is based on the [Theme]'s
  /// [ColorScheme.primary].
  ///
  /// Properties from this text style,
  /// or [NavigationRailThemeData.selectedLabelTextStyle] if this is null, are
  /// merged into the defaults.
  @override
  final TextStyle? selectedLabelTextStyle;

  /// The visual properties of the icon in the unselected destination.
  ///
  /// If this field is not provided, or provided with any null properties, then
  /// a copy of the [IconThemeData.fallback] with a custom [CustomNavigationRail]
  /// specific color will be used.
  ///
  /// The default value is the [Theme]'s [ThemeData.iconTheme] with a color
  /// of the [Theme]'s [ColorScheme.onSurface] with an opacity of 0.64.
  /// Properties from this icon theme, or
  /// [NavigationRailThemeData.unselectedIconTheme] if this is null, are
  /// merged into the defaults.
  @override
  final IconThemeData? unselectedIconTheme;

  /// The visual properties of the icon in the selected destination.
  ///
  /// When a [NavigationRailDestination] is not selected,
  /// [unselectedIconTheme] will be used.
  ///
  /// The default value is the [Theme]'s [ThemeData.iconTheme] with a color
  /// of the [Theme]'s [ColorScheme.primary]. Properties from this icon theme,
  /// or [NavigationRailThemeData.selectedIconTheme] if this is null, are
  /// merged into the defaults.
  @override
  final IconThemeData? selectedIconTheme;

  /// The smallest possible width for the rail regardless of the destination's
  /// icon or label size.
  ///
  /// The default is 72.
  ///
  /// This value also defines the min width and min height of the destinations.
  ///
  /// To make a compact rail, set this to 56 and use
  /// [NavigationRailLabelType.none].
  @override
  final double? minWidth;

  /// The final width when the animation is complete for setting [extended] to
  /// true.
  ///
  /// This is only used when [extended] is set to true.
  ///
  /// The default value is 256.
  @override
  final double? minExtendedWidth;

  /// If `true`, adds a rounded [NavigationIndicator] behind the selected
  /// destination's icon.
  ///
  /// The indicator's shape will be circular if [labelType] is
  /// [NavigationRailLabelType.none], or a [StadiumBorder] if [labelType] is
  /// [NavigationRailLabelType.all] or [NavigationRailLabelType.selected].
  ///
  /// If `null`, defaults to [NavigationRailThemeData.useIndicator]. If that is
  /// `null`, defaults to [ThemeData.useMaterial3].
  @override
  final bool? useIndicator;

  /// Overrides the default value of [CustomNavigationRail]'s selection indicator color,
  /// when [useIndicator] is true.
  ///
  /// If this is null, [NavigationRailThemeData.indicatorColor] is used. If
  /// that is null, defaults to [ColorScheme.secondaryContainer].
  @override
  final Color? indicatorColor;

  /// Overrides the default value of [CustomNavigationRail]'s selection indicator shape,
  /// when [useIndicator] is true.
  ///
  /// If this is null, [NavigationRailThemeData.indicatorShape] is used. If
  /// that is null, defaults to [StadiumBorder].
  @override
  final ShapeBorder? indicatorShape;

  /// Pin the [leading] widget to the top.
  ///
  /// If `true`, the [leading] widget is pinned to the top of the
  /// [NavigationRail]. Otherwise it precedes directly the main group of
  /// [destinations].
  ///
  /// See also [scrollable] for a description of the interplay of these
  /// parameters.
  @override
  final bool leadingAtTop;

  /// Pin the [trailing] widget to the bottom.
  ///
  /// If `true`, the [trailing] widget is pinned to the bottom of the
  /// [NavigationRail]. Otherwise it follows directly the main group of
  /// [destinations].
  ///
  /// See also [scrollable] for a description of the interplay of these
  /// parameters.
  @override
  final bool trailingAtBottom;
  
  /// Whether the main group of items should be scrollable when vertical space
  /// is insufficient to show all of [destinations], [leading] and [trailing].
  ///
  /// If [leadingAtTop] or [trailingAtBottom] are false, [leading] or [trailing]
  /// widgets, respectively, are part of the main group in addition to
  /// [destinations]. Otherwise these are statical at the top or bottom,
  /// respectively.
  @override
  final bool scrollable;

  /// Returns the animation that controls the [CustomNavigationRail.extended] state.
  ///
  /// This can be used to synchronize animations in the [leading] or [trailing]
  /// widget, such as an animated menu or a [FloatingActionButton] animation.
  ///
  /// {@tool dartpad}
  /// This example shows how to use this animation to create a [FloatingActionButton]
  /// that animates itself between the normal and extended states of the
  /// [CustomNavigationRail].
  ///
  /// An instance of `MyNavigationRailFab` is created for [CustomNavigationRail.leading].
  /// Pressing the FAB button toggles the "extended" state of the [CustomNavigationRail].
  ///
  /// ** See code in examples/api/lib/material/navigation_rail/navigation_rail.extended_animation.0.dart **
  /// {@end-tool}
  static Animation<double> extendedAnimation(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ExtendedNavigationRailAnimation>()!
        .animation;
  }

  @override
  State<CustomNavigationRail> createState() => _CustomNavigationRailState();
}

class _CustomNavigationRailState extends State<CustomNavigationRail>
    with TickerProviderStateMixin {
  late List<AnimationController> _destinationControllers;
  late List<Animation<double>> _destinationAnimations;
  late AnimationController _extendedController;
  late CurvedAnimation _extendedAnimation;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  void didUpdateWidget(CustomNavigationRail oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.extended != oldWidget.extended) {
      if (widget.extended) {
        _extendedController.forward();
      } else {
        _extendedController.reverse();
      }
    }

    // No animated segue if the length of the items list changes.
    if (widget.destinations.length != oldWidget.destinations.length) {
      _resetState();
      return;
    }

    if (widget.selectedIndex != oldWidget.selectedIndex) {
      if (oldWidget.selectedIndex != null) {
        _destinationControllers[oldWidget.selectedIndex!].reverse();
      }
      if (widget.selectedIndex != null) {
        _destinationControllers[widget.selectedIndex!].forward();
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final NavigationRailThemeData navigationRailTheme =
        NavigationRailTheme.of(context);
    final NavigationRailThemeData defaults = Theme.of(context).useMaterial3
        ? _NavigationRailDefaultsM3(context)
        : _NavigationRailDefaultsM2(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    final Color backgroundColor = widget.backgroundColor ??
        navigationRailTheme.backgroundColor ??
        defaults.backgroundColor!;
    final double elevation = widget.elevation ??
        navigationRailTheme.elevation ??
        defaults.elevation!;

    final TextStyle unselectedLabelTextStyle =
        widget.unselectedLabelTextStyle ??
            navigationRailTheme.unselectedLabelTextStyle ??
            defaults.unselectedLabelTextStyle!;
    final TextStyle selectedLabelTextStyle = widget.selectedLabelTextStyle ??
        navigationRailTheme.selectedLabelTextStyle ??
        defaults.selectedLabelTextStyle!;
    final IconThemeData unselectedIconTheme = widget.unselectedIconTheme ??
        navigationRailTheme.unselectedIconTheme ??
        defaults.unselectedIconTheme!;
    final IconThemeData selectedIconTheme = widget.selectedIconTheme ??
        navigationRailTheme.selectedIconTheme ??
        defaults.selectedIconTheme!;
    final double groupAlignment = widget.groupAlignment ??
        navigationRailTheme.groupAlignment ??
        defaults.groupAlignment!;
    final NavigationRailLabelType labelType = widget.labelType ??
        navigationRailTheme.labelType ??
        defaults.labelType!;
    final bool useIndicator = widget.useIndicator ??
        navigationRailTheme.useIndicator ??
        defaults.useIndicator!;
    final Color? indicatorColor = widget.indicatorColor ??
        navigationRailTheme.indicatorColor ??
        defaults.indicatorColor;
    final ShapeBorder? indicatorShape = widget.indicatorShape ??
        navigationRailTheme.indicatorShape ??
        defaults.indicatorShape;
    final bool shapeIsRoundedRectangle =
        indicatorShape is RoundedRectangleBorder;

    // For backwards compatibility, in M2 the opacity of the unselected icons needs
    // to be set to the default if it isn't in the given theme. This can be removed
    // when Material 3 is the default.
    final IconThemeData effectiveUnselectedIconTheme =
        Theme.of(context).useMaterial3
            ? unselectedIconTheme
            : unselectedIconTheme.copyWith(
                opacity: unselectedIconTheme.opacity ??
                    defaults.unselectedIconTheme!.opacity,
              );

    final bool isRTLDirection = Directionality.of(context) == TextDirection.rtl;
    final bool isCustom = navigationRailTheme is CustomNavigationRailThemeData;
    final EdgeInsetsGeometry? railDestinationMargin =
        isCustom ? navigationRailTheme.margin : null;
    final EdgeInsetsGeometry? railDestinationPadding =
        isCustom ? navigationRailTheme.padding : null;

    return _ExtendedNavigationRailAnimation(
      animation: _extendedAnimation,
      child: Semantics(
        explicitChildNodes: true,
        child: Material(
          elevation: elevation,
          color: backgroundColor,
          child: SafeArea(
            right: isRTLDirection,
            left: !isRTLDirection,
            child: Column(
              children: <Widget>[
                _verticalSpacer,
                if (widget.leading != null) ...<Widget>[
                  widget.leading!,
                  _verticalSpacer,
                ],
                Expanded(
                  child: Align(
                    alignment: Alignment(0, groupAlignment),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        for (int i = 0; i < widget.destinations.length; i += 1)
                          Container(
                            margin: railDestinationMargin,
                            decoration: BoxDecoration(
                              borderRadius: shapeIsRoundedRectangle
                                  ? indicatorShape.borderRadius
                                  : null,
                              color: widget.selectedIndex == i && useIndicator
                                  ? indicatorColor ??
                                      Theme.of(context).colorScheme.secondary
                                  : Colors.transparent,
                            ),
                            child: RailDestination(
                              minWidth: widget.minWidth,
                              minExtendedWidth: widget.minExtendedWidth,
                              extendedTransitionAnimation: _extendedAnimation,
                              selected: widget.selectedIndex == i,
                              icon: widget.selectedIndex == i
                                  ? widget.destinations[i].selectedIcon
                                  : widget.destinations[i].icon,
                              label: widget.destinations[i].label,
                              destinationAnimation: _destinationAnimations[i],
                              labelType: labelType,
                              iconTheme: widget.selectedIndex == i
                                  ? selectedIconTheme
                                  : effectiveUnselectedIconTheme,
                              labelTextStyle: widget.selectedIndex == i
                                  ? selectedLabelTextStyle
                                  : unselectedLabelTextStyle,
                              padding: railDestinationPadding ??
                                  widget.destinations[i].padding ??
                                  const EdgeInsets.symmetric(
                                    horizontal: _horizontalDestinationPadding,
                                  ),
                              useIndicator: useIndicator,
                              indicatorColor:
                                  useIndicator ? indicatorColor : null,
                              indicatorShape:
                                  useIndicator ? indicatorShape : null,
                              onTap: () {
                                if (widget.onDestinationSelected != null) {
                                  widget.onDestinationSelected!(i);
                                }
                              },
                              indexLabel: localizations.tabLabel(
                                tabIndex: i + 1,
                                tabCount: widget.destinations.length,
                              ),
                              disabled: widget.destinations[i].disabled,
                              extended: widget.extended,
                            ),
                          ),
                        if (widget.trailing != null) widget.trailing!,
                      ],
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

  void _disposeControllers() {
    for (final AnimationController controller in _destinationControllers) {
      controller.dispose();
    }
    _extendedController.dispose();
    _extendedAnimation.dispose();
  }

  void _initControllers() {
    _destinationControllers = List<AnimationController>.generate(
        widget.destinations.length, (int index) {
      return AnimationController(
        duration: kThemeAnimationDuration,
        vsync: this,
      )..addListener(_rebuild);
    });
    _destinationAnimations = _destinationControllers
        .map((AnimationController controller) => controller.view)
        .toList();
    if (widget.selectedIndex != null) {
      _destinationControllers[widget.selectedIndex!].value = 1.0;
    }
    _extendedController = AnimationController(
      duration: kThemeAnimationDuration,
      vsync: this,
      value: widget.extended ? 1.0 : 0.0,
    );
    _extendedAnimation = CurvedAnimation(
      parent: _extendedController,
      curve: Curves.easeInOut,
    );
    _extendedController.addListener(() {
      _rebuild();
    });
  }

  void _resetState() {
    _disposeControllers();
    _initControllers();
  }

  void _rebuild() {
    setState(() {
      // Rebuilding when any of the controllers tick, i.e. when the items are
      // animating.
    });
  }
}
