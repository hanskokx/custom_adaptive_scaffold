import "package:flutter/foundation.dart";
import "package:flutter/widgets.dart";

import "../custom_adaptive_scaffold.dart";

/// Optional, adaptive-navigation-specific overrides for [AdaptiveScaffold].
///
/// All fields are opt-in. When left null/default, [AdaptiveScaffold] keeps
/// its legacy behavior and defers to the existing Material themes.
@immutable
class AdaptiveScaffoldTheme extends InheritedTheme with Diagnosticable {
  /// Creates a theme that can be used for the Adaptive Scaffold Theme.
  const AdaptiveScaffoldTheme({
    super.key,
    NavigationRailLabelType? compactLabelType,
    NavigationRailLabelType? expandedLabelType,
    NavigationDestinationAnimation? transitionAnimation,
    Curve? transitionCurve,
    Duration? transitionDuration,
    NavigationDestinationRegion? destinationFillRegion,
    NavigationDestinationRegion? destinationHoverRegion,
    WidgetStateProperty<ShapeBorder?>? shape,
    AdaptiveScaffoldThemeData? data,
    Widget? child,
  })  : _compactLabelType = compactLabelType,
        _expandedLabelType = expandedLabelType,
        _transitionAnimation =
            transitionAnimation ?? NavigationDestinationAnimation.none,
        _transitionCurve = transitionCurve ?? Curves.easeInOut,
        _transitionDuration = transitionDuration,
        _destinationFillRegion = destinationFillRegion,
        _destinationHoverRegion = destinationHoverRegion,
        _shape = shape,
        _data = data,
        super(child: child ?? const SizedBox());

  final AdaptiveScaffoldThemeData? _data;
  final NavigationRailLabelType? _compactLabelType;
  final NavigationRailLabelType? _expandedLabelType;
  final NavigationDestinationAnimation _transitionAnimation;
  final Curve _transitionCurve;
  final Duration? _transitionDuration;
  final NavigationDestinationRegion? _destinationFillRegion;
  final NavigationDestinationRegion? _destinationHoverRegion;
  final WidgetStateProperty<ShapeBorder?>? _shape;

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
  NavigationRailLabelType? get compactLabelType =>
      _data != null ? _data.compactLabelType : _compactLabelType;

  /// Optional label behavior for expanded navigation rail breakpoints.
  ///
  /// This only applies to the extended rail used on medium-large and up
  /// breakpoints.
  ///
  /// When null, defaults to [NavigationRailLabelType.all].
  NavigationRailLabelType? get expandedLabelType =>
      _data != null ? _data.expandedLabelType : _expandedLabelType;

  /// Icon transition preset used by small breakpoint navigation bar and
  /// compact (medium breakpoint) navigation rail destinations.
  ///
  /// Defaults to [NavigationDestinationAnimation.none] to preserve legacy behavior.
  NavigationDestinationAnimation get transitionAnimation =>
      _data != null ? _data.transitionAnimation : _transitionAnimation;

  /// Curve used by compact rail icon transitions.
  Curve get transitionCurve =>
      _data != null ? _data.transitionCurve : _transitionCurve;

  /// Optional duration used by compact rail icon transitions.
  Duration? get transitionDuration =>
      _data != null ? _data.transitionDuration : _transitionDuration;

  /// Controls where destination selected fill/highlight is painted.
  ///
  /// When null, uses Flutter's default indicator path.
  /// Passing [NavigationDestinationRegion.icon] behaves the same as null.
  NavigationDestinationRegion? get destinationFillRegion =>
      _data != null ? _data.destinationFillRegion : _destinationFillRegion;

  /// Controls where destination hover/ink effects are painted.
  ///
  /// When null, this follows [destinationFillRegion].
  NavigationDestinationRegion? get destinationHoverRegion =>
      _data != null ? _data.destinationHoverRegion : _destinationHoverRegion;

  /// Optional shape for destination navigation elements.
  ///
  /// If null, the resolved navigation rail indicator shape is used.
  WidgetStateProperty<ShapeBorder?>? get shape =>
      _data != null ? _data.shape : _shape;

  AdaptiveScaffoldThemeData get data =>
      _data ??
      AdaptiveScaffoldThemeData(
        compactLabelType: compactLabelType,
        expandedLabelType: expandedLabelType,
        transitionAnimation: transitionAnimation,
        transitionCurve: transitionCurve,
        transitionDuration: transitionDuration,
        destinationFillRegion: destinationFillRegion,
        destinationHoverRegion: destinationHoverRegion,
        shape: shape,
      );

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
    final AdaptiveScaffoldTheme? adaptiveScaffoldTheme =
        context.dependOnInheritedWidgetOfExactType<AdaptiveScaffoldTheme>();
    return adaptiveScaffoldTheme?.data ?? const AdaptiveScaffoldThemeData();
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
      compactLabelType: t < 0.5 ? a?.compactLabelType : b?.compactLabelType,
      expandedLabelType: t < 0.5 ? a?.expandedLabelType : b?.expandedLabelType,
      transitionAnimation:
          t < 0.5 ? a?.transitionAnimation : b?.transitionAnimation,
      transitionCurve: t < 0.5 ? a?.transitionCurve : b?.transitionCurve,
      transitionDuration:
          t < 0.5 ? a?.transitionDuration : b?.transitionDuration,
      destinationFillRegion:
          t < 0.5 ? a?.destinationFillRegion : b?.destinationFillRegion,
      destinationHoverRegion:
          t < 0.5 ? a?.destinationHoverRegion : b?.destinationHoverRegion,
      shape: WidgetStateProperty.lerp<ShapeBorder?>(
        a?.shape,
        b?.shape,
        t,
        ShapeBorder.lerp,
      ),
      data: AdaptiveScaffoldThemeData.lerp(
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

@immutable
class AdaptiveScaffoldThemeData with Diagnosticable {
  const AdaptiveScaffoldThemeData({
    this.compactLabelType,
    this.expandedLabelType,
    this.transitionAnimation = NavigationDestinationAnimation.none,
    this.transitionCurve = Curves.easeInOut,
    this.transitionDuration,
    this.destinationFillRegion,
    this.destinationHoverRegion,
    this.shape,
  });

  /// Overrides the defalt value of [NavigationRail.labelType] for the compact rail and small navigation.
  final NavigationRailLabelType? compactLabelType;

  /// Overrides the default label type of the expanded rail used on medium-large and up breakpoints.
  final NavigationRailLabelType? expandedLabelType;

  /// Overrides the default icon transition in navigation rail destinations.
  final NavigationDestinationAnimation transitionAnimation;

  /// Overrides the default curve used by the navigation rail destination icon transition.
  final Curve transitionCurve;

  /// Overrides the default duration used by the navigation rail destination icon transition.
  final Duration? transitionDuration;

  /// Overrides the default region used for destination selected fill/highlight.
  final NavigationDestinationRegion? destinationFillRegion;

  /// Overrides the default region used for destination hover/ink effects.
  final NavigationDestinationRegion? destinationHoverRegion;

  /// Overrides the default shape used for destination navigation elements.
  final WidgetStateProperty<ShapeBorder?>? shape;

  /// Creates a copy of this object but with the given fields replaced with the
  /// new values.
  AdaptiveScaffoldThemeData copyWith({
    NavigationRailLabelType? compactLabelType,
    NavigationRailLabelType? expandedLabelType,
    NavigationDestinationAnimation? transitionAnimation,
    Curve? transitionCurve,
    Duration? transitionDuration,
    NavigationDestinationRegion? destinationFillRegion,
    NavigationDestinationRegion? destinationHoverRegion,
    WidgetStateProperty<ShapeBorder?>? destinationFillShape,
    WidgetStateProperty<ShapeBorder?>? destinationHoverShape,
  }) {
    return AdaptiveScaffoldThemeData(
      compactLabelType: compactLabelType ?? this.compactLabelType,
      expandedLabelType: expandedLabelType ?? this.expandedLabelType,
      transitionAnimation: transitionAnimation ?? this.transitionAnimation,
      transitionCurve: transitionCurve ?? this.transitionCurve,
      transitionDuration: transitionDuration ?? this.transitionDuration,
      destinationFillRegion:
          destinationFillRegion ?? this.destinationFillRegion,
      destinationHoverRegion:
          destinationHoverRegion ?? this.destinationHoverRegion,
      shape: destinationFillShape ?? this.shape,
    );
  }

  /// Linearly interpolate between two scaffold navigation themes.
  ///
  /// {@macro dart.ui.shadow.lerp}
  factory AdaptiveScaffoldThemeData.lerp(
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
      transitionAnimation:
          t < 0.5 ? a.transitionAnimation : b.transitionAnimation,
      transitionCurve: t < 0.5 ? a.transitionCurve : b.transitionCurve,
      transitionDuration: t < 0.5 ? a.transitionDuration : b.transitionDuration,
      destinationFillRegion:
          t < 0.5 ? a.destinationFillRegion : b.destinationFillRegion,
      destinationHoverRegion:
          t < 0.5 ? a.destinationHoverRegion : b.destinationHoverRegion,
      shape: WidgetStateProperty.lerp<ShapeBorder?>(
        a.shape,
        b.shape,
        t,
        ShapeBorder.lerp,
      ),
    );
  }

  @override
  int get hashCode => Object.hash(
        compactLabelType,
        expandedLabelType,
        transitionAnimation,
        transitionCurve,
        transitionDuration,
        destinationFillRegion,
        destinationHoverRegion,
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
    return other is AdaptiveScaffoldThemeData &&
        other.compactLabelType == compactLabelType &&
        other.expandedLabelType == expandedLabelType &&
        other.transitionAnimation == transitionAnimation &&
        other.transitionCurve == transitionCurve &&
        other.transitionDuration == transitionDuration &&
        other.destinationFillRegion == destinationFillRegion &&
        other.destinationHoverRegion == destinationHoverRegion &&
        other.shape == shape;
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
        "shape",
        shape,
      ),
    );
  }
}
