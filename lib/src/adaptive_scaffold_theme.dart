import "dart:ui" show lerpDouble;

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

import "navigation_destination_types.dart";

@Deprecated(
  "Use AdaptiveScaffoldThemeData instead. "
  "This feature was deprecated after v4.1.0",
)
typedef AdaptiveScaffoldNavigationThemeData = AdaptiveScaffoldThemeData;

/// Indicator-specific styling shared by adaptive navigation destinations.
@immutable
class NavigationIndicatorThemeData with Diagnosticable {
  /// Creates indicator styling shared by adaptive navigation destinations.
  const NavigationIndicatorThemeData({
    this.destinationFillRegion,
    this.destinationHoverRegion,
    this.interactionShape,
    this.color,
    this.shape,
  });

  /// Controls where destination selected fill/highlight is painted.
  ///
  /// When null, uses Flutter's default indicator path.
  /// Passing [NavigationDestinationRegion.icon] behaves the same as null.
  final NavigationDestinationRegion? destinationFillRegion;

  /// Controls where destination hover/ink effects are painted.
  ///
  /// When null, this follows [destinationFillRegion].
  final NavigationDestinationRegion? destinationHoverRegion;

  /// Optional shape for destination navigation elements.
  ///
  /// If null, the resolved navigation rail indicator shape is used.
  final WidgetStateProperty<ShapeBorder?>? interactionShape;

  /// Optional color used for selected destination indicators.
  final Color? color;

  /// Optional shape used for selected destination indicators.
  final ShapeBorder? shape;

  /// Creates a copy of this indicator theme with the given fields replaced.
  NavigationIndicatorThemeData copyWith({
    NavigationDestinationRegion? destinationFillRegion,
    NavigationDestinationRegion? destinationHoverRegion,
    WidgetStateProperty<ShapeBorder?>? interactionShape,
    Color? color,
    ShapeBorder? shape,
  }) {
    return NavigationIndicatorThemeData(
      destinationFillRegion:
          destinationFillRegion ?? this.destinationFillRegion,
      destinationHoverRegion:
          destinationHoverRegion ?? this.destinationHoverRegion,
      interactionShape: interactionShape ?? this.interactionShape,
      color: color ?? this.color,
      shape: shape ?? this.shape,
    );
  }

  /// Linearly interpolates between two indicator themes.
  static NavigationIndicatorThemeData? lerp(
    NavigationIndicatorThemeData? a,
    NavigationIndicatorThemeData? b,
    double t,
  ) {
    if (identical(a, b)) {
      return a;
    }
    if (a == null && b == null) {
      return null;
    }
    return NavigationIndicatorThemeData(
      destinationFillRegion:
          t < 0.5 ? a?.destinationFillRegion : b?.destinationFillRegion,
      destinationHoverRegion:
          t < 0.5 ? a?.destinationHoverRegion : b?.destinationHoverRegion,
      interactionShape: WidgetStateProperty.lerp<ShapeBorder?>(
        a?.interactionShape,
        b?.interactionShape,
        t,
        ShapeBorder.lerp,
      ),
      color: Color.lerp(a?.color, b?.color, t),
      shape: ShapeBorder.lerp(a?.shape, b?.shape, t),
    );
  }

  @override
  int get hashCode => Object.hash(
        destinationFillRegion,
        destinationHoverRegion,
        interactionShape,
        color,
        shape,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is NavigationIndicatorThemeData &&
        other.destinationFillRegion == destinationFillRegion &&
        other.destinationHoverRegion == destinationHoverRegion &&
        other.interactionShape == interactionShape &&
        other.color == color &&
        other.shape == shape;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      EnumProperty<NavigationDestinationRegion>(
        "destinationFillRegion",
        destinationFillRegion,
      ),
    );
    properties.add(
      EnumProperty<NavigationDestinationRegion>(
        "destinationHoverRegion",
        destinationHoverRegion,
      ),
    );
    properties.add(
      DiagnosticsProperty<WidgetStateProperty<ShapeBorder?>>(
        "interactionShape",
        interactionShape,
      ),
    );
    properties.add(ColorProperty("color", color));
    properties.add(
      DiagnosticsProperty<ShapeBorder?>(
        "shape",
        shape,
      ),
    );
  }
}

/// Navigation-bar-specific styling shared by adaptive small-breakpoint bars.
@immutable
class AdaptiveNavigationBarThemeData with Diagnosticable {
  /// Creates navigation-bar styling for adaptive small-breakpoint layouts.
  const AdaptiveNavigationBarThemeData({
    this.height,
    this.backgroundColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
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
  final double? height;

  /// Optional navigation bar background color.
  final Color? backgroundColor;

  /// Optional navigation bar elevation.
  final double? elevation;

  /// Optional shadow color used by the navigation bar.
  final Color? shadowColor;

  /// Optional surface tint color used by the navigation bar.
  final Color? surfaceTintColor;

  /// Optional stateful text style for destination labels.
  final WidgetStateProperty<TextStyle?>? labelTextStyle;

  /// Optional stateful icon theme for destination icons.
  final WidgetStateProperty<IconThemeData?>? iconTheme;

  /// Optional label visibility behavior for destinations.
  final NavigationDestinationLabelBehavior? labelBehavior;

  /// Optional stateful overlay color for destination interaction states.
  final WidgetStateProperty<Color?>? overlayColor;

  /// Optional outer margin around the custom navigation bar.
  final EdgeInsetsGeometry? margin;

  /// Optional inner padding applied to the custom navigation bar.
  final EdgeInsetsGeometry? padding;

  /// Optional vertical offset applied to destination tooltips.
  final double? tooltipVerticalOffset;

  /// Optional padding around destination labels.
  final EdgeInsetsGeometry? labelPadding;

  /// Creates a copy of this navigation bar theme with the given fields replaced.
  AdaptiveNavigationBarThemeData copyWith({
    double? height,
    Color? backgroundColor,
    double? elevation,
    Color? shadowColor,
    Color? surfaceTintColor,
    WidgetStateProperty<TextStyle?>? labelTextStyle,
    WidgetStateProperty<IconThemeData?>? iconTheme,
    NavigationDestinationLabelBehavior? labelBehavior,
    WidgetStateProperty<Color?>? overlayColor,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? tooltipVerticalOffset,
    EdgeInsetsGeometry? labelPadding,
  }) {
    return AdaptiveNavigationBarThemeData(
      height: height ?? this.height,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      elevation: elevation ?? this.elevation,
      shadowColor: shadowColor ?? this.shadowColor,
      surfaceTintColor: surfaceTintColor ?? this.surfaceTintColor,
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
  static AdaptiveNavigationBarThemeData? lerp(
    AdaptiveNavigationBarThemeData? a,
    AdaptiveNavigationBarThemeData? b,
    double t,
  ) {
    if (identical(a, b)) {
      return a;
    }
    if (a == null && b == null) {
      return null;
    }
    return AdaptiveNavigationBarThemeData(
      height: lerpDouble(a?.height, b?.height, t),
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      elevation: lerpDouble(a?.elevation, b?.elevation, t),
      shadowColor: Color.lerp(a?.shadowColor, b?.shadowColor, t),
      surfaceTintColor: Color.lerp(a?.surfaceTintColor, b?.surfaceTintColor, t),
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
    return other is AdaptiveNavigationBarThemeData &&
        other.height == height &&
        other.backgroundColor == backgroundColor &&
        other.elevation == elevation &&
        other.shadowColor == shadowColor &&
        other.surfaceTintColor == surfaceTintColor &&
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
  NavigationRailLabelType? get compactLabelType => _data?.compactLabelType;

  /// Optional label behavior for expanded navigation rail breakpoints.
  ///
  /// This only applies to the extended rail used on medium-large and up
  /// breakpoints.
  ///
  /// When null, defaults to [NavigationRailLabelType.all].
  NavigationRailLabelType? get expandedLabelType => _data?.expandedLabelType;

  /// Optional width for extended navigation rails used on medium-large and up
  /// breakpoints.
  ///
  /// When null, [AdaptiveScaffold] uses its `extendedNavigationRailWidth`
  /// widget value (which defaults to `192`).
  double? get extendedNavigationRailWidth => _data?.extendedNavigationRailWidth;

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
  AdaptiveNavigationBarThemeData? get navigationBarTheme =>
      _data?.navigationBarTheme;

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
    this.compactLabelType,
    this.expandedLabelType,
    this.extendedNavigationRailWidth,
    this.transitionAnimation = NavigationDestinationAnimation.none,
    this.transitionCurve = Curves.easeInOut,
    this.transitionDuration,
    this.indicatorStyle,
    this.navigationBarTheme,
  });

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
  final NavigationRailLabelType? compactLabelType;

  /// Optional label behavior for expanded navigation rail breakpoints.
  ///
  /// This only applies to the extended rail used on medium-large and up
  /// breakpoints.
  ///
  /// When null, defaults to [NavigationRailLabelType.all].
  final NavigationRailLabelType? expandedLabelType;

  /// Optional width for extended navigation rails used on medium-large and up
  /// breakpoints.
  ///
  /// When null, [AdaptiveScaffold] uses its `extendedNavigationRailWidth`
  /// widget value (which defaults to `192`).
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
  final AdaptiveNavigationBarThemeData? navigationBarTheme;

  /// Creates a copy of this object but with the given fields replaced with the
  /// new values.
  @override
  AdaptiveScaffoldThemeData copyWith({
    NavigationRailLabelType? compactLabelType,
    NavigationRailLabelType? expandedLabelType,
    double? extendedNavigationRailWidth,
    NavigationDestinationAnimation? transitionAnimation,
    Curve? transitionCurve,
    Duration? transitionDuration,
    NavigationIndicatorThemeData? indicatorStyle,
    AdaptiveNavigationBarThemeData? navigationBarTheme,
  }) {
    return AdaptiveScaffoldThemeData(
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
      navigationBarTheme: AdaptiveNavigationBarThemeData.lerp(
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
      DiagnosticsProperty<AdaptiveNavigationBarThemeData?>(
        "navigationBarTheme",
        navigationBarTheme,
      ),
    );
  }
}
