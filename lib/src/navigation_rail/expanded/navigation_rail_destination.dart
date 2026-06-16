part of "../navigation_rail.dart";

class ExpandedRailDestination extends StatefulWidget {
  const ExpandedRailDestination({
    required this.icon,
    required this.label,
    this.minWidth,
    this.minExtendedWidth,
    this.destinationAnimation,
    this.extendedTransitionAnimation,
    this.labelType,
    this.selected,
    this.iconTheme,
    this.labelTextStyle,
    this.onTap,
    this.indexLabel,
    this.useIndicator,
    this.indicatorColor,
    this.indicatorShape,
    this.disabled = false,
    this.padding,
    this.margin,
    super.key,
  });

  final double? minWidth;
  final double? minExtendedWidth;
  final Widget icon;
  final Widget label;
  final Animation<double>? destinationAnimation;
  final NavigationRailLabelType? labelType;
  final bool? selected;
  final Animation<double>? extendedTransitionAnimation;
  final IconThemeData? iconTheme;
  final TextStyle? labelTextStyle;
  final VoidCallback? onTap;
  final String? indexLabel;
  final bool? useIndicator;
  final Color? indicatorColor;
  final ShapeBorder? indicatorShape;
  final bool disabled;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  State<ExpandedRailDestination> createState() =>
      _ExpandedRailDestinationState();
}

class _ExpandedRailDestinationState extends State<ExpandedRailDestination>
    with TickerProviderStateMixin {
  late AnimationController _destinationController;
  late Animation<double> _destinationAnimation;

  @override
  void initState() {
    super.initState();
    _destinationController = AnimationController(
      duration: kThemeAnimationDuration,
      vsync: this,
    )..addListener(() => setState(() {}));
    _destinationAnimation =
        widget.destinationAnimation ?? _destinationController.view;
  }

  @override
  void didUpdateWidget(ExpandedRailDestination oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.destinationAnimation != oldWidget.destinationAnimation) {
      _destinationAnimation =
          widget.destinationAnimation ?? _destinationController.view;
    }
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DestinationBuildData data = const RailDestinationStrategy().resolve(
      context,
      DestinationResolveInput(
        icon: widget.icon,
        label: widget.label,
        selected: widget.selected ?? false,
        disabled: widget.disabled,
        destinationAnimation: _destinationAnimation,
        extendedTransitionAnimation: widget.extendedTransitionAnimation,
        indicatorColor: widget.indicatorColor,
        indicatorShape: widget.indicatorShape,
        padding: widget.padding,
        margin: widget.margin,
        minWidth: widget.minWidth,
        minExtendedWidth: widget.minExtendedWidth,
        useIndicator: widget.useIndicator,
        iconTheme: widget.iconTheme,
        labelTextStyle: widget.labelTextStyle,
      ),
    );

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
      splashColor: data.splashColor,
      hoverColor: data.hoverColor,
      child: Padding(
        padding: widget.padding ?? EdgeInsets.zero,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: lerpDouble(data.minWidth, data.minExtendedWidth, 1.0)!,
          ),
          child: ClipRect(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                NavigationIcon(
                  icon: data.themedIcon,
                  minWidth: data.minWidth,
                  material3: data.material3,
                  direction: AutoLayoutDirection.horizontal,
                ),
                Flexible(
                  child: Align(
                    heightFactor: 1.0,
                    widthFactor: 1.0,
                    alignment: AlignmentDirectional.centerStart,
                    child: data.styledLabel,
                  ),
                ),
                const SizedBox(width: _horizontalDestinationPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
