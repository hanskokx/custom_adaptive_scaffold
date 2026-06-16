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
    required this.indicatorShape,
    required this.material3,
    required this.indicatorOffset,
    required this.applyXOffset,
    required this.textDirection,
    required this.splashColor,
    required this.hoverColor,
    required this.child,
    super.key,
  });

  final bool? selected;
  final bool disabled;
  final VoidCallback? onTap;
  final String? indexLabel;
  final double minWidth;
  final ShapeBorder? indicatorShape;
  final bool material3;
  final Offset indicatorOffset;
  final bool applyXOffset;
  final TextDirection textDirection;
  final Color splashColor;
  final Color hoverColor;
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
