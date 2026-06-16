import "package:flutter/material.dart";

/// Height of the selection indicator, matching Material 3 spec.
const double kDestinationIndicatorHeight = 32.0;

/// Surface-agnostic resolved visual data for a navigation destination.
///
/// Produced by a [DestinationSurfaceStrategy] after applying the correct theme
/// precedence chain for the given surface (rail or bar).  All icon and label
/// styling is fully resolved; consumers use [themedIcon] and [styledLabel]
/// directly without further theme lookup.
class DestinationBuildData {
  const DestinationBuildData({
    required this.themedIcon,
    required this.styledLabel,
    required this.minWidth,
    required this.minExtendedWidth,
    required this.material3,
    required this.useIndicator,
    required this.indicatorShape,
    required this.destinationPadding,
    required this.textDirection,
    required this.extendedAnimation,
    required this.indicatorOffset,
    required this.splashColor,
    required this.hoverColor,
    this.resolvedIconSize,
  });

  /// The icon widget with theming and disabled styling already applied.
  final Widget themedIcon;

  /// The label widget with text style and disabled styling already applied.
  final Widget styledLabel;

  /// Minimum width of the destination column (rail minWidth or bar indicator
  /// width).
  final double minWidth;

  /// Minimum width of the destination in the rail extended state.
  final double minExtendedWidth;

  /// Whether Material 3 styling is active.
  final bool material3;

  /// Whether the selection indicator should be rendered.
  final bool useIndicator;

  /// Shape of the selection indicator, or null when [useIndicator] is false.
  final ShapeBorder? indicatorShape;

  /// Resolved inset padding around the destination content.
  final EdgeInsets destinationPadding;

  /// Text direction used for RTL-aware indicator placement.
  final TextDirection textDirection;

  /// Animation controlling expand/collapse transitions (rail only; always
  /// complete for bar).
  final Animation<double> extendedAnimation;

  /// Center offset of the ink indicator for [IndicatorInkWell].  Computed for
  /// the compact (label-hidden) layout; rail destinations with visible labels
  /// override this in their per-label-type layout code.
  final Offset indicatorOffset;

  /// Effective splash color, already opacity-adjusted.
  final Color splashColor;

  /// Effective hover color, already opacity-adjusted.
  final Color hoverColor;

  /// The resolved icon theme size after applying the selected/unselected/
  /// disabled override chain.  Null when the theme does not specify a size.
  ///
  /// Rail layout code uses this to compute per-label-type indicator offsets;
  /// bar layout code can ignore it.
  final double? resolvedIconSize;
}
