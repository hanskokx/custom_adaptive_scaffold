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
    required this.useIndicator,
    required this.material3,
    required this.indicatorOffset,
    required this.applyXOffset,
    required this.textDirection,
    required this.splashColor,
    required this.hoverColor,
    required this.selectionAnimation,
    required this.child,
    this.tooltipTrigger,
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
  final bool useIndicator;
  final bool material3;
  final Offset indicatorOffset;
  final bool centerIndicatorHorizontally;
  final bool applyXOffset;
  final TextDirection textDirection;
  final Color splashColor;
  final Color hoverColor;
  final Animation<double> selectionAnimation;
  final Widget child;
  final TooltipTriggerMode? tooltipTrigger;
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
    if (!mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final CustomNavigationRailThemeData? maybeExplicitRailTheme =
        NavigationRailTheme.maybeOf(context);
    final CustomNavigationRailThemeData railTheme =
        maybeExplicitRailTheme ?? const CustomNavigationRailThemeData();

    final WidgetStateProperty<Color?>? effectivedestinationOverlayColor =
        railTheme.destinationOverlayColor;
    final bool hasExplicitNavigationItemIndicatorShape =
        railTheme.destinationIndicatorShape != null;
    final bool hasExplicitCustomInkOverride =
        effectivedestinationOverlayColor != null ||
            hasExplicitNavigationItemIndicatorShape;
    final bool useFrameworkDefaultInk = !hasExplicitCustomInkOverride;
    final bool disableFullItemInk = useFrameworkDefaultInk ||
        (effectivedestinationOverlayColor == null &&
            !hasExplicitNavigationItemIndicatorShape);
    final Color onSurfaceColor = Theme.of(context).colorScheme.onSurface;
    final WidgetStateProperty<Color?> iconOverlayColor =
        WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.pressed) ||
          states.contains(WidgetState.focused)) {
        return onSurfaceColor.withValues(alpha: 0.12);
      }
      if (states.contains(WidgetState.hovered)) {
        return onSurfaceColor.withValues(alpha: 0.08);
      }
      return null;
    });
    final WidgetStateProperty<Color?> fullItemOverlayColor =
        WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.pressed) ||
          states.contains(WidgetState.focused)) {
        return widget.splashColor;
      }
      if (states.contains(WidgetState.hovered)) {
        return widget.hoverColor;
      }
      return null;
    });
    final WidgetStateProperty<Color?> effectiveInkOverlayColor =
        useFrameworkDefaultInk
            ? effectivedestinationOverlayColor ?? fullItemOverlayColor
            : (disableFullItemInk
                ? iconOverlayColor
                : effectivedestinationOverlayColor ?? fullItemOverlayColor);
    final ShapeBorder? effectiveNavigationItemIndicatorShape =
        useFrameworkDefaultInk
            ? (railTheme.destinationIndicatorShape ??
                railTheme.indicatorShape ??
                const StadiumBorder())
            : (disableFullItemInk
                ? null
                : railTheme.destinationIndicatorShape ??
                    railTheme.indicatorShape ??
                    const StadiumBorder());

    // M2 uses a circular 56x56 selected indicator; M3 uses the 56x32 pill.
    // Keep width clamped for narrow rails to match framework paint behavior.
    final double selectedIndicatorWidth = !widget.material3
        ? widget.indicatorWidth
        : (widget.minWidth < widget.indicatorWidth
            ? widget.minWidth
            : widget.indicatorWidth);

    const double kDefaultIconSize = 24.0;
    final double largeIconIndicatorCompensation =
        ((railTheme.iconTheme?.resolve({})?.size ?? 0) - kDefaultIconSize)
            .clamp(0.0, double.infinity);

    final double selectedIndicatorHeight = widget.material3
        ? _kIndicatorHeight + largeIconIndicatorCompensation
        : widget.indicatorWidth;
    final double indicatorCenteringHeight =
        widget.material3 ? selectedIndicatorHeight : _kIndicatorHeight;

    final Widget iconInteractionIndicator = widget.centerIndicatorHorizontally
        ? Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  top: widget.indicatorOffset.dy -
                      (indicatorCenteringHeight / 2),
                ),
                child: NavigationIndicator(
                  animation: widget.selectionAnimation,
                  color: widget.indicatorColor,
                  width: selectedIndicatorWidth,
                  height: selectedIndicatorHeight,
                  shape: widget.indicatorShape,
                ),
              ),
            ),
          )
        : Positioned.directional(
            textDirection: widget.textDirection,
            start: widget.indicatorOffset.dx - selectedIndicatorWidth / 2,
            top: widget.indicatorOffset.dy - (indicatorCenteringHeight / 2),
            child: NavigationIndicator(
              animation: widget.selectionAnimation,
              color: widget.indicatorColor,
              width: selectedIndicatorWidth,
              height: selectedIndicatorHeight,
              shape: widget.indicatorShape,
            ),
          );

    final Widget content = Stack(
      children: <Widget>[
        // Persistent indicator + icon interaction indicator.
        if (widget.useIndicator) iconInteractionIndicator,
        // Inner Material provides an ink surface above the indicator fill,
        // so splash/hover renders on top of the pill rather than behind it.
        Material(
          type: MaterialType.transparency,
          child: _IndicatorInkWell(
            onTap: widget.disabled ? null : widget.onTap,
            borderRadius: BorderRadius.all(
              Radius.circular(widget.minWidth / 2.0),
            ),
            customBorder: effectiveNavigationItemIndicatorShape,
            highlightColor: null,
            splashColor: disableFullItemInk ? null : Colors.transparent,
            hoverColor: disableFullItemInk ? null : Colors.transparent,
            overlayColor: effectiveInkOverlayColor,
            indicatorWidth: widget.indicatorWidth,
            disableFullItemInk: disableFullItemInk,
            useMaterial3: widget.material3,
            indicatorOffset: widget.indicatorOffset,
            applyXOffset: widget.applyXOffset,
            textDirection: widget.textDirection,
            statesController: _statesController,
            indicatorHeight:
                widget.material3 ? selectedIndicatorHeight : _kIndicatorHeight,
            child: widget.child,
          ),
        ),
        Semantics(
          label: widget.indexLabel,
        ),
      ],
    );

    return Semantics(
      container: true,
      selected: widget.selected,
      child: Material(
        type: MaterialType.transparency,
        child: DestinationTooltip(
          message: widget.tooltip,
          tooltipOffset: railTheme.tooltipOffset ?? const Offset(0, 24),
          tooltipTrigger: widget.tooltipTrigger,
          child: content,
        ),
      ),
    );
  }
}
