import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

import "navigation_destination_types.dart";

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
