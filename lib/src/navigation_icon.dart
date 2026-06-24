import "package:flutter/material.dart";

/// Compact icon body widget shared by both rail and bar destinations.
///
/// Renders the pre-themed [icon] centered inside a fixed-height slot with
/// optional M3 half-spacing on either side.  The [direction] controls
/// whether the spacing is laid out horizontally (rail) or vertically (bar).
class NavigationIcon extends StatelessWidget {
  const NavigationIcon({
    required this.icon,
    required this.minWidth,
    required this.material3,
    this.height = 44.0,
    this.addSpacing = true,
    this.direction = Axis.vertical,
    super.key,
  });

  /// The themed icon widget to render.  Theming and disabled styling must
  /// be applied by the caller (typically via a [DestinationSurfaceStrategy]).
  final Widget icon;

  /// The width constraint for the icon slot.
  final double minWidth;

  /// Whether Material 3 half-spacing should be injected around the icon.
  final bool material3;

  /// Height of the tight constraint box.  Defaults to 44 (rail slot height).
  /// Pass 32 ([kDestinationIndicatorHeight]) for bar destinations so the
  /// layout delegate measures the correct indicator-slot height.
  final double height;

  /// Whether to inject M3 half-spacing ([SizedBox] 6 px) around the icon.
  /// Set to false for bar — bar spacing is handled by the layout delegate.
  final bool addSpacing;

  /// Layout direction of the spacing siblings.
  ///
  /// Use [Axis.horizontal] for rail (side spacing) and
  /// [Axis.vertical] for bar (top/bottom spacing).
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    // _kVerticalDestinationSpacingM3 = 12.0 → half-spacing = 6.0
    final Widget? spacing =
        (material3 && addSpacing) ? const SizedBox(height: 12.0 / 2) : null;

    final List<Widget> children = <Widget>[
      if (spacing != null) spacing,
      Center(child: icon),
      if (spacing != null) spacing,
    ];

    final Widget inner = direction == Axis.horizontal
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          );

    return ConstrainedBox(
      constraints: BoxConstraints.tight(Size(minWidth, height)),
      child: inner,
    );
  }
}
