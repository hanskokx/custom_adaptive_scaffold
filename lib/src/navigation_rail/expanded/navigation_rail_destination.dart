part of "../navigation_rail.dart";

class ExpandedRailDestination extends _BaseRailDestination {
  const ExpandedRailDestination({
    required super.icon,
    required super.label,
    super.minWidth,
    super.minExtendedWidth,
    super.destinationAnimation,
    super.extendedTransitionAnimation,
    super.labelType,
    super.selected,
    super.iconTheme,
    super.labelTextStyle,
    super.onTap,
    super.indexLabel,
    super.useIndicator,
    super.indicatorColor,
    super.indicatorShape,
    super.disabled = false,
    super.padding,
    super.margin,
    super.key,
  });

  @override
  State<ExpandedRailDestination> createState() =>
      _ExpandedRailDestinationState();
}

class _ExpandedRailDestinationState
    extends _SharedNavigationDestinationState<ExpandedRailDestination> {
  @override
  Widget build(BuildContext context) {
    final RailDestinationBuildData data = resolveBuildData(context);

    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color splashColor =
        data.navigationRailTheme.indicatorColor ?? colors.primary;
    final bool primaryColorAlphaModified = splashColor.a < 255.0;

    final Color effectiveSplashColor = primaryColorAlphaModified
        ? splashColor
        : splashColor.withValues(alpha: 0.12);
    final Color effectiveHoverColor = primaryColorAlphaModified
        ? splashColor
        : splashColor.withValues(alpha: 0.04);

    return WrappedRailDestination(
      applyXOffset: true,
      selected: widget.selected,
      disabled: widget.disabled,
      onTap: widget.onTap,
      indexLabel: widget.indexLabel,
      minWidth: data.minWidth,
      indicatorShape: data.indicatorShape,
      material3: data.material3,
      indicatorOffset: data.indicatorOffset,
      textDirection: data.textDirection,
      splashColor: effectiveSplashColor,
      hoverColor: effectiveHoverColor,
      child: Padding(
        padding: widget.padding ?? EdgeInsets.zero,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: lerpDouble(
              data.minWidth,
              data.minExtendedWidth,
              1.0,
            )!,
          ),
          child: ClipRect(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                NavigationIcon(
                  type: NavigationType.rail,
                  data: data,
                ),
                Flexible(
                  child: Align(
                    heightFactor: 1.0,
                    widthFactor: 1.0,
                    alignment: AlignmentDirectional.centerStart,
                    child: data.styledLabel,
                  ),
                ),
                const SizedBox(
                  width: _horizontalDestinationPadding * 1.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
