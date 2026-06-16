// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import "dart:ui" show lerpDouble;

import "package:flutter/foundation.dart";
import "package:flutter/material.dart" as m
    show NavigationRailThemeData, NavigationRailTheme;
import "package:flutter/rendering.dart";

import "../material.dart";

typedef CustomNavigationRailThemeData = NavigationRailThemeData;
typedef CustomNavigationRailTheme = NavigationRailTheme;

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
class NavigationRailThemeData
    with Diagnosticable
    implements m.NavigationRailThemeData {
  /// Creates a theme that can be used for [ThemeData.navigationRailTheme].
  const NavigationRailThemeData({
    this.backgroundColor,
    this.elevation,
    this.unselectedLabelTextStyle,
    this.selectedLabelTextStyle,
    this.unselectedIconTheme,
    this.selectedIconTheme,
    this.groupAlignment,
    this.labelType,
    this.useIndicator,
    this.indicatorColor,
    this.indicatorShape,
    this.showLabelsWhenCollapsed,
    this.minWidth,
    this.minExtendedWidth,
    this.margin,
    this.padding,
  });

  /// Color to be used for the [NavigationRail]'s background.
  @override
  final Color? backgroundColor;

  /// The z-coordinate to be used for the [NavigationRail]'s elevation.
  @override
  final double? elevation;

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

  /// Whether labels are shown while the rail is collapsed and [labelType] is
  /// [NavigationRailLabelType.none].
  final bool? showLabelsWhenCollapsed;

  /// Overrides the default value of [NavigationRail]'s minimum width when it
  /// is not extended.
  @override
  final double? minWidth;

  /// Overrides the default value of [NavigationRail]'s minimum width when it
  /// is extended.
  @override
  final double? minExtendedWidth;

  /// Applies a margin around navigation items. Defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry? margin;

  /// Applies padding around navigation item content. Defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry? padding;

  /// Creates a copy of this object with the given fields replaced with the
  /// new values.
  @override
  NavigationRailThemeData copyWith({
    Color? backgroundColor,
    double? elevation,
    TextStyle? unselectedLabelTextStyle,
    TextStyle? selectedLabelTextStyle,
    IconThemeData? unselectedIconTheme,
    IconThemeData? selectedIconTheme,
    double? groupAlignment,
    NavigationRailLabelType? labelType,
    bool? useIndicator,
    Color? indicatorColor,
    ShapeBorder? indicatorShape,
    bool? showLabelsWhenCollapsed,
    double? minWidth,
    double? minExtendedWidth,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return NavigationRailThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      elevation: elevation ?? this.elevation,
      unselectedLabelTextStyle:
          unselectedLabelTextStyle ?? this.unselectedLabelTextStyle,
      selectedLabelTextStyle:
          selectedLabelTextStyle ?? this.selectedLabelTextStyle,
      unselectedIconTheme: unselectedIconTheme ?? this.unselectedIconTheme,
      selectedIconTheme: selectedIconTheme ?? this.selectedIconTheme,
      groupAlignment: groupAlignment ?? this.groupAlignment,
      labelType: labelType ?? this.labelType,
      useIndicator: useIndicator ?? this.useIndicator,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      indicatorShape: indicatorShape ?? this.indicatorShape,
      showLabelsWhenCollapsed:
          showLabelsWhenCollapsed ?? this.showLabelsWhenCollapsed,
      minWidth: minWidth ?? this.minWidth,
      minExtendedWidth: minExtendedWidth ?? this.minExtendedWidth,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
    );
  }

  /// Linearly interpolate between two navigation rail themes.
  ///
  /// If both arguments are null then null is returned.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static NavigationRailThemeData? lerp(
    NavigationRailThemeData? a,
    NavigationRailThemeData? b,
    double t,
  ) {
    if (identical(a, b)) {
      return a;
    }
    return NavigationRailThemeData(
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      elevation: lerpDouble(a?.elevation, b?.elevation, t),
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
      useIndicator: t < 0.5 ? a?.useIndicator : b?.useIndicator,
      indicatorColor: Color.lerp(a?.indicatorColor, b?.indicatorColor, t),
      indicatorShape: ShapeBorder.lerp(a?.indicatorShape, b?.indicatorShape, t),
      showLabelsWhenCollapsed:
          t < 0.5 ? a?.showLabelsWhenCollapsed : b?.showLabelsWhenCollapsed,
      minWidth: lerpDouble(a?.minWidth, b?.minWidth, t),
      minExtendedWidth: lerpDouble(a?.minExtendedWidth, b?.minExtendedWidth, t),
      margin:
          EdgeInsetsGeometry.lerp(a?.margin, b?.margin, t) ?? EdgeInsets.zero,
      padding:
          EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t) ?? EdgeInsets.zero,
    );
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        elevation,
        unselectedLabelTextStyle,
        selectedLabelTextStyle,
        unselectedIconTheme,
        selectedIconTheme,
        groupAlignment,
        labelType,
        useIndicator,
        indicatorColor,
        indicatorShape,
        showLabelsWhenCollapsed,
        minWidth,
        minExtendedWidth,
        margin,
        padding,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is NavigationRailThemeData &&
        other.backgroundColor == backgroundColor &&
        other.elevation == elevation &&
        other.unselectedLabelTextStyle == unselectedLabelTextStyle &&
        other.selectedLabelTextStyle == selectedLabelTextStyle &&
        other.unselectedIconTheme == unselectedIconTheme &&
        other.selectedIconTheme == selectedIconTheme &&
        other.groupAlignment == groupAlignment &&
        other.labelType == labelType &&
        other.useIndicator == useIndicator &&
        other.indicatorColor == indicatorColor &&
        other.indicatorShape == indicatorShape &&
        other.showLabelsWhenCollapsed == showLabelsWhenCollapsed &&
        other.minWidth == minWidth &&
        other.minExtendedWidth == minExtendedWidth &&
        other.margin == margin &&
        other.padding == padding;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    const NavigationRailThemeData defaultData = NavigationRailThemeData();

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
      DiagnosticsProperty<bool>(
        "showLabelsWhenCollapsed",
        showLabelsWhenCollapsed,
        defaultValue: defaultData.showLabelsWhenCollapsed,
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
  }

  factory NavigationRailThemeData.fromMaterial(
    m.NavigationRailThemeData material,
  ) {
    return NavigationRailThemeData(
      backgroundColor: material.backgroundColor,
      elevation: material.elevation,
      unselectedLabelTextStyle: material.unselectedLabelTextStyle,
      selectedLabelTextStyle: material.selectedLabelTextStyle,
      unselectedIconTheme: material.unselectedIconTheme,
      selectedIconTheme: material.selectedIconTheme,
      groupAlignment: material.groupAlignment,
      labelType: material.labelType,
      useIndicator: material.useIndicator,
      indicatorColor: material.indicatorColor,
      indicatorShape: material.indicatorShape,
      minWidth: material.minWidth,
      minExtendedWidth: material.minExtendedWidth,
    );
  }
}

/// An inherited widget that defines visual properties for [NavigationRail]s and
/// [NavigationRailDestination]s in this widget's subtree.
///
/// Values specified here are used for [NavigationRail] properties that are not
/// given an explicit non-null value.
class NavigationRailTheme extends InheritedTheme
    implements m.NavigationRailTheme {
  /// Creates a navigation rail theme that controls the
  /// [NavigationRailThemeData] properties for a [NavigationRail].
  const NavigationRailTheme({
    required this.data,
    required super.child,
    super.key,
  });

  /// Specifies the background color, elevation, label text style, icon theme,
  /// group alignment, and label type and border values for descendant
  /// [NavigationRail] widgets.
  @override
  final NavigationRailThemeData data;

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
    // The user is using NavigationRailTheme from this package
    final NavigationRailTheme? navigationRailTheme =
        context.dependOnInheritedWidgetOfExactType<NavigationRailTheme>();

    if (navigationRailTheme != null) {
      return navigationRailTheme.data;
    }

    // The user is using a theme extension to provide NavigationRailThemeData
    // from his package

    final NavigationRailThemeData? themeExtension =
        Theme.of(context).extension<NavigationRailThemeData>();

    if (themeExtension != null) {
      return themeExtension;
    }

    // The user is using Flutter's Material NavigationRailThemeData, so we
    // convert it to our own NavigationRailThemeData
    final m.NavigationRailThemeData materialNavigationRailTheme =
        m.NavigationRailTheme.of(context);

    return NavigationRailThemeData.fromMaterial(materialNavigationRailTheme);
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return NavigationRailTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(NavigationRailTheme oldWidget) =>
      data != oldWidget.data;
}

// Hand coded defaults based on Material Design 2.
class NavigationRailDefaultsM2 extends NavigationRailThemeData {
  NavigationRailDefaultsM2(BuildContext context)
      : _theme = Theme.of(context),
        _colors = Theme.of(context).colorScheme,
        super(
          elevation: 0,
          groupAlignment: -1,
          labelType: NavigationRailLabelType.none,
          useIndicator: false,
          minWidth: 72.0,
          minExtendedWidth: 256,
        );

  final ThemeData _theme;
  final ColorScheme _colors;

  @override
  Color? get backgroundColor => _colors.surface;

  @override
  TextStyle? get unselectedLabelTextStyle {
    return _theme.textTheme.bodyLarge!
        .copyWith(color: _colors.onSurface.withValues(alpha: 0.64));
  }

  @override
  TextStyle? get selectedLabelTextStyle {
    return _theme.textTheme.bodyLarge!.copyWith(color: _colors.primary);
  }

  @override
  IconThemeData? get unselectedIconTheme {
    return IconThemeData(
      size: 24.0,
      color: _colors.onSurface,
      opacity: 0.64,
    );
  }

  @override
  IconThemeData? get selectedIconTheme {
    return IconThemeData(
      size: 24.0,
      color: _colors.primary,
      opacity: 1.0,
    );
  }
}

// BEGIN GENERATED TOKEN PROPERTIES - NavigationRail

// Do not edit by hand. The code between the "BEGIN GENERATED" and
// "END GENERATED" comments are generated from data in the Material
// Design token database by the script:
//   dev/tools/gen_defaults/bin/gen_defaults.dart.

class NavigationRailDefaultsM3 extends NavigationRailThemeData {
  NavigationRailDefaultsM3(this.context)
      : super(
          elevation: 0.0,
          groupAlignment: -1,
          labelType: NavigationRailLabelType.none,
          useIndicator: true,
          minWidth: 80.0,
          minExtendedWidth: 256,
        );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => _colors.surface;

  @override
  TextStyle? get unselectedLabelTextStyle {
    return _textTheme.labelMedium!.copyWith(color: _colors.onSurface);
  }

  @override
  TextStyle? get selectedLabelTextStyle {
    return _textTheme.labelMedium!.copyWith(color: _colors.onSurface);
  }

  @override
  IconThemeData? get unselectedIconTheme {
    return IconThemeData(
      size: 24.0,
      color: _colors.onSurfaceVariant,
    );
  }

  @override
  IconThemeData? get selectedIconTheme {
    return IconThemeData(
      size: 24.0,
      color: _colors.onSecondaryContainer,
    );
  }

  @override
  Color? get indicatorColor => _colors.secondaryContainer;

  @override
  ShapeBorder? get indicatorShape => const StadiumBorder();
}

// END GENERATED TOKEN PROPERTIES - NavigationRail
