import "package:flutter/material.dart";

import "../../navigation_bar_theme.dart" as cnb;
import "../../navigation_rail_theme.dart" as cnr;

/// Default indicator dimensions matching the Material 3 spec.
const double _kCircularIndicatorDiameter = 56.0;
const double _kIndicatorHeight = 32.0;

/// Identifies which navigation surface owns this indicator.
enum NavigationIndicatorType {
  navigationRail,
  navigationBar,
}

/// Animated selection indicator pill used by both [NavigationBar] and
/// [NavigationRail] destinations.
///
/// When [animation] is 0 the indicator is absent.  As [animation] grows
/// from 0 → 1 the indicator scales in on the x-axis and fades in over 100 ms.
class NavigationIndicator extends StatelessWidget {
  const NavigationIndicator({
    required this.animation,
    super.key,
    this.color,
    this.width = _kCircularIndicatorDiameter,
    this.height = _kIndicatorHeight,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.shape,
    this.indicatorType,
    this.states = const <WidgetState>{},
    this.overlayColor,
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
  /// Defaults to `56`.
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

  /// Which navigation surface owns this indicator.
  ///
  /// When provided, the indicator can resolve a surface-appropriate interactive
  /// overlay color for hovered/focused/pressed states.
  final NavigationIndicatorType? indicatorType;

  /// Current widget states from the interaction source.
  final Set<WidgetState> states;

  /// Optional explicit interactive overlay color resolver.
  ///
  /// If null, defaults are derived from the owning surface theme.
  final WidgetStateProperty<Color?>? overlayColor;

  Color? _resolveInteractionColor(
    BuildContext context,
    Color baseIndicatorColor,
  ) {
    if (!states.contains(WidgetState.hovered) &&
        !states.contains(WidgetState.focused) &&
        !states.contains(WidgetState.pressed)) {
      return null;
    }

    final Color? explicitOverlay = overlayColor?.resolve(states);
    if (explicitOverlay != null) {
      return explicitOverlay;
    }

    Color fallbackBase = baseIndicatorColor;
    switch (indicatorType) {
      case NavigationIndicatorType.navigationBar:
        final cnb.CustomNavigationBarThemeData barTheme =
            cnb.NavigationBarTheme.of(context);
        final cnb.CustomNavigationBarThemeData defaults =
            cnb.defaultsFor(context);
        final Color? themeOverlay =
            (barTheme.overlayColor ?? defaults.overlayColor)?.resolve(states);
        if (themeOverlay != null) {
          return themeOverlay;
        }
        fallbackBase =
            barTheme.indicatorColor ?? defaults.indicatorColor ?? fallbackBase;
      case NavigationIndicatorType.navigationRail:
        final cnr.CustomNavigationRailThemeData railTheme =
            cnr.NavigationRailTheme.of(context);
        final cnr.CustomNavigationRailThemeData defaults =
            Theme.of(context).useMaterial3
                ? cnr.NavigationRailDefaultsM3(context)
                : cnr.NavigationRailDefaultsM2(context);
        fallbackBase =
            railTheme.indicatorColor ?? defaults.indicatorColor ?? fallbackBase;
      case null:
        break;
    }

    if (states.contains(WidgetState.pressed)) {
      return fallbackBase.withValues(alpha: 0.12);
    }
    if (states.contains(WidgetState.focused)) {
      return fallbackBase.withValues(alpha: 0.12);
    }
    if (states.contains(WidgetState.hovered)) {
      return fallbackBase.withValues(alpha: 0.08);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Color resolvedColor =
        color ?? Theme.of(context).colorScheme.secondary;
    final Color? resolvedInteractionColor =
        _resolveInteractionColor(context, resolvedColor);
    final bool showInteractionIndicator = resolvedInteractionColor != null;

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        // Scale: 0 when dismissed; jumps to 40 % the moment animation starts,
        // then eases to 100 % — matching the M3 NavigationBar indicator curve.
        final double scale = animation.isDismissed
            ? (showInteractionIndicator ? 1.0 : 0.0)
            : Tween<double>(begin: .4, end: 1.0).transform(
                CurveTween(curve: Curves.easeInOutCubicEmphasized)
                    .transform(animation.value),
              );

        final bool showSelectionIndicator = !animation.isDismissed;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values(scale, 1.0, 1.0),
          child: AnimatedOpacity(
            opacity: (showSelectionIndicator || showInteractionIndicator)
                ? 1.0
                : 0.0,
            duration: const Duration(milliseconds: 100),
            child: child,
          ),
        );
      },
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            DecoratedBox(
              decoration: ShapeDecoration(
                shape:
                    shape ?? RoundedRectangleBorder(borderRadius: borderRadius),
                color: resolvedColor,
              ),
            ),
            if (resolvedInteractionColor != null)
              DecoratedBox(
                decoration: ShapeDecoration(
                  shape: shape ??
                      RoundedRectangleBorder(borderRadius: borderRadius),
                  color: resolvedInteractionColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
