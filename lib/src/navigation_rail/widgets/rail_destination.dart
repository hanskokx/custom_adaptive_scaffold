part of "../navigation_rail.dart";

const double _kIndicatorHeight = 32;

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

  bool mediumLargeIsActive(BuildContext context) =>
      const Breakpoint.mediumLarge().isActive(context);
  bool largeIsActive(BuildContext context) =>
      const Breakpoint.large().isActive(context);
  bool extraLargeIsActive(BuildContext context) =>
      const Breakpoint.extraLarge().isActive(context);
  bool mediumIsActive(BuildContext context) =>
      const Breakpoint.medium().isActive(context);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NavigationRailThemeData navigationRailTheme = NavigationRailTheme.of(
      context,
    );

    final NavigationRailThemeData defaults = Theme.of(context).useMaterial3
        ? NavigationRailDefaultsM3(context)
        : NavigationRailDefaultsM2(context);

    final bool useIndicator = widget.useIndicator ??
        navigationRailTheme.useIndicator ??
        defaults.useIndicator!;

    final Color? indicatorColor = useIndicator
        ? widget.indicatorColor ??
            navigationRailTheme.indicatorColor ??
            defaults.indicatorColor
        : null;

    final ShapeBorder? indicatorShape = useIndicator
        ? widget.indicatorShape ??
            navigationRailTheme.indicatorShape ??
            defaults.indicatorShape
        : null;

    assert(
      useIndicator || indicatorColor == null,
      "[NavigationRail.indicatorColor] does not have an effect when [NavigationRail.useIndicator] is false",
    );

    final Animation<double> extendedAnimation =
        widget.extendedTransitionAnimation ?? _extendedAnimation;

    final bool collapsed = extendedAnimation.value == 0;

    final TextDirection textDirection = Directionality.of(context);
    final bool material3 = theme.useMaterial3;

    late final EdgeInsets destinationPadding;
    late final EdgeInsets destinationMargin;

    destinationPadding =
        (widget.padding ?? navigationRailTheme.padding)?.resolve(
              textDirection,
            ) ??
            EdgeInsets.zero;
    destinationMargin =
        (widget.margin ?? navigationRailTheme.margin)?.resolve(textDirection) ??
            EdgeInsets.zero;

    Offset indicatorOffset;
    bool applyXOffset = false;

    final double paddingAndMarginWidth =
        destinationPadding.horizontal + destinationMargin.horizontal;
    final double minWidth =
        widget.minWidth ?? navigationRailTheme.minWidth ?? defaults.minWidth!;

    final double minExtendedWidth = (widget.minExtendedWidth ??
            navigationRailTheme.minExtendedWidth ??
            defaults.minExtendedWidth!) -
        paddingAndMarginWidth;

    final bool selected = widget.selected ?? false;

    final IconThemeData unselectedIconTheme =
        (selected ? null : widget.iconTheme) ??
            navigationRailTheme.unselectedIconTheme ??
            defaults.unselectedIconTheme!;
    final IconThemeData selectedIconTheme =
        (selected ? widget.iconTheme : null) ??
            navigationRailTheme.selectedIconTheme ??
            defaults.selectedIconTheme!;

    final TextStyle unselectedLabelTextStyle =
        (selected ? null : widget.labelTextStyle) ??
            navigationRailTheme.unselectedLabelTextStyle ??
            defaults.unselectedLabelTextStyle!;
    final TextStyle selectedLabelTextStyle =
        (selected ? widget.labelTextStyle : null) ??
            navigationRailTheme.selectedLabelTextStyle ??
            defaults.selectedLabelTextStyle!;

    final NavigationRailLabelType labelType = widget.labelType ??
        navigationRailTheme.labelType ??
        defaults.labelType!;

    final IconThemeData iconTheme =
        selected ? selectedIconTheme : unselectedIconTheme;

    final TextStyle labelTextStyle =
        selected ? selectedLabelTextStyle : unselectedLabelTextStyle;

    final Widget themedIcon = IconTheme(
      data: widget.disabled
          ? iconTheme.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
            )
          : iconTheme,
      child: widget.icon,
    );
    final Widget styledLabel = DefaultTextStyle(
      style: widget.disabled
          ? labelTextStyle.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
            )
          : labelTextStyle,
      child: widget.label,
    );

    Widget content;

    // The indicator height is fixed and equal to _kIndicatorHeight.
    // When the icon height is larger than the indicator height the indicator
    // vertical offset is used to vertically center the indicator.
    final bool isLargeIconSize =
        iconTheme.size != null && iconTheme.size! > _kIndicatorHeight;
    final double indicatorVerticalOffset =
        isLargeIconSize ? (iconTheme.size! - _kIndicatorHeight) / 2 : 0;

    switch (labelType) {
      // * Compact - The label is not shown, and the destination is centered vertically.
      // compact_navigation_rail_destination_layout.dart
      // _CompactRailDestinationLayout
      case NavigationRailLabelType.none:
        // Split the destination spacing across the top and bottom to keep the icon centered.
        final Widget? spacing = material3
            ? const SizedBox(height: _verticalDestinationSpacingM3 / 2)
            : null;
        indicatorOffset = Offset(
          minWidth / 2 + destinationPadding.left,
          _verticalDestinationSpacingM3 / 2 +
              destinationPadding.top +
              indicatorVerticalOffset,
        );
        final Widget iconPart = ConstrainedBox(
          constraints: BoxConstraints.tight(
            Size(minWidth, 44),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (spacing != null) spacing,
              Center(
                // _AddIndicator is only shown on selected menu items.
                child: themedIcon,
              ),
              if (spacing != null) spacing,
            ],
          ),
        );
        if (collapsed) {
          content = Stack(
            children: <Widget>[
              iconPart,
              // For semantics when label is not showing,
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
          // This is the content of an expanded nav item (i.e., with a label)
          content = Padding(
            padding: widget.padding ?? EdgeInsets.zero,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: lerpDouble(
                  minWidth,
                  minExtendedWidth,
                  _extendedAnimation.value,
                )!,
              ),
              child: ClipRect(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    iconPart,
                    // This is the text label
                    Flexible(
                      child: Align(
                        heightFactor: 1.0,
                        widthFactor: extendedAnimation.value,
                        alignment: AlignmentDirectional.centerStart,
                        child: FadeTransition(
                          alwaysIncludeSemantics: true,
                          opacity: labelFadeAnimation,
                          child: styledLabel,
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
      case NavigationRailLabelType.selected:
        final double appearingAnimationValue = 1 - _positionAnimation.value;
        final double verticalPadding = lerpDouble(
          _verticalDestinationPaddingNoLabel,
          _verticalDestinationPaddingWithLabel,
          appearingAnimationValue,
        )!;
        final Interval interval =
            selected ? const Interval(0.25, 0.75) : const Interval(0.75, 1.0);
        final Animation<double> labelFadeAnimation =
            _destinationAnimation.drive(CurveTween(curve: interval));
        final double minHeight = material3 ? 0 : minWidth;

        final Widget topSpacing = SizedBox(
          height: material3 ? 0 : verticalPadding,
        );
        final Widget labelSpacing = SizedBox(
          height: material3
              ? lerpDouble(
                  0,
                  _verticalIconLabelSpacingM3,
                  appearingAnimationValue,
                )!
              : 0,
        );
        final Widget bottomSpacing = SizedBox(
          height: material3 ? _verticalDestinationSpacingM3 : verticalPadding,
        );
        final double indicatorHorizontalPadding =
            (destinationPadding.left / 2) - (destinationPadding.right / 2);
        final double indicatorVerticalPadding = destinationPadding.top;
        indicatorOffset = Offset(
          minWidth / 2 + indicatorHorizontalPadding,
          indicatorVerticalPadding + indicatorVerticalOffset,
        );
        if (minWidth < NavigationRailDefaultsM2(context).minWidth!) {
          indicatorOffset = Offset(
            minWidth / 2 + _horizontalDestinationSpacingM3,
            indicatorVerticalPadding + indicatorVerticalOffset,
          );
        }
        content = Container(
          constraints: BoxConstraints(
            minWidth: minWidth,
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
                topSpacing,
                Row(
                  children: [
                    themedIcon,
                    labelSpacing,
                    Align(
                      alignment: Alignment.topCenter,
                      heightFactor: appearingAnimationValue,
                      widthFactor: 1.0,
                      child: FadeTransition(
                        alwaysIncludeSemantics: true,
                        opacity: labelFadeAnimation,
                        child: styledLabel,
                      ),
                    ),
                  ],
                ),
                bottomSpacing,
              ],
            ),
          ),
        );
      case NavigationRailLabelType.all:
        final double minHeight = material3 ? 0 : minWidth;
        final Widget topSpacing = SizedBox(
          height: material3 ? 0 : _verticalDestinationPaddingWithLabel,
        );
        final Widget labelSpacing = SizedBox(
          height: material3 ? _verticalIconLabelSpacingM3 : 0,
        );
        final Widget bottomSpacing = SizedBox(
          height: material3
              ? _verticalDestinationSpacingM3
              : _verticalDestinationPaddingWithLabel,
        );
        final double indicatorHorizontalPadding =
            (destinationPadding.left / 2) - (destinationPadding.right / 2);
        final double indicatorVerticalPadding = destinationPadding.top;
        indicatorOffset = Offset(
          minWidth / 2 + indicatorHorizontalPadding,
          indicatorVerticalPadding + indicatorVerticalOffset,
        );
        if (minWidth < NavigationRailDefaultsM2(context).minWidth!) {
          indicatorOffset = Offset(
            minWidth / 2 + _horizontalDestinationSpacingM3,
            indicatorVerticalPadding + indicatorVerticalOffset,
          );
        }
        content = Container(
          constraints: BoxConstraints(
            minWidth: minWidth,
            minHeight: minHeight,
          ),
          padding: widget.padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              topSpacing,
              Wrap(
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  themedIcon,
                  labelSpacing,
                  styledLabel,
                ],
              ),
              bottomSpacing,
            ],
          ),
        );
    }

    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color splashColor =
        theme.navigationRailTheme.indicatorColor ?? colors.primary;
    final bool primaryColorAlphaModified = splashColor.a < 255.0;

    final Color effectiveSplashColor = primaryColorAlphaModified
        ? splashColor
        : splashColor.withValues(alpha: 0.12);
    final Color effectiveHoverColor = primaryColorAlphaModified
        ? splashColor
        : splashColor.withValues(alpha: 0.04);

    return Semantics(
      container: true,
      selected: widget.selected,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: <Widget>[
            /// This is the splash overlay when hovering over a
            /// [CustomNavigationDestination] in a [NavigationRail].
            _IndicatorInkWell(
              onTap: widget.disabled ? null : widget.onTap,
              borderRadius: BorderRadius.all(
                Radius.circular(minWidth / 2.0),
              ),
              customBorder: indicatorShape,
              splashColor: effectiveSplashColor,
              hoverColor: effectiveHoverColor,
              useMaterial3: material3,
              indicatorOffset: indicatorOffset,
              applyXOffset: applyXOffset,
              textDirection: textDirection,
              child: content,
            ),
            Semantics(
              label: widget.indexLabel,
            ),
          ],
        ),
      ),
    );
  }
}

// There don't appear to be tokens for these values, but they are
// shown in the spec.
const double _horizontalDestinationPadding = 8.0;
const double _verticalDestinationPaddingNoLabel = 24.0;
const double _verticalDestinationPaddingWithLabel = 16.0;
const Widget _verticalSpacer = SizedBox(height: 8.0);
const double _verticalIconLabelSpacingM3 = 4.0;
const double _verticalDestinationSpacingM3 = 12.0;
const double _horizontalDestinationSpacingM3 = 12.0;
