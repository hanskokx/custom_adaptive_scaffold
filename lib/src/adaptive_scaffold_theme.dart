import "dart:ui" show lerpDouble;

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

import "custom_navigation_rail_theme.dart";
import "navigation_destination_types.dart";
import "navigation_indicator_theme.dart";

/// Navigation-bar-specific styling shared by adaptive small-breakpoint bars.
@immutable
class CustomNavigationBarThemeData
    with Diagnosticable
    implements NavigationBarThemeData {
  /// Creates navigation-bar styling for adaptive small-breakpoint layouts.
  const CustomNavigationBarThemeData({
    this.height,
    this.backgroundColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.indicatorColor,
    this.indicatorShape,
    this.border,
    this.indicatorStyle,
    this.labelTextStyle,
    this.iconTheme,
    this.labelBehavior,
    this.overlayColor,
    this.margin,
    this.padding,
    this.tooltipVerticalOffset,
    this.labelPadding,
  });

  /// Optional navigation bar height.
  @override
  final double? height;

  /// Optional navigation bar background color.
  @override
  final Color? backgroundColor;

  /// Optional navigation bar elevation.
  @override
  final double? elevation;

  /// Optional shadow color used by the navigation bar.
  @override
  final Color? shadowColor;

  /// Optional surface tint color used by the navigation bar.
  @override
  final Color? surfaceTintColor;

  /// Optional selected-destination indicator color.
  ///
  /// When [indicatorStyle] provides a color, it takes precedence.
  @override
  final Color? indicatorColor;

  /// Optional selected-destination indicator shape.
  ///
  /// When [indicatorStyle] provides a shape, it takes precedence.
  @override
  final ShapeBorder? indicatorShape;

  /// Optional border around the outer navigation bar surface.
  final BorderSide? border;

  /// Optional indicator-style override scoped to the navigation bar.
  ///
  /// This takes precedence over top-level [AdaptiveScaffoldThemeData.indicatorStyle]
  /// when resolving bar destination interaction and selected-fill behavior.
  final NavigationIndicatorThemeData? indicatorStyle;

  /// Optional stateful text style for destination labels.
  @override
  final WidgetStateProperty<TextStyle?>? labelTextStyle;

  /// Optional stateful icon theme for destination icons.
  @override
  final WidgetStateProperty<IconThemeData?>? iconTheme;

  /// Optional label visibility behavior for destinations.
  @override
  final NavigationDestinationLabelBehavior? labelBehavior;

  /// Optional stateful overlay color for destination interaction states.
  @override
  final WidgetStateProperty<Color?>? overlayColor;

  /// Optional outer margin around the custom navigation bar.
  final EdgeInsetsGeometry? margin;

  /// Optional inner padding applied to the custom navigation bar.
  final EdgeInsetsGeometry? padding;

  /// Optional vertical offset applied to destination tooltips.
  final double? tooltipVerticalOffset;

  /// Optional padding around destination labels.
  @override
  final EdgeInsetsGeometry? labelPadding;

  /// Resolved indicator style for bar rendering.
  ///
  /// The additive [indicatorStyle] fields override framework-equivalent
  /// indicator fields when both are provided.
  NavigationIndicatorThemeData? get resolvedIndicatorStyle {
    if (indicatorStyle != null) {
      return indicatorStyle;
    }
    if (indicatorColor == null && indicatorShape == null) {
      return null;
    }
    return NavigationIndicatorThemeData(
      color: indicatorColor,
      shape: indicatorShape,
    );
  }

  /// Converts this custom theme data into framework [NavigationBarThemeData].
  NavigationBarThemeData toNavigationBarThemeData() {
    return NavigationBarThemeData(
      height: height,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      indicatorColor: resolvedIndicatorStyle?.color ?? indicatorColor,
      indicatorShape: resolvedIndicatorStyle?.shape ?? indicatorShape,
      labelTextStyle: labelTextStyle,
      iconTheme: iconTheme,
      labelBehavior: labelBehavior,
      overlayColor: overlayColor,
      labelPadding: labelPadding,
    );
  }

  /// Creates custom bar theme data from framework [NavigationBarThemeData].
  factory CustomNavigationBarThemeData.fromNavigationBarThemeData(
    NavigationBarThemeData data,
  ) {
    return CustomNavigationBarThemeData(
      height: data.height,
      backgroundColor: data.backgroundColor,
      elevation: data.elevation,
      shadowColor: data.shadowColor,
      surfaceTintColor: data.surfaceTintColor,
      indicatorColor: data.indicatorColor,
      indicatorShape: data.indicatorShape,
      labelTextStyle: data.labelTextStyle,
      iconTheme: data.iconTheme,
      labelBehavior: data.labelBehavior,
      overlayColor: data.overlayColor,
      labelPadding: data.labelPadding,
    );
  }

  /// Creates a copy of this navigation bar theme with the given fields replaced.
  @override
  CustomNavigationBarThemeData copyWith({
    double? height,
    Color? backgroundColor,
    double? elevation,
    Color? shadowColor,
    Color? surfaceTintColor,
    Color? indicatorColor,
    ShapeBorder? indicatorShape,
    BorderSide? border,
    NavigationIndicatorThemeData? indicatorStyle,
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
      border: border ?? this.border,
      indicatorStyle: indicatorStyle ?? this.indicatorStyle,
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

  /// Linearly interpolates between two adaptive navigation bar themes.
  static CustomNavigationBarThemeData? lerp(
    CustomNavigationBarThemeData? a,
    CustomNavigationBarThemeData? b,
    double t,
  ) {
    if (identical(a, b)) {
      return a;
    }
    if (a == null && b == null) {
      return null;
    }
    return CustomNavigationBarThemeData(
      height: lerpDouble(a?.height, b?.height, t),
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      elevation: lerpDouble(a?.elevation, b?.elevation, t),
      shadowColor: Color.lerp(a?.shadowColor, b?.shadowColor, t),
      surfaceTintColor: Color.lerp(a?.surfaceTintColor, b?.surfaceTintColor, t),
      indicatorColor: Color.lerp(a?.indicatorColor, b?.indicatorColor, t),
      indicatorShape: ShapeBorder.lerp(a?.indicatorShape, b?.indicatorShape, t),
      border: a?.border == null && b?.border == null
          ? null
          : BorderSide.lerp(
              a?.border ?? BorderSide.none,
              b?.border ?? BorderSide.none,
              t,
            ),
      indicatorStyle: NavigationIndicatorThemeData.lerp(
        a?.indicatorStyle,
        b?.indicatorStyle,
        t,
      ),
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
      margin: EdgeInsetsGeometry.lerp(a?.margin, b?.margin, t),
      padding: EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t),
      tooltipVerticalOffset:
          lerpDouble(a?.tooltipVerticalOffset, b?.tooltipVerticalOffset, t),
      labelPadding:
          EdgeInsetsGeometry.lerp(a?.labelPadding, b?.labelPadding, t),
    );
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
        height,
        backgroundColor,
        elevation,
        shadowColor,
        surfaceTintColor,
        indicatorColor,
        indicatorShape,
        border,
        indicatorStyle,
        labelTextStyle,
        iconTheme,
        labelBehavior,
        overlayColor,
        margin,
        padding,
        tooltipVerticalOffset,
        labelPadding,
      ]);

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
        other.border == border &&
        other.indicatorStyle == indicatorStyle &&
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
    properties.add(DoubleProperty("height", height));
    properties.add(ColorProperty("backgroundColor", backgroundColor));
    properties.add(DoubleProperty("elevation", elevation));
    properties.add(ColorProperty("shadowColor", shadowColor));
    properties.add(ColorProperty("surfaceTintColor", surfaceTintColor));
    properties.add(ColorProperty("indicatorColor", indicatorColor));
    properties.add(
      DiagnosticsProperty<ShapeBorder?>(
        "indicatorShape",
        indicatorShape,
      ),
    );
    properties.add(
      DiagnosticsProperty<BorderSide?>(
        "border",
        border,
      ),
    );
    properties.add(
      DiagnosticsProperty<NavigationIndicatorThemeData?>(
        "indicatorStyle",
        indicatorStyle,
      ),
    );
    properties.add(
      DiagnosticsProperty<WidgetStateProperty<TextStyle?>>(
        "labelTextStyle",
        labelTextStyle,
      ),
    );
    properties.add(
      DiagnosticsProperty<WidgetStateProperty<IconThemeData?>>(
        "iconTheme",
        iconTheme,
      ),
    );
    properties.add(
      EnumProperty<NavigationDestinationLabelBehavior>(
        "labelBehavior",
        labelBehavior,
      ),
    );
    properties.add(
      DiagnosticsProperty<WidgetStateProperty<Color?>>(
        "overlayColor",
        overlayColor,
      ),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry?>(
        "margin",
        margin,
      ),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry?>(
        "padding",
        padding,
      ),
    );
    properties.add(
      DiagnosticsProperty<double?>(
        "tooltipVerticalOffset",
        tooltipVerticalOffset,
      ),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry?>(
        "labelPadding",
        labelPadding,
      ),
    );
  }
}

/// An inherited widget that defines visual properties for [NavigationBar]s and
/// [NavigationDestination]s in this widget's subtree.
///
/// Values specified here are used for [NavigationBar] properties that are not
/// given an explicit non-null value.
class CustomNavigationBarTheme extends InheritedTheme
    implements NavigationBarTheme {
  /// Creates a custom navigation bar theme.
  const CustomNavigationBarTheme({
    required this.data,
    required super.child,
    super.key,
  });

  /// The custom navigation bar theme data for descendants.
  @override
  final CustomNavigationBarThemeData data;

  /// The closest instance of this class that encloses the given context.
  ///
  /// If there is no enclosing [CustomNavigationBarTheme] widget, then
  /// framework [NavigationBarTheme] and finally [ThemeData.navigationBarTheme]
  /// are used.
  static NavigationBarThemeData of(BuildContext context) {
    final NavigationBarTheme? navigationBarTheme = context
            .dependOnInheritedWidgetOfExactType<CustomNavigationBarTheme>() ??
        context.dependOnInheritedWidgetOfExactType<NavigationBarTheme>();

    return navigationBarTheme?.data ?? Theme.of(context).navigationBarTheme;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return CustomNavigationBarTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(CustomNavigationBarTheme oldWidget) {
    return data != oldWidget.data;
  }
}

/// Optional, adaptive-navigation-specific overrides for [AdaptiveScaffold].
///
/// All fields are opt-in. When left null/default, [AdaptiveScaffold] keeps
/// its legacy behavior and defers to the existing Material themes.
@immutable
class AdaptiveScaffoldTheme extends InheritedTheme with Diagnosticable {
  /// Creates a theme that can be used for the Adaptive Scaffold Theme.
  const AdaptiveScaffoldTheme({
    super.key,
    AdaptiveScaffoldThemeData? data,
    Widget? child,
  })  : _data = data,
        super(child: child ?? const SizedBox());

  final AdaptiveScaffoldThemeData? _data;

  /// Optional label behavior for compact rail and small navigation bar.
  ///
  /// For rail, this is passed as [NavigationRail.labelType].
  /// For bar, it is mapped as:
  /// [NavigationRailLabelType.none] ->
  /// [NavigationDestinationLabelBehavior.alwaysHide],
  /// [NavigationRailLabelType.selected] ->
  /// [NavigationDestinationLabelBehavior.onlyShowSelected],
  /// [NavigationRailLabelType.all] ->
  /// [NavigationDestinationLabelBehavior.alwaysShow].
  ///
  /// When null, rail and bar each use their theme defaults.
  @Deprecated(
    "Use navigationRailTheme?.compactLabelType instead. "
    "This getter will be removed after v4.1.0+1.",
  )
  NavigationRailLabelType? get compactLabelType =>
      _data?.navigationRailTheme?.compactLabelType ?? _data?.compactLabelType;

  /// Optional label behavior for expanded navigation rail breakpoints.
  ///
  /// This only applies to the extended rail used on medium-large and up
  /// breakpoints.
  ///
  /// When null, defaults to [NavigationRailLabelType.all].
  @Deprecated(
    "Use navigationRailTheme?.expandedLabelType instead. "
    "This getter will be removed after v4.1.0+1.",
  )
  NavigationRailLabelType? get expandedLabelType =>
      _data?.navigationRailTheme?.expandedLabelType ?? _data?.expandedLabelType;

  /// Optional width for extended navigation rails used on medium-large and up
  /// breakpoints.
  ///
  /// When null, [AdaptiveScaffold] uses its `extendedNavigationRailWidth`
  /// widget value (which defaults to `192`).
  @Deprecated(
    "Use navigationRailTheme?.extendedNavigationRailWidth instead. "
    "This getter will be removed after v4.1.0+1.",
  )
  double? get extendedNavigationRailWidth =>
      _data?.navigationRailTheme?.extendedNavigationRailWidth ??
      _data?.extendedNavigationRailWidth;

  /// Icon transition preset used by small breakpoint navigation bar and
  /// compact (medium breakpoint) navigation rail destinations.
  ///
  /// Defaults to [NavigationDestinationAnimation.none] to preserve legacy behavior.
  NavigationDestinationAnimation get transitionAnimation =>
      _data?.transitionAnimation ??
      const AdaptiveScaffoldThemeData().transitionAnimation;

  /// Curve used by compact rail icon transitions.
  Curve get transitionCurve =>
      _data?.transitionCurve ??
      const AdaptiveScaffoldThemeData().transitionCurve;

  /// Optional duration used by compact rail icon transitions.
  Duration? get transitionDuration => _data?.transitionDuration;

  /// Indicator-specific styling shared by adaptive navigation destinations.
  NavigationIndicatorThemeData? get indicatorStyle => _data?.indicatorStyle;

  /// Navigation-bar-specific styling shared by adaptive small-breakpoint bars.
  CustomNavigationBarThemeData? get navigationBarTheme =>
      _data?.navigationBarTheme;

  /// Navigation-rail-specific styling shared by adaptive medium+ breakpoints.
  CustomNavigationRailThemeData? get navigationRailTheme =>
      _data?.navigationRailTheme;

  /// Resolved theme data, falling back to defaults when no data is provided.
  AdaptiveScaffoldThemeData get data =>
      _data ?? const AdaptiveScaffoldThemeData();

  /// Retrieves the [AdaptiveScaffoldThemeData] from the closest ancestor
  /// [AdaptiveScaffoldTheme].
  ///
  /// If there is no enclosing [AdaptiveScaffoldTheme] widget, then a new
  /// [AdaptiveScaffoldThemeData] instance is returned.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// AdaptiveScaffoldThemeData theme = AdaptiveScaffoldTheme.of(context);
  /// ```
  static AdaptiveScaffoldThemeData of(BuildContext context) {
    return maybeOf(context) ?? const AdaptiveScaffoldThemeData();
  }

  /// Retrieves the [AdaptiveScaffoldThemeData] from the closest ancestor
  /// [AdaptiveScaffoldTheme], if available.
  static AdaptiveScaffoldThemeData? maybeOf(BuildContext context) {
    final AdaptiveScaffoldTheme? adaptiveScaffoldTheme =
        context.dependOnInheritedWidgetOfExactType<AdaptiveScaffoldTheme>();
    return adaptiveScaffoldTheme?.data;
  }

  /// Linearly interpolate between two AdaptiveScaffold themes.
  ///
  /// {@macro dart.ui.shadow.lerp}
  factory AdaptiveScaffoldTheme.lerp(
    AdaptiveScaffoldTheme? a,
    AdaptiveScaffoldTheme? b,
    double t,
  ) {
    if (identical(a, b) && a != null) {
      return a;
    }

    return AdaptiveScaffoldTheme(
      data: AdaptiveScaffoldThemeData._lerpThemeData(
        a?.data ?? const AdaptiveScaffoldThemeData(),
        b?.data ?? const AdaptiveScaffoldThemeData(),
        t,
      ),
    );
  }

  @override
  bool updateShouldNotify(covariant AdaptiveScaffoldTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) {
    return AdaptiveScaffoldTheme(data: data, child: child);
  }
}

/// Optional, adaptive-navigation-specific data used by [AdaptiveScaffoldTheme].
@immutable
class AdaptiveScaffoldThemeData
    extends ThemeExtension<AdaptiveScaffoldThemeData> with Diagnosticable {
  /// Creates optional overrides for adaptive navigation behavior and styling.
  const AdaptiveScaffoldThemeData({
    this.navigationRailTheme,
    @Deprecated(
      "Use navigationRailTheme.compactLabelType instead. "
      "This field will be removed after v4.1.0+1.",
    )
    this.compactLabelType,
    @Deprecated(
      "Use navigationRailTheme.expandedLabelType instead. "
      "This field will be removed after v4.1.0+1.",
    )
    this.expandedLabelType,
    @Deprecated(
      "Use navigationRailTheme.extendedNavigationRailWidth instead. "
      "This field will be removed after v4.1.0+1.",
    )
    this.extendedNavigationRailWidth,
    this.transitionAnimation = NavigationDestinationAnimation.none,
    this.transitionCurve = Curves.easeInOut,
    this.transitionDuration,
    this.indicatorStyle,
    this.navigationBarTheme,
  });

  /// Navigation-rail-specific styling shared by adaptive medium+ breakpoints.
  final CustomNavigationRailThemeData? navigationRailTheme;

  /// Optional label behavior for compact rail and small navigation bar.
  ///
  /// For rail, this is passed as [NavigationRail.labelType].
  /// For bar, it is mapped as:
  /// [NavigationRailLabelType.none] ->
  /// [NavigationDestinationLabelBehavior.alwaysHide],
  /// [NavigationRailLabelType.selected] ->
  /// [NavigationDestinationLabelBehavior.onlyShowSelected],
  /// [NavigationRailLabelType.all] ->
  /// [NavigationDestinationLabelBehavior.alwaysShow].
  ///
  /// When null, rail and bar each use their theme defaults.
  @Deprecated(
    "Use navigationRailTheme?.compactLabelType instead. "
    "This field will be removed after v4.1.0+1.",
  )
  final NavigationRailLabelType? compactLabelType;

  /// Optional label behavior for expanded navigation rail breakpoints.
  ///
  /// This only applies to the extended rail used on medium-large and up
  /// breakpoints.
  ///
  /// When null, defaults to [NavigationRailLabelType.all].
  @Deprecated(
    "Use navigationRailTheme?.expandedLabelType instead. "
    "This field will be removed after v4.1.0+1.",
  )
  final NavigationRailLabelType? expandedLabelType;

  /// Optional width for extended navigation rails used on medium-large and up
  /// breakpoints.
  ///
  /// When null, [AdaptiveScaffold] uses its `extendedNavigationRailWidth`
  /// widget value (which defaults to `192`).
  @Deprecated(
    "Use navigationRailTheme?.extendedNavigationRailWidth instead. "
    "This field will be removed after v4.1.0+1.",
  )
  final double? extendedNavigationRailWidth;

  /// Icon transition preset used by small breakpoint navigation bar and
  /// compact (medium breakpoint) navigation rail destinations.
  ///
  /// Defaults to [NavigationDestinationAnimation.none] to preserve legacy behavior.
  final NavigationDestinationAnimation transitionAnimation;

  /// Curve used by compact rail icon transitions.
  final Curve transitionCurve;

  /// Optional duration used by compact rail icon transitions.
  final Duration? transitionDuration;

  /// Indicator-specific styling shared by adaptive navigation destinations.
  final NavigationIndicatorThemeData? indicatorStyle;

  /// Navigation-bar-specific styling shared by adaptive small-breakpoint bars.
  final CustomNavigationBarThemeData? navigationBarTheme;

  /// Creates a copy of this object but with the given fields replaced with the
  /// new values.
  @override
  AdaptiveScaffoldThemeData copyWith({
    CustomNavigationRailThemeData? navigationRailTheme,
    @Deprecated(
      "Use navigationRailTheme?.compactLabelType instead. "
      "This parameter will be removed after v4.1.0+1.",
    )
    NavigationRailLabelType? compactLabelType,
    @Deprecated(
      "Use navigationRailTheme?.expandedLabelType instead. "
      "This parameter will be removed after v4.1.0+1.",
    )
    NavigationRailLabelType? expandedLabelType,
    @Deprecated(
      "Use navigationRailTheme?.extendedNavigationRailWidth instead. "
      "This parameter will be removed after v4.1.0+1.",
    )
    double? extendedNavigationRailWidth,
    NavigationDestinationAnimation? transitionAnimation,
    Curve? transitionCurve,
    Duration? transitionDuration,
    NavigationIndicatorThemeData? indicatorStyle,
    CustomNavigationBarThemeData? navigationBarTheme,
  }) {
    return AdaptiveScaffoldThemeData(
      navigationRailTheme: navigationRailTheme ?? this.navigationRailTheme,
      compactLabelType: compactLabelType ?? this.compactLabelType,
      expandedLabelType: expandedLabelType ?? this.expandedLabelType,
      extendedNavigationRailWidth:
          extendedNavigationRailWidth ?? this.extendedNavigationRailWidth,
      transitionAnimation: transitionAnimation ?? this.transitionAnimation,
      transitionCurve: transitionCurve ?? this.transitionCurve,
      transitionDuration: transitionDuration ?? this.transitionDuration,
      indicatorStyle: indicatorStyle ?? this.indicatorStyle,
      navigationBarTheme: navigationBarTheme ?? this.navigationBarTheme,
    );
  }

  factory AdaptiveScaffoldThemeData._lerpThemeData(
    AdaptiveScaffoldThemeData a,
    AdaptiveScaffoldThemeData b,
    double t,
  ) {
    if (identical(a, b)) {
      return a;
    }

    return AdaptiveScaffoldThemeData(
      navigationRailTheme: CustomNavigationRailThemeData.lerp(
        a.navigationRailTheme,
        b.navigationRailTheme,
        t,
      ),
      compactLabelType: t < 0.5 ? a.compactLabelType : b.compactLabelType,
      expandedLabelType: t < 0.5 ? a.expandedLabelType : b.expandedLabelType,
      extendedNavigationRailWidth: lerpDouble(
        a.extendedNavigationRailWidth,
        b.extendedNavigationRailWidth,
        t,
      ),
      transitionAnimation:
          t < 0.5 ? a.transitionAnimation : b.transitionAnimation,
      transitionCurve: t < 0.5 ? a.transitionCurve : b.transitionCurve,
      transitionDuration: t < 0.5 ? a.transitionDuration : b.transitionDuration,
      indicatorStyle: NavigationIndicatorThemeData.lerp(
        a.indicatorStyle,
        b.indicatorStyle,
        t,
      ),
      navigationBarTheme: CustomNavigationBarThemeData.lerp(
        a.navigationBarTheme,
        b.navigationBarTheme,
        t,
      ),
    );
  }

  /// Linearly interpolate between two scaffold navigation themes.
  ///
  /// {@macro dart.ui.shadow.lerp}
  @override
  AdaptiveScaffoldThemeData lerp(
    covariant ThemeExtension<AdaptiveScaffoldThemeData>? other,
    double t,
  ) {
    if (other is! AdaptiveScaffoldThemeData) {
      return this;
    }
    return AdaptiveScaffoldThemeData._lerpThemeData(this, other, t);
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
        navigationRailTheme,
        compactLabelType,
        expandedLabelType,
        extendedNavigationRailWidth,
        transitionAnimation,
        transitionCurve,
        transitionDuration,
        indicatorStyle,
        navigationBarTheme,
      ]);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is AdaptiveScaffoldThemeData &&
        other.navigationRailTheme == navigationRailTheme &&
        other.compactLabelType == compactLabelType &&
        other.expandedLabelType == expandedLabelType &&
        other.extendedNavigationRailWidth == extendedNavigationRailWidth &&
        other.transitionAnimation == transitionAnimation &&
        other.transitionCurve == transitionCurve &&
        other.transitionDuration == transitionDuration &&
        other.indicatorStyle == indicatorStyle &&
        other.navigationBarTheme == navigationBarTheme;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<CustomNavigationRailThemeData?>(
        "navigationRailTheme",
        navigationRailTheme,
      ),
    );
    properties.add(
      EnumProperty<NavigationRailLabelType>(
        "compactLabelType",
        compactLabelType,
      ),
    );
    properties.add(
      EnumProperty<NavigationRailLabelType>(
        "expandedLabelType",
        expandedLabelType,
      ),
    );
    properties.add(
      DoubleProperty(
        "extendedNavigationRailWidth",
        extendedNavigationRailWidth,
      ),
    );
    properties.add(
      EnumProperty<NavigationDestinationAnimation>(
        "transitionAnimation",
        transitionAnimation,
      ),
    );
    properties
        .add(DiagnosticsProperty<Curve>("transitionCurve", transitionCurve));
    properties.add(
      DiagnosticsProperty<Duration>(
        "transitionDuration",
        transitionDuration,
      ),
    );
    properties.add(
      DiagnosticsProperty<NavigationIndicatorThemeData?>(
        "indicatorStyle",
        indicatorStyle,
      ),
    );
    properties.add(
      DiagnosticsProperty<CustomNavigationBarThemeData?>(
        "navigationBarTheme",
        navigationBarTheme,
      ),
    );
  }
}
