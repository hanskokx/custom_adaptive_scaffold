part of "../navigation_rail.dart";

/// Stateless wrapper that applies the ink-well, indicator, semantics, and tap
/// handler around a rail destination's content widget.
///
/// All visually resolved data comes from [DestinationBuildData]; the caller
/// (typically [_RailDestinationState] or [_ExpandedRailDestinationState])
/// supplies the additional interaction-specific fields.
class WrappedRailDestination extends StatefulWidget {
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
    this.tooltip,
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
  final String? tooltip;

  @override
  State<WrappedRailDestination> createState() => _WrappedRailDestinationState();
}

class _WrappedRailDestinationState extends State<WrappedRailDestination> {
  late final WidgetStatesController _statesController;

  @override
  void initState() {
    super.initState();
    _statesController = WidgetStatesController();
    _statesController.addListener(_handleStatesChanged);
  }

  @override
  void dispose() {
    _statesController.removeListener(_handleStatesChanged);
    _statesController.dispose();
    super.dispose();
  }

  void _handleStatesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final CustomNavigationRailThemeData railTheme =
        NavigationRailTheme.of(context);
    final WidgetStateProperty<Color?>? effectiveNavigationItemOverlayColor =
        railTheme.navigationItemOverlayColor;
    final bool disableFullItemInk = effectiveNavigationItemOverlayColor == null;
    final ShapeBorder effectiveNavigationItemIndicatorShape =
        railTheme.navigationItemIndicatorShape ?? const StadiumBorder();

    final Widget content = Stack(
      children: <Widget>[
        // Persistent selection pill — rendered at the indicator center.
        if (widget.indicatorColor != null)
          if (widget.centerIndicatorHorizontally)
            Positioned.fill(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: widget.indicatorOffset.dy - _kIndicatorHeight / 2,
                  ),
                  child: NavigationIndicator(
                    animation: widget.selectionAnimation,
                    color: widget.indicatorColor,
                    width: widget.indicatorWidth,
                    height: _kIndicatorHeight,
                    shape: widget.indicatorShape,
                    indicatorType: NavigationIndicatorType.navigationRail,
                    states: _statesController.value,
                  ),
                ),
              ),
            )
          else
            Positioned(
              left: widget.indicatorOffset.dx - widget.indicatorWidth / 2,
              top: widget.indicatorOffset.dy - _kIndicatorHeight / 2,
              child: NavigationIndicator(
                animation: widget.selectionAnimation,
                color: widget.indicatorColor,
                width: widget.indicatorWidth,
                height: _kIndicatorHeight,
                shape: widget.indicatorShape,
                indicatorType: NavigationIndicatorType.navigationRail,
                states: _statesController.value,
              ),
            ),
        IndicatorInkWell(
          onTap: widget.disabled ? null : widget.onTap,
          borderRadius: BorderRadius.all(
            Radius.circular(widget.minWidth / 2.0),
          ),
          customBorder: effectiveNavigationItemIndicatorShape,
          splashColor:
              disableFullItemInk ? Colors.transparent : widget.splashColor,
          hoverColor:
              disableFullItemInk ? Colors.transparent : widget.hoverColor,
          overlayColor: effectiveNavigationItemOverlayColor,
          useMaterial3: widget.material3,
          indicatorOffset: widget.indicatorOffset,
          applyXOffset: widget.applyXOffset,
          textDirection: widget.textDirection,
          statesController: _statesController,
          child: widget.child,
        ),
        Semantics(
          label: widget.indexLabel,
        ),
      ],
    );

    final Widget maybeTooltip =
        widget.tooltip != null && widget.tooltip!.isNotEmpty
            ? Tooltip(
                message: widget.tooltip!,
                excludeFromSemantics: true,
                preferBelow: false,
                child: content,
              )
            : content;

    return Semantics(
      container: true,
      selected: widget.selected,
      enabled: !widget.disabled,
      child: Material(
        type: MaterialType.transparency,
        child: maybeTooltip,
      ),
    );
  }
}
