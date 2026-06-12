// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import "dart:ui" show lerpDouble;

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";

import "navigation_indicator_theme.dart";

// Examples can assume:
// late BuildContext context;

/// Defines default property values for descendant [NavigationRail]
/// widgets.
///
/// Descendant widgets obtain the current [NavigationRailThemeData] object
/// using `NavigationRailTheme.of(context)`. Instances of
/// [NavigationRailThemeData] can be customized with
/// [NavigationRailThemeData.copyWith].
///
/// Typically a [NavigationRailThemeData] is specified as part of the
/// overall [Theme] with [ThemeData.navigationRailTheme].
///
/// All [NavigationRailThemeData] properties are `null` by default.
/// When null, the [NavigationRail] will use the values from [ThemeData]
/// if they exist, otherwise it will provide its own defaults based on the
/// overall [Theme]'s textTheme and colorScheme. See the individual
/// [NavigationRail] properties for details.
///
/// See also:
///
///  * [ThemeData], which describes the overall theme information for the
///    application.
@immutable
class CustomNavigationRailThemeData
    with Diagnosticable
    implements NavigationRailThemeData {
  /// Creates a theme that can be used for [ThemeData.navigationRailTheme].
  const CustomNavigationRailThemeData({
    this.backgroundColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.border,
    this.unselectedLabelTextStyle,
    this.selectedLabelTextStyle,
    this.unselectedIconTheme,
    this.selectedIconTheme,
    this.groupAlignment,
    this.labelType,
    this.compactLabelType,
    this.expandedLabelType,
    this.useIndicator,
    this.indicatorColor,
    this.indicatorShape,
    this.indicatorStyle,
    this.minWidth,
    this.minExtendedWidth,
    this.extendedNavigationRailWidth,
    this.margin,
    this.padding,
  });

  /// Color to be used for the [NavigationRail]'s background.
  @override
  final Color? backgroundColor;

  /// The z-coordinate to be used for the [NavigationRail]'s elevation.
  @override
  final double? elevation;

  /// The color used for the rail's drop shadow.
  final Color? shadowColor;

  /// The color used as an overlay on the rail surface to indicate elevation.
  final Color? surfaceTintColor;

  /// Optional border around the outer rail surface.
  final BorderSide? border;

  /// The style to merge with the default text style for
  /// [NavigationRailDestination] labels, when the destination is not selected.
  @override
  final TextStyle? unselectedLabelTextStyle;

  /// The style to merge with the default text style for
  /// [NavigationRailDestination] labels, when the destination is selected.
  @override
  final TextStyle? selectedLabelTextStyle;

  /// The theme to merge with the default icon theme for
  /// [NavigationRailDestination] icons, when the destination is not selected.
  @override
  final IconThemeData? unselectedIconTheme;

  /// The theme to merge with the default icon theme for
  /// [NavigationRailDestination] icons, when the destination is selected.
  @override
  final IconThemeData? selectedIconTheme;

  /// The alignment for the [NavigationRailDestination]s as they are positioned
  /// within the [NavigationRail].
  @override
  final double? groupAlignment;

  /// The type that defines the layout and behavior of the labels in the
  /// [NavigationRail].
  @override
  final NavigationRailLabelType? labelType;

  /// Optional label behavior for compact rail breakpoints in AdaptiveScaffold.
  final NavigationRailLabelType? compactLabelType;

  /// Optional label behavior for expanded rail breakpoints in AdaptiveScaffold.
  final NavigationRailLabelType? expandedLabelType;

  /// Whether or not the selected [NavigationRailDestination] should include a
  /// [NavigationIndicator].
  @override
  final bool? useIndicator;

  /// Overrides the default value of [NavigationRail]'s selection indicator color,
  /// when [useIndicator] is true.
  @override
  final Color? indicatorColor;

  /// Overrides the default shape of the [NavigationRail]'s selection indicator.
  @override
  final ShapeBorder? indicatorShape;

  /// Optional indicator-style override scoped to the navigation rail.
  final NavigationIndicatorThemeData? indicatorStyle;

  /// Overrides the default value of [NavigationRail]'s minimum width when it
  /// is not extended.
  @override
  final double? minWidth;

  /// Overrides the default value of [NavigationRail]'s minimum width when it
  /// is extended.
  @override
  final double? minExtendedWidth;

  /// Optional width for extended navigation rails used by AdaptiveScaffold.
  final double? extendedNavigationRailWidth;

  /// Applies a margin around navigation items.
  final EdgeInsetsGeometry? margin;

  /// Applies padding around navigation item content.
  final EdgeInsetsGeometry? padding;

  /// Converts this custom rail theme data into framework
  /// [NavigationRailThemeData].
  NavigationRailThemeData toNavigationRailThemeData() {
    return NavigationRailThemeData(
      backgroundColor: backgroundColor,
      elevation: elevation,
      unselectedLabelTextStyle: unselectedLabelTextStyle,
      selectedLabelTextStyle: selectedLabelTextStyle,
      unselectedIconTheme: unselectedIconTheme,
      selectedIconTheme: selectedIconTheme,
      groupAlignment: groupAlignment,
      labelType: labelType,
      useIndicator: useIndicator,
      indicatorColor: indicatorStyle?.color ?? indicatorColor,
      indicatorShape: indicatorStyle?.shape ?? indicatorShape,
      minWidth: minWidth,
      minExtendedWidth: minExtendedWidth,
    );
  }

  /// Creates custom rail theme data from framework [NavigationRailThemeData].
  factory CustomNavigationRailThemeData.fromNavigationRailThemeData(
    NavigationRailThemeData data,
  ) {
    return CustomNavigationRailThemeData(
      backgroundColor: data.backgroundColor,
      elevation: data.elevation,
      unselectedLabelTextStyle: data.unselectedLabelTextStyle,
      selectedLabelTextStyle: data.selectedLabelTextStyle,
      unselectedIconTheme: data.unselectedIconTheme,
      selectedIconTheme: data.selectedIconTheme,
      groupAlignment: data.groupAlignment,
      labelType: data.labelType,
      useIndicator: data.useIndicator,
      indicatorColor: data.indicatorColor,
      indicatorShape: data.indicatorShape,
      minWidth: data.minWidth,
      minExtendedWidth: data.minExtendedWidth,
    );
  }

  /// Creates a copy of this object with the given fields replaced with the
  /// new values.
  @override
  CustomNavigationRailThemeData copyWith({
    Color? backgroundColor,
    double? elevation,
    Color? shadowColor,
    Color? surfaceTintColor,
    BorderSide? border,
    TextStyle? unselectedLabelTextStyle,
    TextStyle? selectedLabelTextStyle,
    IconThemeData? unselectedIconTheme,
    IconThemeData? selectedIconTheme,
    double? groupAlignment,
    NavigationRailLabelType? labelType,
    NavigationRailLabelType? compactLabelType,
    NavigationRailLabelType? expandedLabelType,
    bool? useIndicator,
    Color? indicatorColor,
    ShapeBorder? indicatorShape,
    NavigationIndicatorThemeData? indicatorStyle,
    double? minWidth,
    double? minExtendedWidth,
    double? extendedNavigationRailWidth,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return CustomNavigationRailThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      elevation: elevation ?? this.elevation,
      shadowColor: shadowColor ?? this.shadowColor,
      surfaceTintColor: surfaceTintColor ?? this.surfaceTintColor,
      border: border ?? this.border,
      unselectedLabelTextStyle:
          unselectedLabelTextStyle ?? this.unselectedLabelTextStyle,
      selectedLabelTextStyle:
          selectedLabelTextStyle ?? this.selectedLabelTextStyle,
      unselectedIconTheme: unselectedIconTheme ?? this.unselectedIconTheme,
      selectedIconTheme: selectedIconTheme ?? this.selectedIconTheme,
      groupAlignment: groupAlignment ?? this.groupAlignment,
      labelType: labelType ?? this.labelType,
      compactLabelType: compactLabelType ?? this.compactLabelType,
      expandedLabelType: expandedLabelType ?? this.expandedLabelType,
      useIndicator: useIndicator ?? this.useIndicator,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      indicatorShape: indicatorShape ?? this.indicatorShape,
      indicatorStyle: indicatorStyle ?? this.indicatorStyle,
      minWidth: minWidth ?? this.minWidth,
      minExtendedWidth: minExtendedWidth ?? this.minExtendedWidth,
      extendedNavigationRailWidth:
          extendedNavigationRailWidth ?? this.extendedNavigationRailWidth,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
    );
  }

  /// Linearly interpolate between two navigation rail themes.
  ///
  /// If both arguments are null then null is returned.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static CustomNavigationRailThemeData? lerp(
    CustomNavigationRailThemeData? a,
    CustomNavigationRailThemeData? b,
    double t,
  ) {
    if (identical(a, b)) {
      return a;
    }
    return CustomNavigationRailThemeData(
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      elevation: lerpDouble(a?.elevation, b?.elevation, t),
      shadowColor: Color.lerp(a?.shadowColor, b?.shadowColor, t),
      surfaceTintColor: Color.lerp(a?.surfaceTintColor, b?.surfaceTintColor, t),
      border: a?.border == null && b?.border == null
          ? null
          : BorderSide.lerp(
              a?.border ?? BorderSide.none,
              b?.border ?? BorderSide.none,
              t,
            ),
      unselectedLabelTextStyle: TextStyle.lerp(
        a?.unselectedLabelTextStyle,
        b?.unselectedLabelTextStyle,
        t,
      ),
      selectedLabelTextStyle: TextStyle.lerp(
        a?.selectedLabelTextStyle,
        b?.selectedLabelTextStyle,
        t,
      ),
      unselectedIconTheme:
          a?.unselectedIconTheme == null && b?.unselectedIconTheme == null
              ? null
              : IconThemeData.lerp(
                  a?.unselectedIconTheme,
                  b?.unselectedIconTheme,
                  t,
                ),
      selectedIconTheme: a?.selectedIconTheme == null &&
              b?.selectedIconTheme == null
          ? null
          : IconThemeData.lerp(a?.selectedIconTheme, b?.selectedIconTheme, t),
      groupAlignment: lerpDouble(a?.groupAlignment, b?.groupAlignment, t),
      labelType: t < 0.5 ? a?.labelType : b?.labelType,
      compactLabelType: t < 0.5 ? a?.compactLabelType : b?.compactLabelType,
      expandedLabelType: t < 0.5 ? a?.expandedLabelType : b?.expandedLabelType,
      useIndicator: t < 0.5 ? a?.useIndicator : b?.useIndicator,
      indicatorColor: Color.lerp(a?.indicatorColor, b?.indicatorColor, t),
      indicatorShape: ShapeBorder.lerp(a?.indicatorShape, b?.indicatorShape, t),
      indicatorStyle: NavigationIndicatorThemeData.lerp(
        a?.indicatorStyle,
        b?.indicatorStyle,
        t,
      ),
      minWidth: lerpDouble(a?.minWidth, b?.minWidth, t),
      minExtendedWidth: lerpDouble(a?.minExtendedWidth, b?.minExtendedWidth, t),
      extendedNavigationRailWidth: lerpDouble(
        a?.extendedNavigationRailWidth,
        b?.extendedNavigationRailWidth,
        t,
      ),
      margin: EdgeInsetsGeometry.lerp(a?.margin, b?.margin, t),
      padding: EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t),
    );
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
        backgroundColor,
        elevation,
        shadowColor,
        surfaceTintColor,
        border,
        unselectedLabelTextStyle,
        selectedLabelTextStyle,
        unselectedIconTheme,
        selectedIconTheme,
        groupAlignment,
        labelType,
        compactLabelType,
        expandedLabelType,
        useIndicator,
        indicatorColor,
        indicatorShape,
        indicatorStyle,
        minWidth,
        minExtendedWidth,
        extendedNavigationRailWidth,
        margin,
        padding,
      ]);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is CustomNavigationRailThemeData &&
        other.backgroundColor == backgroundColor &&
        other.elevation == elevation &&
        other.shadowColor == shadowColor &&
        other.surfaceTintColor == surfaceTintColor &&
        other.border == border &&
        other.unselectedLabelTextStyle == unselectedLabelTextStyle &&
        other.selectedLabelTextStyle == selectedLabelTextStyle &&
        other.unselectedIconTheme == unselectedIconTheme &&
        other.selectedIconTheme == selectedIconTheme &&
        other.groupAlignment == groupAlignment &&
        other.labelType == labelType &&
        other.compactLabelType == compactLabelType &&
        other.expandedLabelType == expandedLabelType &&
        other.useIndicator == useIndicator &&
        other.indicatorColor == indicatorColor &&
        other.indicatorShape == indicatorShape &&
        other.indicatorStyle == indicatorStyle &&
        other.minWidth == minWidth &&
        other.minExtendedWidth == minExtendedWidth &&
        other.extendedNavigationRailWidth == extendedNavigationRailWidth &&
        other.margin == margin &&
        other.padding == padding;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    const CustomNavigationRailThemeData defaultData =
        CustomNavigationRailThemeData();

    properties.add(
      ColorProperty(
        "backgroundColor",
        backgroundColor,
        defaultValue: defaultData.backgroundColor,
      ),
    );
    properties.add(
      DoubleProperty(
        "elevation",
        elevation,
        defaultValue: defaultData.elevation,
      ),
    );
    properties.add(
      ColorProperty(
        "shadowColor",
        shadowColor,
        defaultValue: defaultData.shadowColor,
      ),
    );
    properties.add(
      ColorProperty(
        "surfaceTintColor",
        surfaceTintColor,
        defaultValue: defaultData.surfaceTintColor,
      ),
    );
    properties.add(
      DiagnosticsProperty<BorderSide?>(
        "border",
        border,
        defaultValue: defaultData.border,
      ),
    );
    properties.add(
      DiagnosticsProperty<TextStyle>(
        "unselectedLabelTextStyle",
        unselectedLabelTextStyle,
        defaultValue: defaultData.unselectedLabelTextStyle,
      ),
    );
    properties.add(
      DiagnosticsProperty<TextStyle>(
        "selectedLabelTextStyle",
        selectedLabelTextStyle,
        defaultValue: defaultData.selectedLabelTextStyle,
      ),
    );
    properties.add(
      DiagnosticsProperty<IconThemeData>(
        "unselectedIconTheme",
        unselectedIconTheme,
        defaultValue: defaultData.unselectedIconTheme,
      ),
    );
    properties.add(
      DiagnosticsProperty<IconThemeData>(
        "selectedIconTheme",
        selectedIconTheme,
        defaultValue: defaultData.selectedIconTheme,
      ),
    );
    properties.add(
      DoubleProperty(
        "groupAlignment",
        groupAlignment,
        defaultValue: defaultData.groupAlignment,
      ),
    );
    properties.add(
      DiagnosticsProperty<NavigationRailLabelType>(
        "labelType",
        labelType,
        defaultValue: defaultData.labelType,
      ),
    );
    properties.add(
      DiagnosticsProperty<NavigationRailLabelType?>(
        "compactLabelType",
        compactLabelType,
        defaultValue: defaultData.compactLabelType,
      ),
    );
    properties.add(
      DiagnosticsProperty<NavigationRailLabelType?>(
        "expandedLabelType",
        expandedLabelType,
        defaultValue: defaultData.expandedLabelType,
      ),
    );
    properties.add(
      DiagnosticsProperty<bool>(
        "useIndicator",
        useIndicator,
        defaultValue: defaultData.useIndicator,
      ),
    );
    properties.add(
      ColorProperty(
        "indicatorColor",
        indicatorColor,
        defaultValue: defaultData.indicatorColor,
      ),
    );
    properties.add(
      DiagnosticsProperty<ShapeBorder>(
        "indicatorShape",
        indicatorShape,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<NavigationIndicatorThemeData?>(
        "indicatorStyle",
        indicatorStyle,
        defaultValue: defaultData.indicatorStyle,
      ),
    );
    properties.add(
      DoubleProperty(
        "minWidth",
        minWidth,
        defaultValue: defaultData.minWidth,
      ),
    );
    properties.add(
      DoubleProperty(
        "minExtendedWidth",
        minExtendedWidth,
        defaultValue: defaultData.minExtendedWidth,
      ),
    );
    properties.add(
      DoubleProperty(
        "extendedNavigationRailWidth",
        extendedNavigationRailWidth,
        defaultValue: defaultData.extendedNavigationRailWidth,
      ),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry?>(
        "margin",
        margin,
        defaultValue: defaultData.margin,
      ),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry?>(
        "padding",
        padding,
        defaultValue: defaultData.padding,
      ),
    );
  }
}

/// An inherited widget that defines visual properties for [NavigationRail]s and
/// [NavigationRailDestination]s in this widget's subtree.
///
/// Values specified here are used for [NavigationRail] properties that are not
/// given an explicit non-null value.
class CustomNavigationRailTheme extends InheritedTheme
    implements NavigationRailTheme {
  /// Creates a navigation rail theme that controls the
  /// [NavigationRailThemeData] properties for a [NavigationRail].
  const CustomNavigationRailTheme({
    required this.data,
    required super.child,
    super.key,
  });

  /// Specifies the background color, elevation, label text style, icon theme,
  /// group alignment, and label type and border values for descendant
  /// [NavigationRail] widgets.
  @override
  final CustomNavigationRailThemeData data;

  /// The closest instance of this class that encloses the given context.
  ///
  /// If there is no enclosing [NavigationRailTheme] widget, then
  /// [ThemeData.navigationRailTheme] is used.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// NavigationRailThemeData theme = NavigationRailTheme.of(context);
  /// ```
  static NavigationRailThemeData of(BuildContext context) {
    final NavigationRailTheme? navigationRailTheme = context
            .dependOnInheritedWidgetOfExactType<CustomNavigationRailTheme>() ??
        context.dependOnInheritedWidgetOfExactType<NavigationRailTheme>();

    return navigationRailTheme?.data ?? Theme.of(context).navigationRailTheme;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return CustomNavigationRailTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(CustomNavigationRailTheme oldWidget) =>
      data != oldWidget.data;
}
