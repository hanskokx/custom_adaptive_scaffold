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
    extends _SharedRailDestinationState<ExpandedRailDestination> {
  @override
  Widget build(BuildContext context) {
    final _SharedRailDestinationBuildData data = resolveBuildData(context);

    final Widget? spacing = data.material3
        ? const SizedBox(height: _verticalDestinationSpacingM3 / 2)
        : null;
    final Widget iconPart = ConstrainedBox(
      constraints: BoxConstraints.tight(
        Size(data.minWidth, 44),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (spacing != null) spacing,
          Center(
            // _AddIndicator is only shown on selected menu items.
            child: data.themedIcon,
          ),
          if (spacing != null) spacing,
        ],
      ),
    );

    return wrapDestination(
      data: data,
      applyXOffset: true,
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
                iconPart,
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
