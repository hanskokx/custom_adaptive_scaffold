// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import "dart:ui" show Offset, lerpDouble;

import "package:flutter/foundation.dart";
import "package:flutter/material.dart" as m
    show NavigationRailThemeData, NavigationRailTheme;
import "package:flutter/rendering.dart";

import "material.dart";
import "src/navigation_rail/theme_defaults.dart";

/// A typedef alias for [NavigationRailThemeData].
///
/// Use this name when you need to import both this package and
/// `package:flutter/material.dart` without hiding Flutter's
/// `NavigationRailThemeData`.
typedef CustomNavigationRailThemeData = NavigationRailThemeData;

/// A typedef alias for [NavigationRailTheme].
///
/// Use this name when you need to import both this package and
/// `package:flutter/material.dart` without hiding Flutter's
/// `NavigationRailTheme`.
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
    this.groupAlignment,
    this.indicatorColor,
    this.indicatorShape,
    this.iconTheme,
    this.labelType,
    this.margin,
    this.minExtendedWidth,
    this.minWidth,
    this.destinationIndicatorShape,
    this.destinationOverlayColor,
    this.padding,
    this.selectedIconTheme,
    this.selectedLabelTextStyle,
    this.showLabelsWhenCollapsed,
    this.tooltipOffset,
    this.tooltipTrigger,
    this.tooltipTriggerWhenLabelHidden,
    this.tooltipTriggerWhenLabelVisible,
    this.unselectedIconTheme,
    this.unselectedLabelTextStyle,
    this.useIndicator,
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
  // TODO(v6.0.0): Remove to deprecate M2.
  @Deprecated(
    "Material 2 is deprecated in Flutter and will be removed in v6.0.0 of this package. "
    "Migrate to Material 3 by relying on the default M3 behavior.",
  )
  final TextStyle? unselectedLabelTextStyle;

  /// The style to merge with the default text style for
  /// [NavigationRailDestination] labels, when the destination is selected.
  @override
  // TODO(v6.0.0): Remove to deprecate M2.
  @Deprecated(
    "Material 2 is deprecated in Flutter and will be removed in v6.0.0 of this package. "
    "Migrate to Material 3 by relying on the default M3 behavior.",
  )
  final TextStyle? selectedLabelTextStyle;

  /// The theme to merge with the default icon theme for
  /// [NavigationRailDestination] icons, when the destination is not selected.
  @override
  // TODO(v6.0.0): Remove to deprecate M2.
  @Deprecated(
    "Material 2 is deprecated in Flutter and will be removed in v6.0.0 of this package. "
    "Migrate to Material 3 by relying on the default M3 behavior.",
  )
  final IconThemeData? unselectedIconTheme;

  /// The theme to merge with the default icon theme for
  /// [NavigationRailDestination] icons, when the destination is selected.
  @override
  // TODO(v6.0.0): Remove to deprecate M2.
  @Deprecated(
    "Material 2 is deprecated in Flutter and will be removed in v6.0.0 of this package. "
    "Migrate to Material 3 by relying on the default M3 behavior.",
  )
  final IconThemeData? selectedIconTheme;

  /// The theme to merge with the default icon theme for
  /// [NavigationRailDestination] icons.
  final WidgetStateProperty<IconThemeData?>? iconTheme;

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
  // TODO(v6.0.0): Remove to deprecate M2.
  @Deprecated(
    "Material 3 enforces the use of the selection indicator. To customize its "
    "appearance, use [indicatorColor] and [indicatorShape] instead of "
    "disabling it entirely. "
    "Material 2 is deprecated in Flutter and will be removed in v6.0.0 of this package. ",
  )
  final bool? useIndicator;

  /// Overrides the default value of [NavigationRail]'s selection indicator color,
  /// when [useIndicator] is true.
  @override
  final Color? indicatorColor;

  /// Overrides the default shape of the [NavigationRail]'s selection indicator.
  @override
  final ShapeBorder? indicatorShape;

  // TODO(v6.0.0): Update comment when deprecating M2.
  /// Overlay colors for the full navigation item container by widget state.
  ///
  /// This has no effect when [ThemeData.useMaterial3] is false.
  final WidgetStateProperty<Color?>? destinationOverlayColor;

  /// Shape of the full navigation item container ink well.
  ///
  /// Defaults to [StadiumBorder] at resolution sites when this is null.
  final ShapeBorder? destinationIndicatorShape;

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

  /// Applies a margin around each navigation item in the rail.
  ///
  /// This creates space between adjacent destination items and between items
  /// and the rail edges. Defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry? margin;

  /// Applies padding inside each navigation item's content area.
  ///
  /// This creates space between the item boundary and the icon/label.
  /// Defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry? padding;

  /// Defines the x/y offset of tooltip popovers relative to the default
  /// anchor position.
  ///
  /// If null, the tooltip renders at its default position.
  final Offset? tooltipOffset;

  /// Controls which gesture triggers the tooltip popover.
  ///
  /// If null, Flutter's platform default is used (long press on mobile,
  /// long press and hover on desktop).
  ///
  /// For navigation destinations in this package, [TooltipTriggerMode.tap]
  /// is mapped to a secondary tap (such as right click) so the primary tap
  /// can continue to activate navigation.
  final TooltipTriggerMode? tooltipTrigger;

  /// Overrides [tooltipTrigger] specifically when the destination label is
  /// currently visible.
  ///
  /// When non-null, takes precedence over [tooltipTrigger] for the
  /// label-visible state.
  final TooltipTriggerMode? tooltipTriggerWhenLabelVisible;

  /// Overrides [tooltipTrigger] specifically when the destination label is
  /// currently hidden (e.g., when [labelType] is
  /// [NavigationRailLabelType.none] and [showLabelsWhenCollapsed] is false).
  ///
  /// When non-null, takes precedence over [tooltipTrigger] for the
  /// label-hidden state.
  final TooltipTriggerMode? tooltipTriggerWhenLabelHidden;

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
    WidgetStateProperty<Color?>? destinationOverlayColor,
    ShapeBorder? destinationIndicatorShape,
    bool? showLabelsWhenCollapsed,
    double? minWidth,
    double? minExtendedWidth,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Offset? tooltipOffset,
    TooltipTriggerMode? tooltipTrigger,
    TooltipTriggerMode? tooltipTriggerWhenLabelVisible,
    TooltipTriggerMode? tooltipTriggerWhenLabelHidden,
    WidgetStateProperty<IconThemeData?>? iconTheme,
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
      destinationOverlayColor:
          destinationOverlayColor ?? this.destinationOverlayColor,
      destinationIndicatorShape:
          destinationIndicatorShape ?? this.destinationIndicatorShape,
      showLabelsWhenCollapsed:
          showLabelsWhenCollapsed ?? this.showLabelsWhenCollapsed,
      minWidth: minWidth ?? this.minWidth,
      minExtendedWidth: minExtendedWidth ?? this.minExtendedWidth,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      tooltipOffset: tooltipOffset ?? this.tooltipOffset,
      tooltipTrigger: tooltipTrigger ?? this.tooltipTrigger,
      tooltipTriggerWhenLabelVisible:
          tooltipTriggerWhenLabelVisible ?? this.tooltipTriggerWhenLabelVisible,
      tooltipTriggerWhenLabelHidden:
          tooltipTriggerWhenLabelHidden ?? this.tooltipTriggerWhenLabelHidden,
      iconTheme: iconTheme ?? this.iconTheme,
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
      destinationOverlayColor: WidgetStateProperty.lerp<Color?>(
        a?.destinationOverlayColor,
        b?.destinationOverlayColor,
        t,
        Color.lerp,
      ),
      destinationIndicatorShape: ShapeBorder.lerp(
        a?.destinationIndicatorShape,
        b?.destinationIndicatorShape,
        t,
      ),
      showLabelsWhenCollapsed:
          t < 0.5 ? a?.showLabelsWhenCollapsed : b?.showLabelsWhenCollapsed,
      minWidth: lerpDouble(a?.minWidth, b?.minWidth, t),
      minExtendedWidth: lerpDouble(a?.minExtendedWidth, b?.minExtendedWidth, t),
      margin: EdgeInsetsGeometry.lerp(a?.margin, b?.margin, t),
      padding: EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t),
      tooltipOffset: Offset.lerp(a?.tooltipOffset, b?.tooltipOffset, t),
      tooltipTrigger: t < 0.5 ? a?.tooltipTrigger : b?.tooltipTrigger,
      tooltipTriggerWhenLabelVisible: t < 0.5
          ? a?.tooltipTriggerWhenLabelVisible
          : b?.tooltipTriggerWhenLabelVisible,
      tooltipTriggerWhenLabelHidden: t < 0.5
          ? a?.tooltipTriggerWhenLabelHidden
          : b?.tooltipTriggerWhenLabelHidden,
      iconTheme: WidgetStateProperty.lerp<IconThemeData?>(
        a?.iconTheme,
        b?.iconTheme,
        t,
        IconThemeData.lerp,
      ),
    );
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
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
        destinationOverlayColor,
        destinationIndicatorShape,
        showLabelsWhenCollapsed,
        minWidth,
        minExtendedWidth,
        margin,
        padding,
        tooltipOffset,
        tooltipTrigger,
        tooltipTriggerWhenLabelVisible,
        tooltipTriggerWhenLabelHidden,
        iconTheme,
      ]);

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
        other.destinationOverlayColor == destinationOverlayColor &&
        other.destinationIndicatorShape == destinationIndicatorShape &&
        other.showLabelsWhenCollapsed == showLabelsWhenCollapsed &&
        other.minWidth == minWidth &&
        other.minExtendedWidth == minExtendedWidth &&
        other.margin == margin &&
        other.padding == padding &&
        other.tooltipOffset == tooltipOffset &&
        other.tooltipTrigger == tooltipTrigger &&
        other.tooltipTriggerWhenLabelVisible ==
            tooltipTriggerWhenLabelVisible &&
        other.tooltipTriggerWhenLabelHidden == tooltipTriggerWhenLabelHidden &&
        other.iconTheme == iconTheme;
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
      DiagnosticsProperty<WidgetStateProperty<Color?>>(
        "destinationOverlayColor",
        destinationOverlayColor,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<ShapeBorder>(
        "destinationIndicatorShape",
        destinationIndicatorShape,
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
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry?>(
        "padding",
        padding,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<Offset?>(
        "tooltipOffset",
        tooltipOffset,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<TooltipTriggerMode?>(
        "tooltipTrigger",
        tooltipTrigger,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<TooltipTriggerMode?>(
        "tooltipTriggerWhenLabelVisible",
        tooltipTriggerWhenLabelVisible,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<TooltipTriggerMode?>(
        "tooltipTriggerWhenLabelHidden",
        tooltipTriggerWhenLabelHidden,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<WidgetStateProperty<IconThemeData?>?>(
        "iconTheme",
        iconTheme,
        defaultValue: null,
      ),
    );
  }

  factory NavigationRailThemeData.fromMaterial(
    m.NavigationRailThemeData material,
  ) {
    if (material is NavigationRailThemeData) {
      return material;
    }
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
      destinationOverlayColor: null,
      destinationIndicatorShape: null,
      minWidth: material.minWidth,
      minExtendedWidth: material.minExtendedWidth,
      margin: null,
      padding: null,
      tooltipOffset: null,
      tooltipTrigger: null,
      tooltipTriggerWhenLabelVisible: null,
      tooltipTriggerWhenLabelHidden: null,
      iconTheme: null,
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
  static NavigationRailThemeData? maybeOf(BuildContext context) {
    final NavigationRailTheme? navigationRailTheme =
        context.dependOnInheritedWidgetOfExactType<NavigationRailTheme>();

    if (navigationRailTheme != null) {
      return navigationRailTheme.data;
    }

    final m.NavigationRailThemeData materialNavigationRailTheme =
        m.NavigationRailTheme.of(context);

    // This is the package's custom implementation
    if (materialNavigationRailTheme is NavigationRailThemeData) {
      return materialNavigationRailTheme;
    }

    final bool hasAnyExplicitValue =
        materialNavigationRailTheme.backgroundColor != null ||
            materialNavigationRailTheme.elevation != null ||
            materialNavigationRailTheme.unselectedLabelTextStyle != null ||
            materialNavigationRailTheme.selectedLabelTextStyle != null ||
            materialNavigationRailTheme.unselectedIconTheme != null ||
            materialNavigationRailTheme.selectedIconTheme != null ||
            materialNavigationRailTheme.groupAlignment != null ||
            materialNavigationRailTheme.labelType != null ||
            materialNavigationRailTheme.useIndicator != null ||
            materialNavigationRailTheme.indicatorColor != null ||
            materialNavigationRailTheme.indicatorShape != null ||
            materialNavigationRailTheme.minWidth != null ||
            materialNavigationRailTheme.minExtendedWidth != null;

    if (!hasAnyExplicitValue) {
      return null;
    }

    return NavigationRailThemeData.fromMaterial(materialNavigationRailTheme);
  }

  static NavigationRailThemeData of(BuildContext context) {
    final NavigationRailThemeData defaults = navigationRailDefaultsFor(context);

    final NavigationRailThemeData? explicitTheme = maybeOf(context);

    if (explicitTheme != null) {
      return defaults.copyWith(
        backgroundColor: explicitTheme.backgroundColor,
        elevation: explicitTheme.elevation,
        unselectedLabelTextStyle: explicitTheme.unselectedLabelTextStyle,
        selectedLabelTextStyle: explicitTheme.selectedLabelTextStyle,
        unselectedIconTheme: explicitTheme.unselectedIconTheme,
        selectedIconTheme: explicitTheme.selectedIconTheme,
        groupAlignment: explicitTheme.groupAlignment,
        labelType: explicitTheme.labelType,
        useIndicator: explicitTheme.useIndicator,
        indicatorColor: explicitTheme.indicatorColor,
        indicatorShape: explicitTheme.indicatorShape,
        destinationOverlayColor: explicitTheme.destinationOverlayColor,
        destinationIndicatorShape: explicitTheme.destinationIndicatorShape,
        showLabelsWhenCollapsed: explicitTheme.showLabelsWhenCollapsed,
        minWidth: explicitTheme.minWidth,
        minExtendedWidth: explicitTheme.minExtendedWidth,
        margin: explicitTheme.margin,
        padding: explicitTheme.padding,
        tooltipOffset: explicitTheme.tooltipOffset,
        tooltipTrigger: explicitTheme.tooltipTrigger,
        tooltipTriggerWhenLabelVisible:
            explicitTheme.tooltipTriggerWhenLabelVisible,
        tooltipTriggerWhenLabelHidden:
            explicitTheme.tooltipTriggerWhenLabelHidden,
        iconTheme: explicitTheme.iconTheme,
      );
    }

    return defaults;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return NavigationRailTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(NavigationRailTheme oldWidget) =>
      data != oldWidget.data;
}
