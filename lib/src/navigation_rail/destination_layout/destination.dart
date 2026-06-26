part of "../navigation_rail.dart";

/// Expanded layout used to render a single [NavigationRail] destination.
///
/// This widget builds the horizontally arranged destination content used when
/// the rail shows labels inline with the icon. It resolves the effective icon,
/// label styling, indicator configuration, and sizing from the surrounding
/// [NavigationRail] state and theme before delegating interaction and
/// semantics to [WrappedRailDestination].
class ExpandedRailDestination extends StatefulWidget {
  /// Creates an expanded rail destination.
  ///
  /// The [icon] and [label] are required.
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

  /// The minimum width of the collapsed destination region.
  ///
  /// If null, the value is resolved from the surrounding [NavigationRail]
  /// configuration or theme.
  final double? minWidth;

  /// The minimum width of the expanded destination region.
  ///
  /// If null, the value is resolved from the surrounding [NavigationRail]
  /// configuration or theme.
  final double? minExtendedWidth;

  /// The icon displayed for this destination.
  final Widget icon;

  /// The label displayed next to [icon].
  final Widget label;

  /// The selection animation driving this destination's visual state.
  ///
  /// If null, an internal animation controller is used.
  final Animation<double>? destinationAnimation;

  /// The label behavior for the surrounding [NavigationRail].
  final NavigationRailLabelType? labelType;

  /// Whether this destination is currently selected.
  final bool? selected;

  /// The animation that tracks the rail's extended transition.
  final Animation<double>? extendedTransitionAnimation;

  /// The icon theme applied to [icon].
  final IconThemeData? iconTheme;

  /// The text style applied to [label].
  final TextStyle? labelTextStyle;

  /// Called when the destination is tapped.
  final VoidCallback? onTap;

  /// The semantic position label announced for assistive technologies.
  final String? indexLabel;

  /// Whether to show the selected indicator for this destination.
  ///
  /// If null, the value is resolved from the surrounding [NavigationRail]
  /// configuration or theme.
  final bool? useIndicator;

  /// The color of the selected indicator.
  ///
  /// If null, the value is resolved from the surrounding [NavigationRail]
  /// configuration or theme.
  final Color? indicatorColor;

  /// The shape of the selected indicator.
  ///
  /// If null, the value is resolved from the surrounding [NavigationRail]
  /// configuration or theme.
  final ShapeBorder? indicatorShape;

  /// Whether this destination is disabled.
  ///
  /// Disabled destinations do not respond to taps and are styled as inactive.
  final bool disabled;

  /// Padding applied inside the destination's content area.
  final EdgeInsetsGeometry? padding;

  /// External margin associated with this destination.
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
      indicatorWidth: _kRailIndicatorWidth,
      indicatorColor: data.indicatorColor,
      indicatorShape: data.indicatorShape,
      useIndicator: data.useIndicator,
      material3: data.material3,
      indicatorOffset: data.indicatorOffset,
      textDirection: data.textDirection,
      splashColor: data.splashColor,
      hoverColor: data.hoverColor,
      selectionAnimation: _destinationAnimation,
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
                  direction: Axis.horizontal,
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
