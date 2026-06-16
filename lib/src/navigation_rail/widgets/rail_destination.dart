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
  final bool extended;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

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
    final NavigationRailThemeData defaults = Theme.of(context).useMaterial3
        ? NavigationRailDefaultsM3(context)
        : NavigationRailDefaultsM2(context);
    final NavigationRailLabelType labelType =
        widget.labelType ?? railTheme.labelType ?? defaults.labelType!;

    final Animation<double> extendedAnimation = data.extendedAnimation;
    final bool collapsed = extendedAnimation.value == 0;

    // Indicator vertical centering when icon exceeds indicator height.
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
        final Widget iconPart = NavigationIcon(
          icon: data.themedIcon,
          minWidth: data.minWidth,
          material3: data.material3,
          direction: AutoLayoutDirection.horizontal,
        );
        if (collapsed) {
          content = Stack(
            children: <Widget>[
              iconPart,
              // Hidden label preserved for semantics.
              SizedBox.shrink(
                child: Visibility.maintain(
                  visible: false,
                  child: widget.label,
                ),
              ),
            ],
          );
        } else {
          final Animation<double> labelFadeAnimation = extendedAnimation.drive(
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
                  _extendedAnimation.value,
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
        final double indicatorVerticalPadding = data.destinationPadding.top;
        indicatorOffset = Offset(
          data.minWidth / 2 + indicatorHorizontalPadding,
          indicatorVerticalPadding + indicatorVerticalOffset,
        );
        if (data.minWidth < NavigationRailDefaultsM2(context).minWidth!) {
          indicatorOffset = Offset(
            data.minWidth / 2 + _horizontalDestinationSpacingM3,
            indicatorVerticalPadding + indicatorVerticalOffset,
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
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: data.material3 ? 0 : verticalPadding),
                Row(
                  children: [
                    data.themedIcon,
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
                  ],
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
        final double indicatorVerticalPadding = data.destinationPadding.top;
        indicatorOffset = Offset(
          data.minWidth / 2 + indicatorHorizontalPadding,
          indicatorVerticalPadding + indicatorVerticalOffset,
        );
        if (data.minWidth < NavigationRailDefaultsM2(context).minWidth!) {
          indicatorOffset = Offset(
            data.minWidth / 2 + _horizontalDestinationSpacingM3,
            indicatorVerticalPadding + indicatorVerticalOffset,
          );
        }

        content = Container(
          constraints: BoxConstraints(
            minWidth: data.minWidth,
            minHeight: minHeight,
          ),
          padding: widget.padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height:
                    data.material3 ? 0 : _verticalDestinationPaddingWithLabel,
              ),
              Wrap(
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  data.themedIcon,
                  SizedBox(
                    height: data.material3 ? _verticalIconLabelSpacingM3 : 0,
                  ),
                  data.styledLabel,
                ],
              ),
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
      indicatorShape: data.indicatorShape,
      material3: data.material3,
      indicatorOffset: indicatorOffset,
      applyXOffset: applyXOffset,
      textDirection: data.textDirection,
      splashColor: data.splashColor,
      hoverColor: data.hoverColor,
      child: content,
    );
  }
}
