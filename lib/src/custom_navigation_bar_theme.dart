// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import "dart:ui" show lerpDouble;

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";

// Examples can assume:
// late BuildContext context;

/// Defines default property values for descendant [NavigationBar]
/// widgets.
///
/// Descendant widgets obtain the current [NavigationBarThemeData] object
/// using `NavigationBarTheme.of(context)`. Instances of
/// [NavigationBarThemeData] can be customized with
/// [NavigationBarThemeData.copyWith].
///
/// Typically a [NavigationBarThemeData] is specified as part of the
/// overall [Theme] with [ThemeData.navigationBarTheme]. Alternatively, a
/// [NavigationBarTheme] inherited widget can be used to theme [NavigationBar]s
/// in a subtree of widgets.
///
/// All [NavigationBarThemeData] properties are `null` by default.
/// When null, the [NavigationBar] will provide its own defaults based on the
/// overall [Theme]'s textTheme and colorScheme. See the individual
/// [NavigationBar] properties for details.
///
/// See also:
///
///  * [ThemeData], which describes the overall theme information for the
///    application.
@immutable
class CustomNavigationBarThemeData
    with Diagnosticable
    implements NavigationBarThemeData {
  /// Creates a theme that can be used for [ThemeData.navigationBarTheme] and
  /// [NavigationBarTheme].
  const CustomNavigationBarThemeData({
    this.height,
    this.backgroundColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.indicatorColor,
    this.indicatorShape,
    this.labelTextStyle,
    this.iconTheme,
    this.labelBehavior,
    this.overlayColor,
    this.margin = EdgeInsets.zero,
    this.padding = EdgeInsets.zero,
    this.tooltipVerticalOffset = 42,
    this.labelPadding,
  });

  /// Overrides the default value of [NavigationBar.height].
  @override
  final double? height;

  /// Overrides the default value of [NavigationBar.backgroundColor].
  @override
  final Color? backgroundColor;

  /// Overrides the default value of [NavigationBar.elevation].
  @override
  final double? elevation;

  /// Overrides the default value of [NavigationBar.shadowColor].
  @override
  final Color? shadowColor;

  /// Overrides the default value of [NavigationBar.surfaceTintColor].
  @override
  final Color? surfaceTintColor;

  /// Overrides the default value of [NavigationBar]'s selection indicator.
  @override
  final Color? indicatorColor;

  /// Overrides the default shape of the [NavigationBar]'s selection indicator.
  @override
  final ShapeBorder? indicatorShape;

  /// The style to merge with the default text style for
  /// [NavigationDestination] labels.
  ///
  /// You can use this to specify a different style when the label is selected.
  @override
  final WidgetStateProperty<TextStyle?>? labelTextStyle;

  /// The theme to merge with the default icon theme for
  /// [NavigationDestination] icons.
  ///
  /// You can use this to specify a different icon theme when the icon is
  /// selected.
  @override
  final WidgetStateProperty<IconThemeData?>? iconTheme;

  /// Overrides the default value of [NavigationBar.labelBehavior].
  @override
  final NavigationDestinationLabelBehavior? labelBehavior;

  /// Overrides the default value of [NavigationBar.overlayColor].
  @override
  final WidgetStateProperty<Color?>? overlayColor;

  /// Applies a margin around navigation items. Defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry margin;

  /// Applies padding around navigation item content. Defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry padding;

  /// Defines the vertical offset of tooltip popovers. Defaults to 42.
  final double tooltipVerticalOffset;

  /// Applies padding around navigation item labels. Defaults to [EdgeInsets.zero].
  @override
  final EdgeInsetsGeometry? labelPadding;

  /// Creates a copy of this object with the given fields replaced with the
  /// new values.
  @override
  CustomNavigationBarThemeData copyWith({
    double? height,
    Color? backgroundColor,
    double? elevation,
    Color? shadowColor,
    Color? surfaceTintColor,
    Color? indicatorColor,
    ShapeBorder? indicatorShape,
    WidgetStateProperty<TextStyle?>? labelTextStyle,
    WidgetStateProperty<IconThemeData?>? iconTheme,
    NavigationDestinationLabelBehavior? labelBehavior,
    WidgetStateProperty<Color?>? overlayColor,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? tooltipVerticalOffset,
    EdgeInsetsGeometry? labelPadding,
  }) {
    return CustomNavigationBarThemeData(
      height: height ?? this.height,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      elevation: elevation ?? this.elevation,
      shadowColor: shadowColor ?? this.shadowColor,
      surfaceTintColor: surfaceTintColor ?? this.surfaceTintColor,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      indicatorShape: indicatorShape ?? this.indicatorShape,
      labelTextStyle: labelTextStyle ?? this.labelTextStyle,
      iconTheme: iconTheme ?? this.iconTheme,
      labelBehavior: labelBehavior ?? this.labelBehavior,
      overlayColor: overlayColor ?? this.overlayColor,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      tooltipVerticalOffset:
          tooltipVerticalOffset ?? this.tooltipVerticalOffset,
      labelPadding: labelPadding ?? this.labelPadding,
    );
  }

  /// Linearly interpolate between two navigation rail themes.
  ///
  /// If both arguments are null then null is returned.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static CustomNavigationBarThemeData? lerp(
    CustomNavigationBarThemeData? a,
    CustomNavigationBarThemeData? b,
    double t,
  ) {
    if (identical(a, b)) {
      return a;
    }
    return CustomNavigationBarThemeData(
      height: lerpDouble(a?.height, b?.height, t),
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      elevation: lerpDouble(a?.elevation, b?.elevation, t),
      shadowColor: Color.lerp(a?.shadowColor, b?.shadowColor, t),
      surfaceTintColor: Color.lerp(a?.surfaceTintColor, b?.surfaceTintColor, t),
      indicatorColor: Color.lerp(a?.indicatorColor, b?.indicatorColor, t),
      indicatorShape: ShapeBorder.lerp(a?.indicatorShape, b?.indicatorShape, t),
      labelTextStyle: WidgetStateProperty.lerp<TextStyle?>(
        a?.labelTextStyle,
        b?.labelTextStyle,
        t,
        TextStyle.lerp,
      ),
      iconTheme: WidgetStateProperty.lerp<IconThemeData?>(
        a?.iconTheme,
        b?.iconTheme,
        t,
        IconThemeData.lerp,
      ),
      labelBehavior: t < 0.5 ? a?.labelBehavior : b?.labelBehavior,
      overlayColor: WidgetStateProperty.lerp<Color?>(
        a?.overlayColor,
        b?.overlayColor,
        t,
        Color.lerp,
      ),
      margin:
          EdgeInsetsGeometry.lerp(a?.margin, b?.margin, t) ?? EdgeInsets.zero,
      padding:
          EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t) ?? EdgeInsets.zero,
      tooltipVerticalOffset:
          lerpDouble(a?.tooltipVerticalOffset, b?.tooltipVerticalOffset, t) ??
              42,
      labelPadding: EdgeInsetsGeometry.lerp(
        a?.labelPadding,
        b?.labelPadding,
        t,
      ),
    );
  }

  @override
  int get hashCode => Object.hash(
        height,
        backgroundColor,
        elevation,
        shadowColor,
        surfaceTintColor,
        indicatorColor,
        indicatorShape,
        labelTextStyle,
        iconTheme,
        labelBehavior,
        overlayColor,
        margin,
        padding,
        tooltipVerticalOffset,
        labelPadding,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is CustomNavigationBarThemeData &&
        other.height == height &&
        other.backgroundColor == backgroundColor &&
        other.elevation == elevation &&
        other.shadowColor == shadowColor &&
        other.surfaceTintColor == surfaceTintColor &&
        other.indicatorColor == indicatorColor &&
        other.indicatorShape == indicatorShape &&
        other.labelTextStyle == labelTextStyle &&
        other.iconTheme == iconTheme &&
        other.labelBehavior == labelBehavior &&
        other.overlayColor == overlayColor &&
        other.margin == margin &&
        other.padding == padding &&
        other.tooltipVerticalOffset == tooltipVerticalOffset &&
        other.labelPadding == labelPadding;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty("height", height, defaultValue: null));
    properties.add(
      ColorProperty("backgroundColor", backgroundColor, defaultValue: null),
    );
    properties.add(DoubleProperty("elevation", elevation, defaultValue: null));
    properties
        .add(ColorProperty("shadowColor", shadowColor, defaultValue: null));
    properties.add(
      ColorProperty(
        "surfaceTintColor",
        surfaceTintColor,
        defaultValue: null,
      ),
    );
    properties.add(
      ColorProperty("indicatorColor", indicatorColor, defaultValue: null),
    );
    properties.add(
      DiagnosticsProperty<ShapeBorder>(
        "indicatorShape",
        indicatorShape,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<WidgetStateProperty<TextStyle?>>(
        "labelTextStyle",
        labelTextStyle,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<WidgetStateProperty<IconThemeData?>>(
        "iconTheme",
        iconTheme,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<NavigationDestinationLabelBehavior>(
        "labelBehavior",
        labelBehavior,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<WidgetStateProperty<Color?>>(
        "overlayColor",
        overlayColor,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry?>(
        "margin",
        margin,
        defaultValue: EdgeInsets.zero,
      ),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry?>(
        "padding",
        padding,
        defaultValue: EdgeInsets.zero,
      ),
    );
    properties.add(
      DiagnosticsProperty<double?>(
        "tooltipVerticalOffset",
        tooltipVerticalOffset,
        defaultValue: 42,
      ),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry?>(
        "labelPadding",
        labelPadding,
        defaultValue: null,
      ),
    );
  }
}

/// An inherited widget that defines visual properties for [NavigationBar]s and
/// [NavigationDestination]s in this widget's subtree.
///
/// Values specified here are used for [NavigationBar] properties that are not
/// given an explicit non-null value.
///
/// See also:
///
///  * [ThemeData.navigationBarTheme], which describes the
///    [NavigationBarThemeData] in the overall theme for the application.
class CustomNavigationBarTheme extends InheritedTheme
    implements NavigationBarTheme {
  /// Creates a navigation rail theme that controls the
  /// [NavigationBarThemeData] properties for a [NavigationBar].
  const CustomNavigationBarTheme({
    required this.data,
    required super.child,
    super.key,
  });

  /// Specifies the background color, label text style, icon theme, and label
  /// type values for descendant [NavigationBar] widgets.
  @override
  final CustomNavigationBarThemeData data;

  /// The closest instance of this class that encloses the given context.
  ///
  /// If there is no enclosing [NavigationBarTheme] widget, then
  /// [ThemeData.navigationBarTheme] is used.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// NavigationBarThemeData theme = NavigationBarTheme.of(context);
  /// ```
  static NavigationBarThemeData of(BuildContext context) {
    final NavigationBarTheme? navigationBarTheme = context
            .dependOnInheritedWidgetOfExactType<CustomNavigationBarTheme>() ??
        context.dependOnInheritedWidgetOfExactType<NavigationBarTheme>();

    return navigationBarTheme?.data ?? Theme.of(context).navigationBarTheme;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return NavigationBarTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(NavigationBarTheme oldWidget) =>
      data != oldWidget.data;
}
