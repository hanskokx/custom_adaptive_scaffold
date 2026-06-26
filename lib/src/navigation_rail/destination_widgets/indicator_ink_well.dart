part of "../navigation_rail.dart";

/// Ink response used by rail destinations to align splash geometry with the
/// selection indicator or full destination bounds.
class _IndicatorInkWell extends InkResponse {
  /// Creates an ink response for a rail destination indicator.
  const _IndicatorInkWell({
    required this.useMaterial3,
    required this.indicatorOffset,
    required this.applyXOffset,
    required this.textDirection,
    required this.indicatorWidth,
    required this.disableFullItemInk,
    this.indicatorHeight = 32.0,
    super.child,
    super.onTap,
    super.statesController,
    ShapeBorder? customBorder,
    BorderRadius? borderRadius,
    super.highlightColor,
    super.splashColor,
    super.hoverColor,
    super.overlayColor,
  }) : super(
          containedInkWell: true,
          highlightShape: BoxShape.rectangle,
          borderRadius: customBorder == null ? borderRadius : null,
          customBorder: customBorder,
        );

  /// Whether the surrounding destination is using Material 3 behavior.
  final bool useMaterial3;

  /// The center point used to place the indicator-aligned ink rect.
  final Offset indicatorOffset;

  /// Whether the horizontal indicator offset should be applied directly.
  final bool applyXOffset;

  /// The ambient text direction used to mirror indicator placement in RTL.
  final TextDirection textDirection;

  /// The width of the indicator-aligned ink rect.
  final double indicatorWidth;

  /// The height of the indicator-aligned ink rect.
  final double indicatorHeight;

  /// Whether ink should be clipped to the indicator instead of the full item.
  final bool disableFullItemInk;

  @override
  RectCallback? getRectCallback(RenderBox referenceBox) {
    final double boxWidth = referenceBox.size.width;
    double indicatorHorizontalCenter =
        applyXOffset ? indicatorOffset.dx : boxWidth / 2;
    if (textDirection == TextDirection.rtl) {
      indicatorHorizontalCenter = boxWidth - indicatorHorizontalCenter;
    }
    if (disableFullItemInk) {
      return () => Rect.fromCenter(
            center: Offset(indicatorHorizontalCenter, indicatorOffset.dy),
            width: indicatorWidth,
            height: indicatorHeight,
          );
    }
    return () => Rect.fromLTRB(
          0,
          0,
          referenceBox.size.width,
          referenceBox.size.height,
        );
  }
}
