part of "custom_navigation_rail.dart";

const double _kCircularIndicatorDiameter = 56;
const double _kIndicatorHeight = 32;

class RailDestination extends StatefulWidget {
  const RailDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
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
    this.destinationFillRegion,
    this.destinationHoverRegion,
    this.shape,
    this.disabled = false,
    this.extended = true,
    this.padding,
    this.margin,
    this.iconTransitionAnimation = NavigationDestinationAnimation.none,
    this.iconTransitionCurve = Curves.easeInOut,
    this.iconTransitionDuration,
    this.destinationTransitionBuilder,
    super.key,
  });

  final double? minWidth;
  final double? minExtendedWidth;
  final Widget icon;
  final Widget? selectedIcon;
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
  final NavigationDestinationRegion? destinationFillRegion;
  final NavigationDestinationRegion? destinationHoverRegion;
  final WidgetStateProperty<ShapeBorder?>? shape;
  final bool disabled;
  final bool extended;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final NavigationDestinationAnimation iconTransitionAnimation;
  final Curve iconTransitionCurve;
  final Duration? iconTransitionDuration;
  final NavigationDestinationTransitionBuilder? destinationTransitionBuilder;

  @override
  State<RailDestination> createState() => _RailDestinationState();
}

class _RailDestinationState extends State<RailDestination>
    with TickerProviderStateMixin {
  static const Set<WidgetState> _selectedState = <WidgetState>{
    WidgetState.selected,
  };
  static const Set<WidgetState> _selectedHoveredState = <WidgetState>{
    WidgetState.selected,
    WidgetState.hovered,
  };
  static const Set<WidgetState> _selectedPressedState = <WidgetState>{
    WidgetState.selected,
    WidgetState.pressed,
  };
  static const Set<WidgetState> _selectedFocusedState = <WidgetState>{
    WidgetState.selected,
    WidgetState.focused,
  };
  static const Set<WidgetState> _hoveredState = <WidgetState>{
    WidgetState.hovered,
  };
  static const Set<WidgetState> _pressedState = <WidgetState>{
    WidgetState.pressed,
  };
  static const Set<WidgetState> _focusedState = <WidgetState>{
    WidgetState.focused,
  };
  late CurvedAnimation _positionAnimation;
  late Animation<double> _destinationAnimation;
  AnimationController? _ownedDestinationController;
  late AnimationController _extendedController;
  late CurvedAnimation _extendedAnimation;
  final GlobalKey _destinationRegionKey = GlobalKey();
  final GlobalKey _iconRegionKey = GlobalKey();
  final GlobalKey _labelRegionKey = GlobalKey();

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
      _detachDestinationAnimation();
      _attachDestinationAnimation();
      _positionAnimation.dispose();
      _setPositionAnimation();
    }
  }

  void _initControllers() {
    _attachDestinationAnimation();

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
      if (mounted) setState(() {});
    });
  }

  void _attachDestinationAnimation() {
    if (widget.destinationAnimation != null) {
      _destinationAnimation = widget.destinationAnimation!;
      _ownedDestinationController = null;
    } else {
      final AnimationController controller = AnimationController(
        duration: kThemeAnimationDuration,
        vsync: this,
      );
      _ownedDestinationController = controller;
      _destinationAnimation = controller;
    }

    _destinationAnimation.addListener(_onDestinationAnimationTick);
  }

  void _detachDestinationAnimation() {
    _destinationAnimation.removeListener(_onDestinationAnimationTick);
    _ownedDestinationController?.dispose();
    _ownedDestinationController = null;
  }

  void _onDestinationAnimationTick() {
    if (mounted) {
      setState(() {});
    }
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
    _detachDestinationAnimation();
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
    final NavigationRailThemeData navigationRailTheme =
        CustomNavigationRailTheme.of(context);
    final NavigationRailThemeData defaults = Theme.of(context).useMaterial3
        ? _NavigationRailDefaultsM3(context)
        : _NavigationRailDefaultsM2(context);

    final Color? indicatorColor = widget.indicatorColor ??
        navigationRailTheme.indicatorColor ??
        defaults.indicatorColor;

    final ShapeBorder? indicatorShape = widget.indicatorShape ??
        navigationRailTheme.indicatorShape ??
        defaults.indicatorShape;

    final Animation<double> extendedAnimation =
        widget.extendedTransitionAnimation ?? _extendedAnimation;

    // When the rail is toggled from extended to collapsed, its outer width can
    // snap back to compact immediately while the destination animation is still
    // reversing. Treating non-extended destinations as collapsed avoids a
    // temporary horizontal overflow in that transition frame.
    final bool collapsed = !widget.extended || extendedAnimation.value == 0;

    final TextDirection textDirection = Directionality.of(context);
    final bool material3 = theme.useMaterial3;

    late final EdgeInsets destinationPadding;
    late final EdgeInsets destinationMargin;

    if (navigationRailTheme is CustomNavigationRailThemeData) {
      destinationPadding =
          (widget.padding ?? navigationRailTheme.padding ?? EdgeInsets.zero)
              .resolve(textDirection);
      destinationMargin =
          (widget.margin ?? navigationRailTheme.margin ?? EdgeInsets.zero)
              .resolve(textDirection);
    } else {
      destinationPadding =
          (widget.padding ?? EdgeInsets.zero).resolve(textDirection);
      destinationMargin =
          (widget.margin ?? EdgeInsets.zero).resolve(textDirection);
    }

    Offset indicatorOffset;
    bool applyXOffset = false;

    final double paddingAndMarginWidth =
        destinationPadding.horizontal + destinationMargin.horizontal;
    final double minWidth =
        widget.minWidth ?? navigationRailTheme.minWidth ?? defaults.minWidth!;

    final NavigationDestinationRegion? destinationFillRegion =
        widget.destinationFillRegion;
    final double minExtendedWidth = (widget.minExtendedWidth ??
            navigationRailTheme.minExtendedWidth ??
            defaults.minExtendedWidth!) -
        (destinationFillRegion == NavigationDestinationRegion.full
            ? 0
            : paddingAndMarginWidth);

    final bool selected = widget.selected ?? false;
    final NavigationDestinationRegion? destinationHoverRegion =
        widget.destinationHoverRegion ?? destinationFillRegion;
    final bool isDefaultFillPath = destinationFillRegion == null ||
        destinationFillRegion == NavigationDestinationRegion.icon;
    final bool isNoneFillMode =
        destinationFillRegion == NavigationDestinationRegion.none;
    final bool isNoneHoverMode =
        destinationHoverRegion == NavigationDestinationRegion.none;
    final bool usesLabelRegion =
        destinationFillRegion == NavigationDestinationRegion.label ||
            destinationHoverRegion == NavigationDestinationRegion.label;
    final bool isCustomFillMode = !isDefaultFillPath && !isNoneFillMode;
    final bool shouldPaintSelectedFill = selected && isCustomFillMode;
    final bool shouldShowIconIndicator =
        (widget.useIndicator ?? false) && isDefaultFillPath;
    final ShapeBorder? selectedStateShape =
        widget.shape?.resolve(_selectedState);
    final ShapeBorder? selectedHoverStateShape =
      widget.shape?.resolve(_selectedHoveredState);
    final ShapeBorder? selectedPressedStateShape =
      widget.shape?.resolve(_selectedPressedState);
    final ShapeBorder? selectedFocusedStateShape =
      widget.shape?.resolve(_selectedFocusedState);
    final ShapeBorder? effectiveSelectedHoverShape =
      selectedHoverStateShape == selectedStateShape
        ? null
        : selectedHoverStateShape;
    final ShapeBorder? effectiveSelectedPressedShape =
      selectedPressedStateShape == selectedStateShape
        ? null
        : selectedPressedStateShape;
    final ShapeBorder? effectiveSelectedFocusedShape =
      selectedFocusedStateShape == selectedStateShape
        ? null
        : selectedFocusedStateShape;
    final ShapeBorder? hoverStateShape =
      effectiveSelectedHoverShape ?? widget.shape?.resolve(_hoveredState);
    final ShapeBorder? pressedStateShape =
      effectiveSelectedPressedShape ?? widget.shape?.resolve(_pressedState);
    final ShapeBorder? focusedStateShape =
      effectiveSelectedFocusedShape ?? widget.shape?.resolve(_focusedState);
    final ShapeBorder effectiveIconIndicatorShape = selectedStateShape ??
        indicatorShape ??
        (destinationFillRegion == NavigationDestinationRegion.full
            ? const RoundedRectangleBorder()
            : const StadiumBorder());
    final Color? selectedFillColor = indicatorColor;

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
    final NavigationRailLabelType layoutLabelType =
        !collapsed ? NavigationRailLabelType.none : labelType;

    final IconThemeData iconTheme =
        selected ? selectedIconTheme : unselectedIconTheme;

    final TextStyle labelTextStyle =
        selected ? selectedLabelTextStyle : unselectedLabelTextStyle;

    final Widget unselectedThemedIcon = IconTheme(
      data: widget.disabled
          ? unselectedIconTheme.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
            )
          : unselectedIconTheme,
      child: widget.icon,
    );
    final Widget selectedThemedIcon = IconTheme(
      data: widget.disabled
          ? selectedIconTheme.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
            )
          : selectedIconTheme,
      child: widget.selectedIcon ?? widget.icon,
    );
    final Widget themedIcon =
        selected ? selectedThemedIcon : unselectedThemedIcon;
    final Duration effectiveTransitionDuration =
        widget.iconTransitionDuration ?? const Duration(milliseconds: 200);
    final Widget animatedThemedIcon = widget.destinationTransitionBuilder !=
            null
        ? widget.destinationTransitionBuilder!(
            context,
            _destinationAnimation,
            _destinationAnimation.isForwardOrCompleted,
            unselectedThemedIcon,
            selectedThemedIcon,
            DefaultTextStyle(
              style: widget.disabled
                  ? unselectedLabelTextStyle.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.38),
                    )
                  : unselectedLabelTextStyle,
              child: widget.label,
            ),
            DefaultTextStyle(
              style: widget.disabled
                  ? selectedLabelTextStyle.copyWith(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.38),
                    )
                  : selectedLabelTextStyle,
              child: widget.label,
            ),
          )
        : switch (widget.iconTransitionAnimation) {
            NavigationDestinationAnimation.none => themedIcon,
            NavigationDestinationAnimation.fadeSwap => AnimatedSwitcher(
                duration: effectiveTransitionDuration,
                switchInCurve: widget.iconTransitionCurve,
                switchOutCurve: widget.iconTransitionCurve,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: KeyedSubtree(
                  key: ValueKey<bool>(selected),
                  child: themedIcon,
                ),
              ),
            NavigationDestinationAnimation.scale => AnimatedSwitcher(
                duration: effectiveTransitionDuration,
                switchInCurve: widget.iconTransitionCurve,
                switchOutCurve: widget.iconTransitionCurve,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: KeyedSubtree(
                  key: ValueKey<bool>(selected),
                  child: themedIcon,
                ),
              ),
          };
    final Widget styledLabel = DefaultTextStyle(
      style: widget.disabled
          ? labelTextStyle.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
            )
          : labelTextStyle,
      child: widget.label,
    );
    final Widget measuredLabel = DestinationRegionBoundary(
      regionKey: _labelRegionKey,
      child: styledLabel,
    );

    Widget content;

    // The indicator height is fixed and equal to _kIndicatorHeight.
    // When the icon height is larger than the indicator height the indicator
    // vertical offset is used to vertically center the indicator.
    final bool isLargeIconSize =
        iconTheme.size != null && iconTheme.size! > _kIndicatorHeight;
    final double indicatorVerticalOffset =
        isLargeIconSize ? (iconTheme.size! - _kIndicatorHeight) / 2 : 0;
    final double iconSlotWidth = material3
        ? _kCircularIndicatorDiameter
        : (iconTheme.size ?? _kCircularIndicatorDiameter);
    final double iconSlotHeight = material3
        ? (isLargeIconSize ? iconTheme.size! : _kIndicatorHeight)
        : (iconTheme.size ?? _kIndicatorHeight);

    switch (layoutLabelType) {
      case NavigationRailLabelType.none:
        final Widget? spacing = material3
            ? const SizedBox(height: _verticalDestinationSpacingM3 / 2)
            : null;
        indicatorOffset = Offset(
          minWidth / 2 + destinationPadding.left,
          _verticalDestinationSpacingM3 / 2 +
              destinationPadding.top +
              indicatorVerticalOffset,
        );
        final Widget iconPart = Column(
          children: <Widget>[
            if (spacing != null) spacing,
            SizedBox(
              width: minWidth,
              height: material3 ? null : minWidth,
              child: Center(
                child: DestinationRegionBoundary(
                  regionKey: _iconRegionKey,
                  child: SizedBox(
                    width: iconSlotWidth,
                    height: iconSlotHeight,
                    child: _AddIndicator(
                      addIndicator: shouldShowIconIndicator,
                      indicatorColor: indicatorColor,
                      indicatorShape: effectiveIconIndicatorShape,
                      isCircular: !material3,
                      indicatorAnimation: _destinationAnimation,
                      child: animatedThemedIcon,
                    ),
                  ),
                ),
              ),
            ),
            if (spacing != null) spacing,
          ],
        );
        if (collapsed) {
          content = Padding(
            padding: widget.padding ?? EdgeInsets.zero,
            child: Stack(
              children: <Widget>[
                iconPart,
                SizedBox.shrink(
                  child: Visibility.maintain(
                    visible: false,
                    child: widget.label,
                  ),
                ),
              ],
            ),
          );
        } else {
          final bool showExpandedLabel = switch (labelType) {
            NavigationRailLabelType.none => true,
            NavigationRailLabelType.selected => selected,
            NavigationRailLabelType.all => true,
          };
          final Animation<double> labelFadeAnimation = extendedAnimation.drive(
            CurveTween(curve: const Interval(0.0, 0.25)),
          );
          applyXOffset = true;
          content = Padding(
            padding: widget.padding ?? EdgeInsets.zero,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: lerpDouble(
                  minWidth,
                  minExtendedWidth,
                  extendedAnimation.value,
                )!,
              ),
              child: ClipRect(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    iconPart,
                    Flexible(
                      child: showExpandedLabel
                          ? Align(
                              heightFactor: 1.0,
                              widthFactor: extendedAnimation.value,
                              alignment: AlignmentDirectional.centerStart,
                              child: FadeTransition(
                                alwaysIncludeSemantics: true,
                                opacity: labelFadeAnimation,
                                child: measuredLabel,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    SizedBox(
                      width: showExpandedLabel
                          ? _horizontalDestinationPadding *
                              extendedAnimation.value
                          : 0,
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
        final Widget topSpacing =
            SizedBox(height: material3 ? 0 : verticalPadding);
        final double labelSpacing = material3
            ? lerpDouble(
                  0,
                  _verticalIconLabelSpacingM3,
                  appearingAnimationValue,
                )! +
                (usesLabelRegion ? 4.0 : 0.0)
            : 0;
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
        if (minWidth < _NavigationRailDefaultsM2(context).minWidth!) {
          indicatorOffset = Offset(
            minWidth / 2 + _horizontalDestinationSpacingM3,
            indicatorVerticalPadding + indicatorVerticalOffset,
          );
        }
        content = ConstrainedBox(
          constraints: BoxConstraints(minWidth: minWidth, minHeight: minHeight),
          child: Padding(
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
                  _AddIndicator(
                    addIndicator: shouldShowIconIndicator,
                    indicatorColor: indicatorColor,
                    indicatorShape: effectiveIconIndicatorShape,
                    isCircular: false,
                    indicatorAnimation: _destinationAnimation,
                    child: DestinationRegionBoundary(
                      regionKey: _iconRegionKey,
                      child: SizedBox(
                        width: iconSlotWidth,
                        height: iconSlotHeight,
                        child: Center(child: animatedThemedIcon),
                      ),
                    ),
                  ),
                  SizedBox(height: labelSpacing),
                  Align(
                    alignment: Alignment.topCenter,
                    heightFactor: appearingAnimationValue,
                    widthFactor: 1.0,
                    child: FadeTransition(
                      alwaysIncludeSemantics: true,
                      opacity: labelFadeAnimation,
                      child: DestinationRegionBoundary(
                        regionKey: _labelRegionKey,
                        child: styledLabel,
                      ),
                    ),
                  ),
                  bottomSpacing,
                ],
              ),
            ),
          ),
        );
      case NavigationRailLabelType.all:
        final double minHeight = material3 ? 0 : minWidth;
        final Widget topSpacing = SizedBox(
          height: material3 ? 0 : _verticalDestinationPaddingWithLabel,
        );
        final double labelSpacing =
            (material3 ? _verticalIconLabelSpacingM3 : 0) +
                (usesLabelRegion ? 4.0 : 0.0);
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
        if (minWidth < _NavigationRailDefaultsM2(context).minWidth!) {
          indicatorOffset = Offset(
            minWidth / 2 + _horizontalDestinationSpacingM3,
            indicatorVerticalPadding + indicatorVerticalOffset,
          );
        }
        content = ConstrainedBox(
          constraints: BoxConstraints(minWidth: minWidth, minHeight: minHeight),
          child: Padding(
            padding: widget.padding ??
                const EdgeInsets.symmetric(
                  horizontal: _horizontalDestinationPadding,
                ),
            child: Column(
              children: <Widget>[
                topSpacing,
                _AddIndicator(
                  addIndicator: shouldShowIconIndicator,
                  indicatorColor: indicatorColor,
                  indicatorShape: effectiveIconIndicatorShape,
                  isCircular: false,
                  indicatorAnimation: _destinationAnimation,
                  child: DestinationRegionBoundary(
                    regionKey: _iconRegionKey,
                    child: SizedBox(
                      width: iconSlotWidth,
                      height: iconSlotHeight,
                      child: Center(child: animatedThemedIcon),
                    ),
                  ),
                ),
                SizedBox(height: labelSpacing),
                DestinationRegionBoundary(
                  regionKey: _labelRegionKey,
                  child: styledLabel,
                ),
                bottomSpacing,
              ],
            ),
          ),
        );
    }

    final ShapeBorder defaultFillShape =
        destinationFillRegion == NavigationDestinationRegion.full
            ? const RoundedRectangleBorder()
            : const StadiumBorder();
    final ShapeBorder effectiveFillShape =
        selectedStateShape ?? indicatorShape ?? defaultFillShape;
    final ShapeBorder effectiveInkShape = hoverStateShape ??
      pressedStateShape ??
      focusedStateShape ??
        selectedStateShape ??
        indicatorShape ??
        defaultFillShape;
    final bool hasVisibleText = !collapsed
        ? switch (labelType) {
            NavigationRailLabelType.none => false,
            NavigationRailLabelType.selected => selected,
            NavigationRailLabelType.all => true,
          }
        : switch (labelType) {
            NavigationRailLabelType.none => false,
            NavigationRailLabelType.selected => selected,
            NavigationRailLabelType.all => true,
          };

    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool primaryColorAlphaModified =
        (colors.primary.a * 255.0).round().clamp(0, 255) < 255;
    final Color effectiveSplashColor = primaryColorAlphaModified
        ? colors.primary
        : colors.primary.withValues(alpha: 0.12);
    final Color effectiveHoverColor = primaryColorAlphaModified
        ? colors.primary
        : colors.primary.withValues(alpha: 0.04);

    return Semantics(
      container: true,
      selected: widget.selected,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          key: _destinationRegionKey,
          children: <Widget>[
            if (shouldPaintSelectedFill && selectedFillColor != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: _DestinationSelectionFill(
                    color: selectedFillColor,
                    shape: effectiveFillShape,
                    animation: _destinationAnimation,
                    mode: destinationFillRegion,
                    useMaterial3: material3,
                    isCollapsed: collapsed,
                    indicatorOffset: indicatorOffset,
                    applyXOffset: applyXOffset,
                    textDirection: textDirection,
                    hasVisibleText: hasVisibleText,
                    destinationRegionKey: _destinationRegionKey,
                    iconRegionKey: _iconRegionKey,
                    labelRegionKey: _labelRegionKey,
                    fillPadding: destinationPadding,
                  ),
                ),
              ),

            /// This is the splash overlay when hovering over a
            /// [CustomNavigationDestination] in a [NavigationRail].
            _IndicatorInkWell(
              onTap: widget.disabled ? null : widget.onTap,
              borderRadius: BorderRadius.all(
                Radius.circular(minWidth / 2.0),
              ),
              customBorder: effectiveInkShape,
              splashColor: isNoneHoverMode ? null : effectiveSplashColor,
              hoverColor: isNoneHoverMode ? null : effectiveHoverColor,
              useMaterial3: material3,
              isCollapsed: collapsed,
              indicatorOffset: indicatorOffset,
              applyXOffset: applyXOffset,
              destinationHoverRegion: destinationHoverRegion,
              textDirection: textDirection,
              hasVisibleText: hasVisibleText,
              iconRegionKey: _iconRegionKey,
              labelRegionKey: _labelRegionKey,
              fillPadding: destinationPadding,
              child:
                  destinationFillRegion == NavigationDestinationRegion.full &&
                          !collapsed
                      ? SizedBox(
                          width: double.infinity,
                          child: Align(
                            alignment: AlignmentDirectional.topCenter,
                            child: Padding(
                              padding: const EdgeInsetsDirectional.only(
                                start: _horizontalDestinationSpacingM3,
                              ),
                              child: content,
                            ),
                          ),
                        )
                      : content,
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

class _IndicatorInkWell extends InkResponse {
  const _IndicatorInkWell({
    required this.useMaterial3,
    required this.isCollapsed,
    required this.indicatorOffset,
    required this.applyXOffset,
    required this.destinationHoverRegion,
    required this.textDirection,
    required this.hasVisibleText,
    required this.iconRegionKey,
    required this.labelRegionKey,
    required this.fillPadding,
    super.child,
    super.onTap,
    ShapeBorder? customBorder,
    BorderRadius? borderRadius,
    super.splashColor,
    super.hoverColor,
  }) : super(
          containedInkWell: true,
          highlightShape: BoxShape.rectangle,
          borderRadius: useMaterial3 ? null : borderRadius,
          customBorder: useMaterial3 ? customBorder : null,
        );

  final bool useMaterial3;
  final bool isCollapsed;

  // The offset used to position Ink highlight.
  final Offset indicatorOffset;

  // Whether the horizontal offset from indicatorOffset should be used to position Ink highlight.
  // If true, Ink highlight uses the indicator horizontal offset. If false, Ink highlight is centered horizontally.
  final bool applyXOffset;

  // The text direction used to adjust the indicator horizontal offset.
  final TextDirection textDirection;

  // Where hover/highlight should be painted.
  final NavigationDestinationRegion? destinationHoverRegion;

  // Whether text is currently visible in the destination.
  final bool hasVisibleText;

  // Keys used to resolve actual icon/label bounds.
  final GlobalKey iconRegionKey;
  final GlobalKey labelRegionKey;
  final EdgeInsets fillPadding;

  @override
  RectCallback? getRectCallback(RenderBox referenceBox) {
    return () => _destinationHighlightRect(
          size: referenceBox.size,
          useMaterial3: useMaterial3,
          isCollapsed: isCollapsed,
          indicatorOffset: indicatorOffset,
          applyXOffset: applyXOffset,
          textDirection: textDirection,
          mode: destinationHoverRegion,
          hasVisibleText: hasVisibleText,
          referenceBox: referenceBox,
          iconRegionKey: iconRegionKey,
          labelRegionKey: labelRegionKey,
          fillPadding: fillPadding,
        );
  }
}

Rect _destinationHighlightRect({
  required Size size,
  required bool useMaterial3,
  required bool isCollapsed,
  required Offset indicatorOffset,
  required bool applyXOffset,
  required TextDirection textDirection,
  required NavigationDestinationRegion? mode,
  required bool hasVisibleText,
  required EdgeInsets fillPadding,
  RenderBox? referenceBox,
  GlobalKey? iconRegionKey,
  GlobalKey? labelRegionKey,
}) {
  final Rect fullRect = Offset.zero & size;

  final double boxWidth = size.width;
  double indicatorHorizontalCenter =
      applyXOffset ? indicatorOffset.dx : boxWidth / 2;
  if (textDirection == TextDirection.rtl) {
    indicatorHorizontalCenter = boxWidth - indicatorHorizontalCenter;
  }

  final Rect iconRect = Rect.fromLTWH(
    indicatorHorizontalCenter - (_kCircularIndicatorDiameter / 2),
    indicatorOffset.dy,
    _kCircularIndicatorDiameter,
    _kIndicatorHeight,
  );
  final bool isDefaultFillPath =
      mode == null || mode == NavigationDestinationRegion.icon;
  if (isDefaultFillPath) {
    return iconRect;
  }
  final Rect? measuredIconRect = referenceBox != null && iconRegionKey != null
      ? _resolveRegionRect(iconRegionKey, referenceBox)
      : null;
  final Rect? measuredLabelRect = referenceBox != null && labelRegionKey != null
      ? _resolveRegionRect(labelRegionKey, referenceBox)
      : null;
  final Rect effectiveIconRect = measuredIconRect ?? iconRect;
  final bool hasExplicitHorizontalFillPadding =
      fillPadding.left > 0 || fillPadding.right > 0;
  final bool useFallbackHorizontalPadding = !hasExplicitHorizontalFillPadding &&
      (mode == NavigationDestinationRegion.content ||
          mode == NavigationDestinationRegion.label);
  final double horizontalPadding = useFallbackHorizontalPadding
      ? _horizontalDestinationPadding
      : fillPadding.left;
  final double topPadding = fillPadding.top;
  final double bottomPadding = fillPadding.bottom;

  Rect expandAndClamp(
    Rect rect, {
    double leftPadding = 0,
    double rightPadding = 0,
  }) {
    double left = rect.left - leftPadding;
    double right = rect.right + rightPadding;

    // Keep horizontal padding visually balanced near edges by shifting the
    // rect back inside bounds instead of clipping only one side.
    if (left < fullRect.left) {
      final double delta = fullRect.left - left;
      left += delta;
      right += delta;
    }
    if (right > fullRect.right) {
      final double delta = right - fullRect.right;
      left -= delta;
      right -= delta;
    }

    // If content is wider than available bounds, fall back to clamping.
    left = left.clamp(fullRect.left, fullRect.right);
    right = right.clamp(fullRect.left, fullRect.right);
    if (right < left) {
      right = left;
    }

    return Rect.fromLTRB(
      left,
      (rect.top - topPadding).clamp(0.0, fullRect.bottom),
      right,
      (rect.bottom + bottomPadding).clamp(0.0, fullRect.bottom),
    );
  }

  switch (mode) {
    case NavigationDestinationRegion.none:
      return Rect.zero;
    case NavigationDestinationRegion.icon:
      return iconRect;
    case NavigationDestinationRegion.content:
      if (!hasVisibleText) {
        return iconRect;
      }
      final Rect combined = measuredLabelRect != null
          ? effectiveIconRect.expandToInclude(measuredLabelRect)
          : Rect.fromLTWH(
              effectiveIconRect.left,
              0,
              effectiveIconRect.width,
              size.height,
            );
      if (isCollapsed) {
        return expandAndClamp(
          combined,
          leftPadding: horizontalPadding,
          rightPadding: horizontalPadding,
        );
      }
      // Keep hover content mode anchored to the icon region on the leading side.
      final double leftEdge = effectiveIconRect.left.clamp(0.0, fullRect.right);
      return Rect.fromLTRB(
        leftEdge,
        (combined.top - topPadding).clamp(0.0, fullRect.bottom),
        fullRect.right,
        (combined.bottom + bottomPadding).clamp(0.0, fullRect.bottom),
      );
    case NavigationDestinationRegion.label:
      if (!hasVisibleText) {
        return Rect.zero;
      }
      if (measuredLabelRect == null) {
        return Rect.zero;
      }
      final Rect labelBand = measuredLabelRect;
      final double leadingAnchor =
          isCollapsed ? effectiveIconRect.left : labelBand.left;
      final double left =
          (leadingAnchor - horizontalPadding).clamp(0.0, fullRect.right);
      final double right = fullRect.right;
      final double desiredTop = labelBand.center.dy - (_kIndicatorHeight / 2);
      double top = desiredTop;
      top = top.clamp(
        0.0,
        (fullRect.bottom - _kIndicatorHeight).clamp(0.0, fullRect.bottom),
      );
      final double bottom =
          (top + _kIndicatorHeight).clamp(0.0, fullRect.bottom);
      return Rect.fromLTRB(
        left,
        top,
        right,
        bottom,
      );
    case NavigationDestinationRegion.full:
      if (!isCollapsed) {
        return fullRect;
      }
      // For collapsed selected-label rails, keep full-width but avoid tall
      // full-height hover/fill on unselected items where label is hidden.
      // When no label region is measured (e.g. labelType.none), preserve
      // legacy full-destination behavior.
      if (measuredLabelRect == null) {
        return fullRect;
      }
      final Rect combined = hasVisibleText
          ? effectiveIconRect.expandToInclude(measuredLabelRect)
          : effectiveIconRect;
      return Rect.fromLTRB(
        fullRect.left,
        (combined.top - topPadding).clamp(0.0, fullRect.bottom),
        fullRect.right,
        (combined.bottom + bottomPadding).clamp(0.0, fullRect.bottom),
      );
  }
}

class _DestinationSelectionFill extends StatelessWidget {
  const _DestinationSelectionFill({
    required this.color,
    required this.shape,
    required this.animation,
    required this.mode,
    required this.useMaterial3,
    required this.isCollapsed,
    required this.indicatorOffset,
    required this.applyXOffset,
    required this.textDirection,
    required this.hasVisibleText,
    required this.destinationRegionKey,
    required this.iconRegionKey,
    required this.labelRegionKey,
    required this.fillPadding,
  });

  final Color color;
  final ShapeBorder shape;
  final Animation<double> animation;
  final NavigationDestinationRegion mode;
  final bool useMaterial3;
  final bool isCollapsed;
  final Offset indicatorOffset;
  final bool applyXOffset;
  final TextDirection textDirection;
  final bool hasVisibleText;
  final GlobalKey destinationRegionKey;
  final GlobalKey iconRegionKey;
  final GlobalKey labelRegionKey;
  final EdgeInsets fillPadding;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double scale = animation.isDismissed
            ? 0.0
            : Tween<double>(begin: .4, end: 1.0).transform(
                CurveTween(curve: Curves.easeInOutCubicEmphasized)
                    .transform(animation.value),
              );
        return Opacity(
          opacity: animation.value,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(scale, 1.0, 1.0),
            child: child,
          ),
        );
      },
      child: CustomPaint(
        painter: _DestinationSelectionFillPainter(
          color: color,
          shape: shape,
          mode: mode,
          useMaterial3: useMaterial3,
          isCollapsed: isCollapsed,
          indicatorOffset: indicatorOffset,
          applyXOffset: applyXOffset,
          textDirection: textDirection,
          hasVisibleText: hasVisibleText,
          destinationRegionKey: destinationRegionKey,
          iconRegionKey: iconRegionKey,
          labelRegionKey: labelRegionKey,
          fillPadding: fillPadding,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _DestinationSelectionFillPainter extends CustomPainter {
  const _DestinationSelectionFillPainter({
    required this.color,
    required this.shape,
    required this.mode,
    required this.useMaterial3,
    required this.isCollapsed,
    required this.indicatorOffset,
    required this.applyXOffset,
    required this.textDirection,
    required this.hasVisibleText,
    required this.destinationRegionKey,
    required this.iconRegionKey,
    required this.labelRegionKey,
    required this.fillPadding,
  });

  final Color color;
  final ShapeBorder shape;
  final NavigationDestinationRegion mode;
  final bool useMaterial3;
  final bool isCollapsed;
  final Offset indicatorOffset;
  final bool applyXOffset;
  final TextDirection textDirection;
  final bool hasVisibleText;
  final GlobalKey destinationRegionKey;
  final GlobalKey iconRegionKey;
  final GlobalKey labelRegionKey;
  final EdgeInsets fillPadding;

  @override
  void paint(Canvas canvas, Size size) {
    final RenderBox? destinationBox =
        _resolveReferenceBox(destinationRegionKey);
    final Rect rect = _destinationHighlightRect(
      size: size,
      useMaterial3: useMaterial3,
      isCollapsed: isCollapsed,
      indicatorOffset: indicatorOffset,
      applyXOffset: applyXOffset,
      textDirection: textDirection,
      mode: mode,
      hasVisibleText: hasVisibleText,
      fillPadding: fillPadding,
      referenceBox: destinationBox,
      iconRegionKey: iconRegionKey,
      labelRegionKey: labelRegionKey,
    );
    final Path path = shape.getOuterPath(rect, textDirection: textDirection);
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_DestinationSelectionFillPainter oldDelegate) {
    return color != oldDelegate.color ||
        shape != oldDelegate.shape ||
        mode != oldDelegate.mode ||
        useMaterial3 != oldDelegate.useMaterial3 ||
        isCollapsed != oldDelegate.isCollapsed ||
        indicatorOffset != oldDelegate.indicatorOffset ||
        applyXOffset != oldDelegate.applyXOffset ||
        textDirection != oldDelegate.textDirection ||
        hasVisibleText != oldDelegate.hasVisibleText ||
        destinationRegionKey != oldDelegate.destinationRegionKey ||
        iconRegionKey != oldDelegate.iconRegionKey ||
        labelRegionKey != oldDelegate.labelRegionKey ||
        fillPadding != oldDelegate.fillPadding;
  }
}

RenderBox? _resolveReferenceBox(GlobalKey key) {
  final BuildContext? context = key.currentContext;
  if (context == null) return null;
  final RenderObject? renderObject = context.findRenderObject();
  if (renderObject is! RenderBox || !renderObject.attached) return null;
  return renderObject;
}

Rect? _resolveRegionRect(GlobalKey key, RenderBox referenceBox) {
  final BuildContext? context = key.currentContext;
  if (context == null) return null;

  final RenderObject? renderObject = context.findRenderObject();
  if (renderObject is! RenderBox || !renderObject.attached) return null;

  final Offset topLeft = renderObject.localToGlobal(
    Offset.zero,
    ancestor: referenceBox,
  );
  return topLeft & renderObject.size;
}

/// When [addIndicator] is `true`, places [child] centered above a
/// [NavigationIndicator]; otherwise returns [child] unchanged.
class _AddIndicator extends StatelessWidget {
  const _AddIndicator({
    required this.addIndicator,
    required this.isCircular,
    required this.indicatorColor,
    required this.indicatorShape,
    required this.indicatorAnimation,
    required this.child,
  });

  final bool addIndicator;
  final bool isCircular;
  final Color? indicatorColor;
  final ShapeBorder? indicatorShape;
  final Animation<double> indicatorAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!addIndicator) {
      return child;
    }

    late final Widget indicator;
    if (isCircular) {
      indicator = NavigationIndicator(
        animation: indicatorAnimation,
        height: _kCircularIndicatorDiameter,
        width: _kCircularIndicatorDiameter,
        borderRadius: const BorderRadius.all(
          Radius.circular(_kCircularIndicatorDiameter / 2),
        ),
        color: indicatorColor,
      );
    } else {
      indicator = NavigationIndicator(
        animation: indicatorAnimation,
        width: _kCircularIndicatorDiameter,
        shape: indicatorShape,
        color: indicatorColor,
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[indicator, child],
    );
  }
}

class _ExtendedNavigationRailAnimation extends InheritedWidget {
  const _ExtendedNavigationRailAnimation({
    required this.animation,
    required super.child,
  });

  final Animation<double> animation;

  @override
  bool updateShouldNotify(_ExtendedNavigationRailAnimation old) =>
      animation != old.animation;
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

// Hand coded defaults based on Material Design 2.
class _NavigationRailDefaultsM2 extends NavigationRailThemeData {
  _NavigationRailDefaultsM2(BuildContext context)
      : _theme = Theme.of(context),
        _colors = Theme.of(context).colorScheme,
        super(
          elevation: 0,
          groupAlignment: -1,
          labelType: NavigationRailLabelType.none,
          useIndicator: false,
          minWidth: 72.0,
          minExtendedWidth: 256,
        );

  final ThemeData _theme;
  final ColorScheme _colors;

  @override
  Color? get backgroundColor => _colors.surface;

  @override
  TextStyle? get unselectedLabelTextStyle {
    return _theme.textTheme.bodyLarge!
        .copyWith(color: _colors.onSurface.withValues(alpha: 0.64));
  }

  @override
  TextStyle? get selectedLabelTextStyle {
    return _theme.textTheme.bodyLarge!.copyWith(color: _colors.primary);
  }

  @override
  IconThemeData? get unselectedIconTheme {
    return IconThemeData(
      size: 24.0,
      color: _colors.onSurface,
      opacity: 0.64,
    );
  }

  @override
  IconThemeData? get selectedIconTheme {
    return IconThemeData(
      size: 24.0,
      color: _colors.primary,
      opacity: 1.0,
    );
  }
}

// BEGIN GENERATED TOKEN PROPERTIES - NavigationRail

// Do not edit by hand. The code between the "BEGIN GENERATED" and
// "END GENERATED" comments are generated from data in the Material
// Design token database by the script:
//   dev/tools/gen_defaults/bin/gen_defaults.dart.

class _NavigationRailDefaultsM3 extends NavigationRailThemeData {
  _NavigationRailDefaultsM3(this.context)
      : super(
          elevation: 0.0,
          groupAlignment: -1,
          labelType: NavigationRailLabelType.none,
          useIndicator: true,
          minWidth: 80.0,
          minExtendedWidth: 256,
        );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => _colors.surface;

  @override
  TextStyle? get unselectedLabelTextStyle {
    return _textTheme.labelMedium!.copyWith(color: _colors.onSurface);
  }

  @override
  TextStyle? get selectedLabelTextStyle {
    return _textTheme.labelMedium!.copyWith(color: _colors.onSurface);
  }

  @override
  IconThemeData? get unselectedIconTheme {
    return IconThemeData(
      size: 24.0,
      color: _colors.onSurfaceVariant,
    );
  }

  @override
  IconThemeData? get selectedIconTheme {
    return IconThemeData(
      size: 24.0,
      color: _colors.onSecondaryContainer,
    );
  }

  @override
  Color? get indicatorColor => _colors.secondaryContainer;

  @override
  ShapeBorder? get indicatorShape => const StadiumBorder();
}

// END GENERATED TOKEN PROPERTIES - NavigationRail
