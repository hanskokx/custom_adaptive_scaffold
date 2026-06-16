part of "../navigation_rail.dart";

class IndicatorInkWell extends InkResponse {
  const IndicatorInkWell({
    required this.useMaterial3,
    required this.indicatorOffset,
    required this.applyXOffset,
    required this.textDirection,
    required this.indicatorWidth,
    required this.disableFullItemInk,
    super.key,
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

  final bool useMaterial3;
  final Offset indicatorOffset;
  final bool applyXOffset;
  final TextDirection textDirection;
  final double indicatorWidth;
  final bool disableFullItemInk;

  static const double _indicatorHeight = 32.0;

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
            height: _indicatorHeight,
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
