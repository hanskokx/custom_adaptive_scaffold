part of "../navigation_bar_destination.dart";

/// Widget that handles the semantics and layout of a navigation bar
/// destination.
///
/// Prefer [NavigationDestination] over this widget, as it is a simpler
/// (although less customizable) way to get navigation bar destinations.
///
/// The icon and label of this destination are built with [buildIcon] and
/// [buildLabel]. They should build the unselected and selected icon and label
/// according to [NavigationDestinationInfo.selectedAnimation], where an
/// animation value of 0 is unselected and 1 is selected.
///
/// See [NavigationDestination] for an example.
class _NavigationBarDestinationBuilder extends StatefulWidget {
  /// Builds a destination (icon + label) to use in a Material 3 [NavigationBar].
  const _NavigationBarDestinationBuilder({
    required this.buildIcon,
    required this.buildLabel,
    required this.label,
    required this.animation,
    super.key,
    this.color,
    this.shape,
    this.tooltip,
    this.disabled = false,
    this.padding = EdgeInsets.zero,
  });

  /// Builds the icon for a destination in a [NavigationBar].
  ///
  /// To animate between unselected and selected, build the icon based on
  /// [NavigationDestinationInfo.selectedAnimation]. When the animation is 0,
  /// the destination is unselected, when the animation is 1, the destination is
  /// selected.
  ///
  /// The destination is considered selected as soon as the animation is
  /// increasing or completed, and it is considered unselected as soon as the
  /// animation is decreasing or dismissed.
  final WidgetBuilder buildIcon;

  /// Builds the label for a destination in a [NavigationBar].
  ///
  /// To animate between unselected and selected, build the icon based on
  /// [NavigationDestinationInfo.selectedAnimation]. When the animation is
  /// 0, the destination is unselected, when the animation is 1, the destination
  /// is selected.
  ///
  /// The destination is considered selected as soon as the animation is
  /// increasing or completed, and it is considered unselected as soon as the
  /// animation is decreasing or dismissed.
  final WidgetBuilder buildLabel;

  /// The text value of what is in the label widget, this is required for
  /// semantics so that screen readers and tooltips can read the proper label.
  final Widget label;

  /// The text to display in the tooltip for this [NavigationDestination], when
  /// the user long presses the destination.
  ///
  /// If [tooltip] is an empty string, no tooltip will be used.
  ///
  /// Defaults to null, in which case the [label] text will be used.
  final String? tooltip;

  /// Indicates that this destination is unselectable.
  ///
  /// Defaults to false.
  final bool disabled;

  final Animation<double> animation;
  final Color? color;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry padding;

  @override
  State<_NavigationBarDestinationBuilder> createState() =>
      _NavigationBarDestinationBuilderState();
}

class _NavigationBarDestinationBuilderState
    extends State<_NavigationBarDestinationBuilder> {
  final GlobalKey itemKey = GlobalKey();
  final GlobalKey iconKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NavigationDestinationInfo info =
        NavigationDestinationInfo.of(context);
    final bool isDisabled = widget.disabled;

    final ThemeData theme = Theme.of(context);
    final CustomNavigationBarThemeData navigationBarTheme =
        NavigationBarTheme.maybeOf(context) ??
            const CustomNavigationBarThemeData();
    final CustomNavigationBarThemeData defaults = defaultsFor(context);
    final WidgetStateProperty<Color?>? effectiveNavigationItemOverlayColor =
        navigationBarTheme.navigationItemOverlayColor;
    final bool disableFullItemInk = effectiveNavigationItemOverlayColor == null;
    final ShapeBorder effectiveNavigationItemIndicatorShape =
        navigationBarTheme.navigationItemIndicatorShape ??
            navigationBarTheme.indicatorShape ??
            defaults.indicatorShape ??
            const StadiumBorder();
    final WidgetStateProperty<Color?>? fullItemOverlayColor =
        disableFullItemInk ? null : effectiveNavigationItemOverlayColor;
    final WidgetStateProperty<Color?>? iconOverlayColor =
        navigationBarTheme.overlayColor ?? defaults.overlayColor;

    final Color splashBase = navigationBarTheme.indicatorColor ??
        defaults.indicatorColor ??
        theme.colorScheme.secondaryContainer;
    final bool splashAlphaModified =
        (splashBase.a * 255.0).round().clamp(0, 255) < 255;
    final Color effectiveSplashColor =
        splashAlphaModified ? splashBase : splashBase.withValues(alpha: 0.12);
    final Color effectiveHoverColor =
        splashAlphaModified ? splashBase : splashBase.withValues(alpha: 0.04);
    final String labelText =
        widget.label is Text ? (widget.label as Text).data ?? "" : "";
    final String? tooltipMessage = widget.tooltip == null
        ? (labelText.isNotEmpty ? labelText : null)
        : (widget.tooltip!.isNotEmpty ? widget.tooltip : null);
    final Offset effectiveTooltipOffset =
        navigationBarTheme.tooltipOffset ?? const Offset(0, 42);
    final TooltipTriggerMode? effectiveTooltipTrigger =
        navigationBarTheme.tooltipTrigger;

    return _NavigationBarDestinationSemantics(
      enabled: !isDisabled,
      child: DestinationTooltip(
        message: tooltipMessage,
        tooltipOffset: effectiveTooltipOffset,
        tooltipTrigger: effectiveTooltipTrigger,
        child: ClipRect(
          // Inner Material provides an ink surface above the indicator fill,
          // so splash/hover renders on top of the pill rather than behind it.
          child: Material(
            type: MaterialType.transparency,
            child: _IndicatorInkWell(
              itemKey: itemKey,
              iconKey: iconKey,
              labelBehavior: info.labelBehavior,
              disableFullItemInk: disableFullItemInk,
              indicatorOverlayColor:
                  disableFullItemInk ? iconOverlayColor : null,
              overlayColor: fullItemOverlayColor,
              highlightColor: disableFullItemInk ? null : Colors.transparent,
              splashColor: disableFullItemInk
                  ? effectiveSplashColor
                  : Colors.transparent,
              hoverColor:
                  disableFullItemInk ? effectiveHoverColor : Colors.transparent,
              customBorder: effectiveNavigationItemIndicatorShape,
              onTap: isDisabled ? null : info.onTap,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  AnimatedBuilder(
                    animation: widget.animation,
                    builder: (context, child) => Row(
                      children: <Widget>[
                        Expanded(
                          child: _NavigationBarDestinationLayout(
                            icon: KeyedSubtree(
                              key: iconKey,
                              child: widget.buildIcon(context),
                            ),
                            itemKey: itemKey,
                            padding: widget.padding,
                            label: widget.buildLabel(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IndicatorInkWell extends InkResponse {
  const _IndicatorInkWell({
    required this.itemKey,
    required this.iconKey,
    required this.labelBehavior,
    required this.disableFullItemInk,
    this.indicatorOverlayColor,
    super.customBorder,
    super.highlightColor,
    super.splashColor,
    super.hoverColor,
    super.onTap,
    super.child,
    WidgetStateProperty<Color?>? overlayColor,
  }) : super(
          containedInkWell: true,
          highlightShape: BoxShape.rectangle,
          overlayColor:
              disableFullItemInk ? indicatorOverlayColor : overlayColor,
        );

  final GlobalKey itemKey;
  final GlobalKey iconKey;
  final NavigationDestinationLabelBehavior labelBehavior;
  final bool disableFullItemInk;
  final WidgetStateProperty<Color?>? indicatorOverlayColor;

  @override
  RectCallback? getRectCallback(RenderBox referenceBox) {
    return () {
      final GlobalKey targetKey =
          disableFullItemInk && iconKey.currentContext != null
              ? iconKey
              : itemKey;
      final RenderBox targetBox =
          targetKey.currentContext!.findRenderObject()! as RenderBox;
      final Rect targetRect =
          targetBox.localToGlobal(Offset.zero) & targetBox.size;
      return referenceBox.globalToLocal(targetRect.topLeft) & targetBox.size;
    };
  }
}
