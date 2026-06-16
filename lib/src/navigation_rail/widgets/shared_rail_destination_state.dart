part of "../navigation_rail.dart";

/// Stateless wrapper that applies the ink-well, indicator, semantics, and tap
/// handler around a rail destination's content widget.
///
/// All visually resolved data comes from [DestinationBuildData]; the caller
/// (typically [_RailDestinationState] or [_ExpandedRailDestinationState])
/// supplies the additional interaction-specific fields.
class WrappedRailDestination extends StatelessWidget {
  const WrappedRailDestination({
    required this.selected,
    required this.disabled,
    required this.onTap,
    required this.indexLabel,
    required this.minWidth,
    required this.indicatorWidth,
    required this.indicatorColor,
    required this.indicatorShape,
    required this.material3,
    required this.indicatorOffset,
    required this.applyXOffset,
    required this.textDirection,
    required this.splashColor,
    required this.hoverColor,
    required this.selectionAnimation,
    required this.child,
    this.centerIndicatorHorizontally = false,
    super.key,
  });

  final bool? selected;
  final bool disabled;
  final VoidCallback? onTap;
  final String? indexLabel;
  final double minWidth;
  final double indicatorWidth;
  final Color? indicatorColor;
  final ShapeBorder? indicatorShape;
  final bool material3;
  final Offset indicatorOffset;
  final bool centerIndicatorHorizontally;
  final bool applyXOffset;
  final TextDirection textDirection;
  final Color splashColor;
  final Color hoverColor;
  final Animation<double> selectionAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      selected: selected,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: <Widget>[
            // Persistent selection pill — rendered at the indicator center.
            if (indicatorColor != null)
              if (centerIndicatorHorizontally)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: indicatorOffset.dy - _kIndicatorHeight / 2,
                      ),
                      child: NavigationIndicator(
                        animation: selectionAnimation,
                        color: indicatorColor,
                        width: indicatorWidth,
                        height: _kIndicatorHeight,
                        shape: indicatorShape,
                      ),
                    ),
                  ),
                )
              else
                Positioned(
                  left: indicatorOffset.dx - indicatorWidth / 2,
                  top: indicatorOffset.dy - _kIndicatorHeight / 2,
                  child: NavigationIndicator(
                    animation: selectionAnimation,
                    color: indicatorColor,
                    width: indicatorWidth,
                    height: _kIndicatorHeight,
                    shape: indicatorShape,
                  ),
                ),
            IndicatorInkWell(
              onTap: disabled ? null : onTap,
              borderRadius: BorderRadius.all(
                Radius.circular(minWidth / 2.0),
              ),
              customBorder: indicatorShape,
              splashColor: splashColor,
              hoverColor: hoverColor,
              useMaterial3: material3,
              indicatorOffset: indicatorOffset,
              applyXOffset: applyXOffset,
              textDirection: textDirection,
              child: child,
            ),
            Semantics(
              label: indexLabel,
            ),
          ],
        ),
      ),
    );
  }
}
