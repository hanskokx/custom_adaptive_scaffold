import "package:flutter/material.dart";

/// Default indicator dimensions matching the Material 3 spec.
const double _kDefaultIndicatorWidth = 64.0;
const double _kDefaultIndicatorHeight = 32.0;

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
    this.width = _kDefaultIndicatorWidth,
    this.height = _kDefaultIndicatorHeight,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.shape,
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
  /// Defaults to `64`.
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

  @override
  Widget build(BuildContext context) {
    final Color resolvedColor =
        color ?? Theme.of(context).colorScheme.secondary;

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        // Scale: 0 when dismissed; jumps to 40 % the moment animation starts,
        // then eases to 100 % — matching the M3 NavigationBar indicator curve.
        final double scale = animation.isDismissed
            ? 0.0
            : Tween<double>(begin: .4, end: 1.0).transform(
                CurveTween(curve: Curves.easeInOutCubicEmphasized)
                    .transform(animation.value),
              );

        // Fade: 100 ms cross-fade driven by whether the animation is moving
        // forward or backward.
        final bool selected = animation.isForwardOrCompleted;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.diagonal3Values(scale, 1.0, 1.0),
          child: AnimatedOpacity(
            opacity: selected ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 100),
            child: child,
          ),
        );
      },
      child: Transform.translate(
        offset: Offset(0, height / 2),
        child: SizedBox(
          width: width,
          height: height,
          child: DecoratedBox(
            decoration: ShapeDecoration(
              shape:
                  shape ?? RoundedRectangleBorder(borderRadius: borderRadius),
              color: resolvedColor,
            ),
          ),
        ),
      ),
    );
  }
}
