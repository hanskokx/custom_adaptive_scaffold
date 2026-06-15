part of "../navigation_rail.dart";

class CompactRailDestination extends _BaseRailDestination {
  const CompactRailDestination({
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
  State<CompactRailDestination> createState() => _CompactRailDestinationState();
}

class _CompactRailDestinationState
    extends _SharedRailDestinationState<CompactRailDestination> {
  @override
  Widget build(BuildContext context) {
    final _SharedRailDestinationBuildData data = resolveBuildData(context);
    final bool collapsed = data.extendedAnimation.value == 0;

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

    final bool applyXOffset;
    final Widget content;
    if (collapsed) {
      applyXOffset = false;
      content = Stack(
        children: <Widget>[
          iconPart,
          SizedBox.shrink(
            child: Visibility.maintain(
              visible: false,
              child: widget.label,
            ),
          ),
        ],
      );
    } else {
      final Animation<double> labelFadeAnimation = data.extendedAnimation.drive(
        CurveTween(curve: const Interval(0.0, 0.25)),
      );
      applyXOffset = true;
      content = Padding(
        padding: widget.padding ?? EdgeInsets.zero,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: lerpDouble(
              data.minWidth,
              data.minExtendedWidth,
              data.extendedAnimation.value,
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
                    widthFactor: data.extendedAnimation.value,
                    alignment: AlignmentDirectional.centerStart,
                    child: FadeTransition(
                      alwaysIncludeSemantics: true,
                      opacity: labelFadeAnimation,
                      child: data.styledLabel,
                    ),
                  ),
                ),
                SizedBox(
                  width: _horizontalDestinationPadding *
                      data.extendedAnimation.value,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return wrapDestination(
      data: data,
      applyXOffset: applyXOffset,
      child: content,
    );
  }
}
