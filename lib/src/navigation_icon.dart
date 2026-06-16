import "package:auto_layout_frame/auto_layout_frame.dart";
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
    this.direction = AutoLayoutDirection.vertical,
    super.key,
  });

  /// The themed icon widget to render.  Theming and disabled styling must
  /// be applied by the caller (typically via a [DestinationSurfaceStrategy]).
  final Widget icon;

  /// The width constraint for the icon slot.
  final double minWidth;

  /// Whether Material 3 half-spacing should be injected around the icon.
  final bool material3;

  /// Layout direction of the spacing siblings.
  ///
  /// Use [AutoLayoutDirection.horizontal] for rail (side spacing) and
  /// [AutoLayoutDirection.vertical] for bar (top/bottom spacing).
  final AutoLayoutDirection direction;

  @override
  Widget build(BuildContext context) {
    // _kVerticalDestinationSpacingM3 = 12.0 → half-spacing = 6.0
    final Widget? spacing =
        material3 ? const SizedBox(height: 12.0 / 2) : null;

    return ConstrainedBox(
      constraints: BoxConstraints.tight(Size(minWidth, 44)),
      child: AutoLayoutFrame(
        alignChildren: Alignment.center,
        direction: direction,
        children: <Widget>[
          if (spacing != null) spacing,
          Center(
            // The shared compact item only owns the icon body.
            child: icon,
          ),
          if (spacing != null) spacing,
        ],
      ),
    );
  }
}
