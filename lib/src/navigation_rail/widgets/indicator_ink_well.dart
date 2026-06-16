part of "../navigation_rail.dart";

class IndicatorInkWell extends InkResponse {
  const IndicatorInkWell({
    required this.useMaterial3,
    required this.indicatorOffset,
    required this.applyXOffset,
    required this.textDirection,
    super.key,
    super.child,
    super.onTap,
    super.statesController,
    ShapeBorder? customBorder,
    BorderRadius? borderRadius,
    super.splashColor,
    super.hoverColor,
    super.overlayColor,
  }) : super(
          containedInkWell: true,
          highlightShape: BoxShape.rectangle,
          borderRadius: useMaterial3 ? null : borderRadius,
          customBorder: useMaterial3 ? customBorder : null,
        );

  final bool useMaterial3;

  // The offset used to position Ink highlight.
  final Offset indicatorOffset;

  // Whether the horizontal offset from indicatorOffset should be used to position Ink highlight.
  // If true, Ink highlight uses the indicator horizontal offset. If false, Ink highlight is centered horizontally.
  final bool applyXOffset;

  // The text direction used to adjust the indicator horizontal offset.
  final TextDirection textDirection;

  @override
  RectCallback? getRectCallback(RenderBox referenceBox) {
    if (useMaterial3) {
      final double boxWidth = referenceBox.size.width;
      double indicatorHorizontalCenter =
          applyXOffset ? indicatorOffset.dx : boxWidth / 2;
      if (textDirection == TextDirection.rtl) {
        indicatorHorizontalCenter = boxWidth - indicatorHorizontalCenter;
      }
      return () {
        // Defines the bounds of the hover/splash rectangle
        return Rect.fromLTRB(
          0,
          0,
          referenceBox.size.width,
          referenceBox.size.height,
        );
      };
    }
    return null;
  }
}
