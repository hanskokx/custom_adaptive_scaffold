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
    this.destinationFillMode = NavigationDestinationFillMode.icon,
    this.destinationFillShape,
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
  final NavigationDestinationFillMode destinationFillMode;
  final ShapeBorder? destinationFillShape;
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
  late CurvedAnimation _positionAnimation;
  late Animation<double> _destinationAnimation;
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

    final bool collapsed = extendedAnimation.value == 0;

    final TextDirection textDirection = Directionality.of(context);
    final bool material3 = theme.useMaterial3;

    late final EdgeInsets destinationPadding;
    late final EdgeInsets destinationMargin;

    if (navigationRailTheme is CustomNavigationRailThemeData) {
      destinationPadding = (widget.padding ?? navigationRailTheme.padding)
          .resolve(textDirection);
      destinationMargin =
          (widget.margin ?? navigationRailTheme.margin).resolve(textDirection);
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

    final double minExtendedWidth = (widget.minExtendedWidth ??
            navigationRailTheme.minExtendedWidth ??
            defaults.minExtendedWidth!) -
        paddingAndMarginWidth;

    final bool selected = widget.selected ?? false;
    final NavigationDestinationFillMode destinationFillMode =
        widget.destinationFillMode;
    final bool isNoneFillMode =
        destinationFillMode == NavigationDestinationFillMode.none;
    final bool shouldPaintSelectedFill = selected && !isNoneFillMode;
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
    final Widget measuredLabel = KeyedSubtree(
      key: _labelRegionKey,
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

    switch (labelType) {
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
                child: SizedBox(
                  key: _iconRegionKey,
                  width: _kCircularIndicatorDiameter,
                  height: _kIndicatorHeight,
                  child: _AddIndicator(
                    addIndicator: false,
                    indicatorColor: indicatorColor,
                    indicatorShape: indicatorShape,
                    isCircular: !material3,
                    indicatorAnimation: _destinationAnimation,
                    child: animatedThemedIcon,
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
                      child: Align(
                        heightFactor: 1.0,
                        widthFactor: extendedAnimation.value,
                        alignment: AlignmentDirectional.centerStart,
                        child: FadeTransition(
                          alwaysIncludeSemantics: true,
                          opacity: labelFadeAnimation,
                          child: measuredLabel,
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
        final Widget topSpacing =
            SizedBox(height: material3 ? 0 : verticalPadding);
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
                    addIndicator: false,
                    indicatorColor: indicatorColor,
                    indicatorShape: indicatorShape,
                    isCircular: false,
                    indicatorAnimation: _destinationAnimation,
                    child: SizedBox(
                      key: _iconRegionKey,
                      width: _kCircularIndicatorDiameter,
                      height: _kIndicatorHeight,
                      child: Center(child: animatedThemedIcon),
                    ),
                  ),
                  labelSpacing,
                  Align(
                    alignment: Alignment.topCenter,
                    heightFactor: appearingAnimationValue,
                    widthFactor: 1.0,
                    child: FadeTransition(
                      alwaysIncludeSemantics: true,
                      opacity: labelFadeAnimation,
                      child: measuredLabel,
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
        final Widget labelSpacing =
            SizedBox(height: material3 ? _verticalIconLabelSpacingM3 : 0);
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
                  addIndicator: false,
                  indicatorColor: indicatorColor,
                  indicatorShape: indicatorShape,
                  isCircular: false,
                  indicatorAnimation: _destinationAnimation,
                  child: SizedBox(
                    key: _iconRegionKey,
                    width: _kCircularIndicatorDiameter,
                    height: _kIndicatorHeight,
                    child: Center(child: animatedThemedIcon),
                  ),
                ),
                labelSpacing,
                measuredLabel,
                bottomSpacing,
              ],
            ),
          ),
        );
    }

    final ShapeBorder defaultFillShape =
        destinationFillMode == NavigationDestinationFillMode.full
            ? const RoundedRectangleBorder()
            : const StadiumBorder();
    final ShapeBorder effectiveFillShape =
        widget.destinationFillShape ?? indicatorShape ?? defaultFillShape;
    final ShapeBorder effectiveInkShape = effectiveFillShape;
    final bool hasVisibleText =
        labelType != NavigationRailLabelType.none || !collapsed;
    final bool isNoneMode =
        destinationFillMode == NavigationDestinationFillMode.none;

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
                    mode: destinationFillMode,
                    useMaterial3: material3,
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
              customBorder: isNoneMode ? null : effectiveInkShape,
              splashColor: effectiveSplashColor,
              hoverColor: effectiveHoverColor,
              useMaterial3: material3,
              indicatorOffset: indicatorOffset,
              applyXOffset: applyXOffset,
              destinationFillMode: destinationFillMode,
              textDirection: textDirection,
              hasVisibleText: hasVisibleText,
              iconRegionKey: _iconRegionKey,
              labelRegionKey: _labelRegionKey,
              fillPadding: destinationPadding,
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

class _IndicatorInkWell extends InkResponse {
  const _IndicatorInkWell({
    required this.useMaterial3,
    required this.indicatorOffset,
    required this.applyXOffset,
    required this.destinationFillMode,
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

  // The offset used to position Ink highlight.
  final Offset indicatorOffset;

  // Whether the horizontal offset from indicatorOffset should be used to position Ink highlight.
  // If true, Ink highlight uses the indicator horizontal offset. If false, Ink highlight is centered horizontally.
  final bool applyXOffset;

  // The text direction used to adjust the indicator horizontal offset.
  final TextDirection textDirection;

  // Where fill/highlight should be painted.
  final NavigationDestinationFillMode destinationFillMode;

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
          indicatorOffset: indicatorOffset,
          applyXOffset: applyXOffset,
          textDirection: textDirection,
          mode: destinationFillMode,
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
  required Offset indicatorOffset,
  required bool applyXOffset,
  required TextDirection textDirection,
  required NavigationDestinationFillMode mode,
  required bool hasVisibleText,
  required EdgeInsets fillPadding,
  RenderBox? referenceBox,
  GlobalKey? iconRegionKey,
  GlobalKey? labelRegionKey,
}) {
  final Rect fullRect = Offset.zero & size;
  if (mode == NavigationDestinationFillMode.full) {
    return fullRect;
  }

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
      (mode == NavigationDestinationFillMode.content ||
          mode == NavigationDestinationFillMode.label);
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
    case NavigationDestinationFillMode.none:
      return Rect.zero;
    case NavigationDestinationFillMode.icon:
      return expandAndClamp(
        effectiveIconRect,
        leftPadding: horizontalPadding,
        rightPadding: horizontalPadding,
      );
    case NavigationDestinationFillMode.content:
      if (!hasVisibleText) {
        return expandAndClamp(
          effectiveIconRect,
          leftPadding: horizontalPadding,
          rightPadding: horizontalPadding,
        );
      }
      final Rect combined = measuredLabelRect != null
          ? effectiveIconRect.expandToInclude(measuredLabelRect)
          : Rect.fromLTWH(
              effectiveIconRect.left,
              0,
              effectiveIconRect.width,
              size.height,
            );
      // Left inset is how far the pill left edge sits from the destination boundary.
      // Mirror that same inset on the right for visual symmetry.
      final double leftEdge =
          (combined.left - horizontalPadding).clamp(0.0, fullRect.right);
      final double rightEdge =
          (fullRect.right - leftEdge).clamp(leftEdge, fullRect.right);
      return Rect.fromLTRB(
        leftEdge,
        (combined.top - topPadding).clamp(0.0, fullRect.bottom),
        rightEdge,
        (combined.bottom + bottomPadding).clamp(0.0, fullRect.bottom),
      );
    case NavigationDestinationFillMode.label:
      if (!hasVisibleText) {
        return expandAndClamp(
          effectiveIconRect,
          leftPadding: horizontalPadding,
          rightPadding: horizontalPadding,
        );
      }
      // Start just past the icon's right edge — doesn't cover the icon but
      // leaves natural breathing room before the label text begins.
      final double labelLeft =
          effectiveIconRect.right.clamp(fullRect.left, fullRect.right);
      return Rect.fromLTRB(
        labelLeft,
        fullRect.top,
        fullRect.right,
        fullRect.bottom,
      );
    case NavigationDestinationFillMode.full:
      return fullRect;
  }
}

class _DestinationSelectionFill extends StatelessWidget {
  const _DestinationSelectionFill({
    required this.color,
    required this.shape,
    required this.mode,
    required this.useMaterial3,
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
  final NavigationDestinationFillMode mode;
  final bool useMaterial3;
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
    return CustomPaint(
      painter: _DestinationSelectionFillPainter(
        color: color,
        shape: shape,
        mode: mode,
        useMaterial3: useMaterial3,
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
    );
  }
}

class _DestinationSelectionFillPainter extends CustomPainter {
  const _DestinationSelectionFillPainter({
    required this.color,
    required this.shape,
    required this.mode,
    required this.useMaterial3,
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
  final NavigationDestinationFillMode mode;
  final bool useMaterial3;
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
