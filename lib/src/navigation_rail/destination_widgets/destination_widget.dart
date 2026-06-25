part of "../navigation_rail.dart";

// Layout spacing constants — kept here so the rail layout code can reference
// them without a cross-module import.
const double _kIndicatorHeight = 32.0;
const double _horizontalDestinationPadding = 8.0;
const double _verticalDestinationPaddingNoLabel = 24.0;
const double _verticalDestinationPaddingWithLabel = 16.0;
const Widget _verticalSpacer = SizedBox(height: 8.0);
const double _verticalIconLabelSpacingM3 = 4.0;
const double _verticalDestinationSpacingM3 = 12.0;
const double _horizontalDestinationSpacingM3 = 12.0;
const double _kRailIndicatorWidth = 56.0;
const double _kRailIconSlotHeight = 44.0;

class RailDestination extends StatefulWidget {
  const RailDestination({
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
    this.extended = true,
    this.showLabelsWhenCollapsed = false,
    this.padding,
    this.margin,
    this.tooltip,
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
  final bool extended;
  final bool showLabelsWhenCollapsed;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final String? tooltip;

  @override
  State<RailDestination> createState() => _RailDestinationState();
}

class _RailDestinationState extends State<RailDestination>
    with TickerProviderStateMixin {
  late CurvedAnimation _positionAnimation;
  late Animation<double> _destinationAnimation;
  late AnimationController _extendedController;
  late CurvedAnimation _extendedAnimation;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _setPositionAnimation();
  }

  @override
  void didUpdateWidget(RailDestination oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.destinationAnimation != oldWidget.destinationAnimation) {
      _positionAnimation.dispose();
      _setPositionAnimation();
    }
  }

  void _initControllers() {
    _destinationAnimation = widget.destinationAnimation ??
        AnimationController(
          duration: kThemeAnimationDuration,
          vsync: this,
        )
      ..addListener(() {
        setState(() {});
      });

    _extendedController = AnimationController(
      duration: kThemeAnimationDuration,
      vsync: this,
      value: widget.extended ? 1.0 : 0.0,
    );

    _extendedAnimation = CurvedAnimation(
      parent: _extendedController,
      curve: Curves.easeInOut,
    );

    _extendedController.addListener(() {
      setState(() {});
    });
  }

  void _setPositionAnimation() {
    _positionAnimation = CurvedAnimation(
      parent: ReverseAnimation(_destinationAnimation),
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut.flipped,
    );
  }

  @override
  void dispose() {
    _extendedAnimation.dispose();
    _extendedController.dispose();
    _positionAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Resolve all theming via the shared rail strategy.
    final DestinationBuildData data = const RailDestinationStrategy().resolve(
      context,
      DestinationResolveInput(
        icon: widget.icon,
        label: widget.label,
        selected: widget.selected ?? false,
        disabled: widget.disabled,
        destinationAnimation: _destinationAnimation,
        extendedTransitionAnimation:
            widget.extendedTransitionAnimation ?? _extendedAnimation,
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

    // Label type is a layout-level concern, resolved here after theming.
    final NavigationRailThemeData railTheme = NavigationRailTheme.of(context);
    final NavigationRailThemeData defaults = navigationRailDefaultsFor(context);
    final NavigationRailLabelType labelType =
        widget.labelType ?? railTheme.labelType ?? defaults.labelType!;

    final Animation<double> extendedAnimation = data.extendedAnimation;
    final bool collapsed = extendedAnimation.value == 0;
    final bool isLabelVisible = switch (labelType) {
      NavigationRailLabelType.none =>
        !collapsed || widget.showLabelsWhenCollapsed,
      NavigationRailLabelType.selected => widget.selected ?? false,
      NavigationRailLabelType.all => true,
    };
    final TooltipTriggerMode? effectiveTooltipTrigger = isLabelVisible
        ? railTheme.tooltipTriggerWhenLabelVisible ?? railTheme.tooltipTrigger
        : railTheme.tooltipTriggerWhenLabelHidden ?? railTheme.tooltipTrigger;

    // Indicator vertical centering when icon exceeds indicator height.
    final double largeIconIndicatorCompensation =
        (data.resolvedIconSize! - _kIndicatorHeight)
            .clamp(0.0, double.infinity);

    final bool isLargeIconSize = data.resolvedIconSize != null &&
        data.resolvedIconSize! > _kIndicatorHeight;

    final double indicatorVerticalOffset =
        isLargeIconSize ? (data.resolvedIconSize! - _kIndicatorHeight) / 2 : 0;

    Offset indicatorOffset = data.indicatorOffset;

    bool applyXOffset = false;

    Widget content;

    switch (labelType) {
      // Compact — label is hidden, icon is centered vertically.
      case NavigationRailLabelType.none:
        // indicatorOffset from the strategy is already correct for this case.
        final double compactIndicatorHorizontalPadding =
            collapsed ? 0.0 : data.destinationPadding.left;
        final double compactIndicatorVerticalPadding =
            collapsed ? 0.0 : data.destinationPadding.top;
        indicatorOffset = Offset(
          compactIndicatorHorizontalPadding + (data.minWidth / 2),
          compactIndicatorVerticalPadding +
              (_kRailIconSlotHeight / 2) +
              indicatorVerticalOffset,
        );

        final Widget iconPart = NavigationIcon(
          height: (data.material3 ? _kRailIconSlotHeight : data.minWidth) +
              largeIconIndicatorCompensation,
          icon: data.themedIcon,
          minWidth: data.minWidth,
          material3: data.material3,
          direction: Axis.horizontal,
        );
        if (collapsed) {
          if (widget.showLabelsWhenCollapsed) {
            // Label is visible: switch to a proper column layout so the label
            // sits below the icon and the indicator stays centred over the
            // icon slot.  Recompute indicatorOffset the same way .all does.
            final double indicatorHorizontalPadding =
                (data.destinationPadding.left / 2) -
                    (data.destinationPadding.right / 2);
            final double indicatorVerticalPadding =
                data.destinationPadding.top +
                    (data.material3 ? 0 : _verticalDestinationPaddingWithLabel);
            indicatorOffset = Offset(
              data.minWidth / 2 + indicatorHorizontalPadding,
              indicatorVerticalPadding +
                  (_kIndicatorHeight / 2) +
                  indicatorVerticalOffset,
            );
            if (data.minWidth < navigationRailMinWidthM2) {
              indicatorOffset = Offset(
                data.minWidth / 2 + _horizontalDestinationSpacingM3,
                indicatorVerticalPadding +
                    (_kIndicatorHeight / 2) +
                    indicatorVerticalOffset,
              );
            }
            content = Container(
              constraints: BoxConstraints(
                minWidth: data.minWidth,
              ),
              padding: widget.padding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: data.material3
                        ? 0
                        : _verticalDestinationPaddingWithLabel,
                  ),
                  SizedBox(
                    height: _kIndicatorHeight + largeIconIndicatorCompensation,
                    child: Center(child: data.themedIcon),
                  ),
                  SizedBox(
                    height: data.material3 ? _verticalIconLabelSpacingM3 : 0,
                  ),
                  data.styledLabel,
                  SizedBox(
                    height: data.material3
                        ? _verticalDestinationSpacingM3
                        : _verticalDestinationPaddingWithLabel,
                  ),
                ],
              ),
            );
          } else {
            // No label: compact icon-only stack.
            content = Padding(
              padding: widget.padding ?? EdgeInsets.zero,
              child: Stack(
                children: <Widget>[
                  iconPart,
                  // Label maintained at 0×0 for semantics only.
                  SizedBox.shrink(
                    child: Visibility.maintain(
                      visible: false,
                      child: data.styledLabel,
                    ),
                  ),
                ],
              ),
            );
          }
        } else {
          final Animation<double> labelFadeAnimation = extendedAnimation.drive(
            CurveTween(curve: const Interval(0.0, 0.25)),
          );
          final double minWidthTransitionValue = extendedAnimation.value;
          applyXOffset = true;
          content = Padding(
            padding: widget.padding ?? EdgeInsets.zero,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: lerpDouble(
                  data.minWidth,
                  data.minExtendedWidth,
                  minWidthTransitionValue,
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
                        widthFactor: extendedAnimation.value,
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
                          extendedAnimation.value,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

      // Selected — label appears below icon for the selected destination only.
      case NavigationRailLabelType.selected:
        final double appearingAnimationValue = 1 - _positionAnimation.value;
        final double verticalPadding = lerpDouble(
          _verticalDestinationPaddingNoLabel,
          _verticalDestinationPaddingWithLabel,
          appearingAnimationValue,
        )!;
        final Interval interval = (widget.selected ?? false)
            ? const Interval(0.25, 0.75)
            : const Interval(0.75, 1.0);
        final Animation<double> labelFadeAnimation =
            _destinationAnimation.drive(CurveTween(curve: interval));
        final double minHeight = data.material3 ? 0 : data.minWidth;

        final double indicatorHorizontalPadding =
            (data.destinationPadding.left / 2) -
                (data.destinationPadding.right / 2);
        final double indicatorVerticalPadding = data.destinationPadding.top +
            (data.material3 ? 0 : _verticalDestinationPaddingWithLabel);
        indicatorOffset = Offset(
          data.minWidth / 2 + indicatorHorizontalPadding,
          indicatorVerticalPadding +
              (_kIndicatorHeight / 2) +
              indicatorVerticalOffset,
        );
        if (data.minWidth < navigationRailMinWidthM2) {
          indicatorOffset = Offset(
            data.minWidth / 2 + _horizontalDestinationSpacingM3,
            indicatorVerticalPadding +
                (_kIndicatorHeight / 2) +
                indicatorVerticalOffset,
          );
        }

        content = Container(
          constraints: BoxConstraints(
            minWidth: data.minWidth,
            minHeight: minHeight,
          ),
          padding: widget.padding ??
              const EdgeInsets.symmetric(
                horizontal: _horizontalDestinationPadding,
              ),
          child: ClipRect(
            child: Column(
              mainAxisSize:
                  data.material3 ? MainAxisSize.min : MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: data.material3 ? 0 : verticalPadding),
                data.material3
                    ? SizedBox(
                        height:
                            _kIndicatorHeight + largeIconIndicatorCompensation,
                        child: Center(child: data.themedIcon),
                      )
                    : data.themedIcon,
                SizedBox(
                  height: data.material3
                      ? lerpDouble(
                          0,
                          _verticalIconLabelSpacingM3,
                          appearingAnimationValue,
                        )!
                      : 0,
                ),
                Align(
                  alignment: Alignment.topCenter,
                  heightFactor: appearingAnimationValue,
                  widthFactor: 1.0,
                  child: FadeTransition(
                    alwaysIncludeSemantics: true,
                    opacity: labelFadeAnimation,
                    child: data.styledLabel,
                  ),
                ),
                SizedBox(
                  height: data.material3
                      ? _verticalDestinationSpacingM3
                      : verticalPadding,
                ),
              ],
            ),
          ),
        );

      // All — label is always visible below the icon.
      case NavigationRailLabelType.all:
        final double minHeight = data.material3 ? 0 : data.minWidth;

        final double indicatorHorizontalPadding =
            (data.destinationPadding.left / 2) -
                (data.destinationPadding.right / 2);
        final double indicatorVerticalPadding = data.destinationPadding.top +
            (data.material3 ? 0 : _verticalDestinationPaddingWithLabel);
        indicatorOffset = Offset(
          data.minWidth / 2 + indicatorHorizontalPadding,
          indicatorVerticalPadding +
              (_kIndicatorHeight / 2) +
              indicatorVerticalOffset,
        );
        if (data.minWidth < navigationRailMinWidthM2) {
          indicatorOffset = Offset(
            data.minWidth / 2 + _horizontalDestinationSpacingM3,
            indicatorVerticalPadding +
                (_kIndicatorHeight / 2) +
                indicatorVerticalOffset,
          );
        }

        content = Container(
          constraints: BoxConstraints(
            minWidth: data.minWidth,
            minHeight: minHeight,
          ),
          padding: widget.padding ??
              const EdgeInsets.symmetric(
                horizontal: _horizontalDestinationPadding,
              ),
          child: Column(
            mainAxisSize: data.material3 ? MainAxisSize.min : MainAxisSize.max,
            children: <Widget>[
              SizedBox(
                height:
                    data.material3 ? 0 : _verticalDestinationPaddingWithLabel,
              ),
              data.material3
                  ? SizedBox(
                      height:
                          _kIndicatorHeight + largeIconIndicatorCompensation,
                      child: Center(child: data.themedIcon),
                    )
                  : data.themedIcon,
              SizedBox(
                height: data.material3 ? _verticalIconLabelSpacingM3 : 0,
              ),
              data.styledLabel,
              SizedBox(
                height: data.material3
                    ? _verticalDestinationSpacingM3
                    : _verticalDestinationPaddingWithLabel,
              ),
            ],
          ),
        );
    }

    return WrappedRailDestination(
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
      indicatorOffset: indicatorOffset,
      // Use Positioned.fill+Align.topCenter (centerIndicatorHorizontally=true)
      // whenever the icon is centred inside a column — i.e. every layout
      // except the extended/expanding none case where the label sits to the
      // right of the icon in a row.  That case is the only one that sets
      // applyXOffset=true, so tying the two flags together is exact.
      centerIndicatorHorizontally: !applyXOffset,
      applyXOffset: applyXOffset,
      textDirection: data.textDirection,
      splashColor: data.splashColor,
      hoverColor: data.hoverColor,
      selectionAnimation: _destinationAnimation,
      tooltipTrigger: effectiveTooltipTrigger,
      tooltip: widget.tooltip,
      child: content,
    );
  }
}
