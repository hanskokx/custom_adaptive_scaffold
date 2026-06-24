part of "../destination.dart";

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
    final CustomNavigationBarThemeData? navigationBarTheme =
        NavigationBarTheme.maybeOf(context);
    final CustomNavigationBarThemeData defaults =
        navigationBarDefaultsFor(context);
    final bool useEnhancedItemInk = theme.useMaterial3 &&
        (navigationBarTheme?.destinationOverlayColor != null ||
            navigationBarTheme?.destinationIndicatorShape != null);
    final ShapeBorder effectiveNavigationItemIndicatorShape =
        navigationBarTheme?.destinationIndicatorShape ??
            navigationBarTheme?.indicatorShape ??
            defaults.indicatorShape ??
            const StadiumBorder();

    final WidgetStateProperty<Color?>? iconOverlayColor =
        info.overlayColor ?? navigationBarTheme?.overlayColor;
    final WidgetStateProperty<Color?>? fullItemOverlayColor =
        navigationBarTheme?.destinationOverlayColor ?? iconOverlayColor;
    final String labelText =
        widget.label is Text ? (widget.label as Text).data ?? "" : "";
    final String? tooltipMessage = widget.tooltip == null
        ? (labelText.isNotEmpty ? labelText : null)
        : (widget.tooltip!.isNotEmpty ? widget.tooltip : null);
    final bool isSelected = info.index == info.selectedIndex;
    final bool isLabelVisible = switch (info.labelBehavior) {
      NavigationDestinationLabelBehavior.alwaysShow => true,
      NavigationDestinationLabelBehavior.onlyShowSelected => isSelected,
      NavigationDestinationLabelBehavior.alwaysHide => false,
    };
    final Offset effectiveTooltipOffset =
        navigationBarTheme?.tooltipOffset ?? const Offset(0, 42);
    final TooltipTriggerMode? effectiveTooltipTrigger = isLabelVisible
        ? navigationBarTheme?.tooltipTriggerWhenLabelVisible ??
            navigationBarTheme?.tooltipTrigger
        : navigationBarTheme?.tooltipTriggerWhenLabelHidden ??
            navigationBarTheme?.tooltipTrigger;

    return _NavigationBarDestinationSemantics(
      enabled: !isDisabled,
      child: DestinationTooltip(
        message: tooltipMessage,
        tooltipOffset: effectiveTooltipOffset,
        tooltipTrigger: effectiveTooltipTrigger,
        child: (useEnhancedItemInk
            ? _FullItemIndicatorInkWell(
                effectiveNavigationItemIndicatorShape:
                    effectiveNavigationItemIndicatorShape,
                fullItemOverlayColor: fullItemOverlayColor,
                isDisabled: isDisabled,
                info: info,
                isSelected: isSelected,
                iconKey: iconKey,
                itemKey: itemKey,
                child: _DestinationLayout(
                  buildIcon: widget.buildIcon,
                  buildLabel: widget.buildLabel,
                  iconKey: iconKey,
                  itemKey: itemKey,
                  padding: widget.padding,
                  animation: widget.animation,
                ),
              )
            : _FrameworkIndicatorInkWell(
                iconKey: iconKey,
                labelBehavior: info.labelBehavior,
                customBorder: info.indicatorShape ??
                    navigationBarTheme?.indicatorShape ??
                    defaults.indicatorShape,
                overlayColor: iconOverlayColor,
                onTap: isDisabled ? null : info.onTap,
                child: _DestinationLayout(
                  buildIcon: widget.buildIcon,
                  buildLabel: widget.buildLabel,
                  iconKey: iconKey,
                  itemKey: itemKey,
                  padding: widget.padding,
                  animation: widget.animation,
                ),
              )),
      ),
    );
  }
}

class _FullItemIndicatorInkWell extends StatelessWidget {
  const _FullItemIndicatorInkWell({
    required this.effectiveNavigationItemIndicatorShape,
    required this.fullItemOverlayColor,
    required this.isDisabled,
    required this.info,
    required this.isSelected,
    required this.iconKey,
    required this.itemKey,
    required this.child,
  });

  final ShapeBorder effectiveNavigationItemIndicatorShape;
  final WidgetStateProperty<Color?>? fullItemOverlayColor;
  final bool isDisabled;
  final NavigationDestinationInfo info;
  final bool isSelected;
  final GlobalKey<State<StatefulWidget>> iconKey;
  final GlobalKey<State<StatefulWidget>> itemKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _DestinationClipper(
        shape: effectiveNavigationItemIndicatorShape,
      ),
      child: Material(
        child: InkResponse(
          containedInkWell: true,
          highlightShape: BoxShape.rectangle,
          overlayColor: fullItemOverlayColor,
          hoverColor: fullItemOverlayColor?.resolve({
            WidgetState.hovered,
          }),
          focusColor: fullItemOverlayColor?.resolve({
            WidgetState.focused,
          }),
          splashColor: fullItemOverlayColor?.resolve({
            WidgetState.pressed,
          }),
          onTap: isDisabled ? null : info.onTap,
          child: ColoredBox(
            color: isSelected
                ? fullItemOverlayColor?.resolve({WidgetState.selected}) ??
                    Colors.transparent
                : Colors.transparent,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _DestinationClipper extends CustomClipper<Path> {
  const _DestinationClipper({required this.shape});

  final ShapeBorder shape;

  @override
  Path getClip(Size size) {
    return shape.getOuterPath(Offset.zero & size);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return oldClipper != this;
  }
}

class _DestinationLayout extends StatelessWidget {
  const _DestinationLayout({
    required this.buildIcon,
    required this.buildLabel,
    required this.iconKey,
    required this.itemKey,
    required this.padding,
    required this.animation,
  });

  final Widget Function(BuildContext) buildIcon;
  final Widget Function(BuildContext) buildLabel;
  final GlobalKey iconKey;
  final GlobalKey itemKey;
  final EdgeInsetsGeometry padding;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) => Row(
            children: <Widget>[
              Expanded(
                child: _NavigationBarDestinationLayout(
                  icon: buildIcon(context),
                  iconKey: iconKey,
                  itemKey: itemKey,
                  padding: padding,
                  label: buildLabel(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FrameworkIndicatorInkWell extends InkResponse {
  const _FrameworkIndicatorInkWell({
    required this.iconKey,
    required this.labelBehavior,
    super.overlayColor,
    super.customBorder,
    super.onTap,
    super.child,
  }) : super(
          containedInkWell: true,
          highlightColor: Colors.transparent,
        );

  final GlobalKey iconKey;
  final NavigationDestinationLabelBehavior labelBehavior;

  @override
  RectCallback? getRectCallback(RenderBox referenceBox) {
    return () {
      final RenderBox iconBox =
          iconKey.currentContext!.findRenderObject()! as RenderBox;
      final Rect iconRect = iconBox.localToGlobal(Offset.zero) & iconBox.size;
      return referenceBox.globalToLocal(iconRect.topLeft) & iconBox.size;
    };
  }
}
