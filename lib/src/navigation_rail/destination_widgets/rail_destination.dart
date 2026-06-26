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
const double _kDefaultIconSize = 24.0;

/// Builds a single [NavigationRail] destination across collapsed and extended
/// rail layouts.
///
/// This widget resolves the effective styling, indicator behavior, tooltip
/// behavior, and badge presentation for one destination before choosing the
/// appropriate layout for the current [NavigationRailLabelType].
class RailDestination extends StatefulWidget {
  /// Creates a rail destination.
  ///
  /// The [icon] and [label] are required.
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
    this.badge,
    this.badgeStyle = NavigationBadgeStyle.count,
    this.badgeLabel,
    this.customBadge,
    super.key,
  })  : assert(
          badge == null || badge > 0,
          "RailDestination.badge must be a positive integer.",
        ),
        assert(
          !(badge != null && badgeLabel != null),
          "badge and badgeLabel cannot both be set at the same time.",
        ),
        assert(
          !(badge != null && customBadge != null),
          "badge and customBadge cannot both be set at the same time.",
        ),
        assert(
          !(badgeLabel != null && customBadge != null),
          "badgeLabel and customBadge cannot both be set at the same time.",
        ),
        assert(
          customBadge == null ||
              badgeStyle == NavigationBadgeStyle.count ||
              badgeStyle == NavigationBadgeStyle.dot ||
              badgeStyle == NavigationBadgeStyle.hidden,
          "Only count, dot, and hidden styles may be combined with customBadge. "
          "exact applies to badge (int) only.",
        ),
        assert(
          badgeLabel == null ||
              badgeStyle == NavigationBadgeStyle.count ||
              badgeStyle == NavigationBadgeStyle.dot ||
              badgeStyle == NavigationBadgeStyle.hidden,
          "Only count, dot, and hidden styles may be combined with badgeLabel. "
          "exact applies to badge (int) only.",
        );

  /// The minimum width of the collapsed destination region.
  ///
  /// If null, the value is resolved from the surrounding [NavigationRail]
  /// configuration or theme.
  final double? minWidth;

  /// The minimum width of the extended destination region.
  ///
  /// If null, the value is resolved from the surrounding [NavigationRail]
  /// configuration or theme.
  final double? minExtendedWidth;

  /// The icon displayed for this destination.
  final Widget icon;

  /// The label associated with this destination.
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

  /// Whether the surrounding rail is currently extended.
  final bool extended;

  /// Whether labels remain visible when the rail is collapsed and [labelType]
  /// is [NavigationRailLabelType.none].
  final bool showLabelsWhenCollapsed;

  /// Padding applied inside the destination's content area.
  final EdgeInsetsGeometry? padding;

  /// External margin associated with this destination.
  final EdgeInsetsGeometry? margin;

  /// Tooltip text shown for this destination.
  final String? tooltip;

  /// Numeric badge count displayed on the destination icon.
  ///
  /// Must be greater than zero when provided.
  final int? badge;

  /// Controls how badge content is rendered for this destination.
  final NavigationBadgeStyle badgeStyle;

  /// Text badge content displayed on the destination icon.
  final String? badgeLabel;

  /// A fully custom [Badge] to display on the destination icon.
  final Badge? customBadge;

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
    final NavigationRailThemeData? maybeExplicitRailTheme =
        NavigationRailTheme.maybeOf(context);
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
        ((data.resolvedIconSize ?? _kDefaultIconSize) - _kDefaultIconSize)
            .clamp(0.0, double.infinity);
    final bool alignIndicatorToCustomLargeIconCenter =
        maybeExplicitRailTheme?.iconTheme != null;
    final double indicatorOffsetBaseline = alignIndicatorToCustomLargeIconCenter
        ? _kDefaultIconSize
        : _kIndicatorHeight;
    final bool isLargeIconSize = data.resolvedIconSize != null &&
        data.resolvedIconSize! > indicatorOffsetBaseline;

    final double indicatorVerticalOffset = isLargeIconSize
        ? (data.resolvedIconSize! - indicatorOffsetBaseline) / 2
        : 0;

    Offset indicatorOffset = data.indicatorOffset;

    // --- Badge ---
    final bool hasAnyBadge = widget.badge != null ||
        widget.badgeLabel != null ||
        widget.customBadge != null;
    Widget effectiveBadgedIcon;
    if (!hasAnyBadge || widget.badgeStyle == NavigationBadgeStyle.hidden) {
      // No badge, or hidden overrides all badge types.
      effectiveBadgedIcon = data.themedIcon;
    } else if (widget.badgeStyle == NavigationBadgeStyle.dot) {
      // Dot overrides all badge types — show a themed dot.
      final Widget badged = Badge(child: data.themedIcon);
      effectiveBadgedIcon = railTheme.badgeThemeData != null
          ? BadgeTheme(data: railTheme.badgeThemeData!, child: badged)
          : badged;
    } else if (widget.customBadge != null) {
      // User-provided Badge: reconstruct with icon as child. No BadgeTheme.
      final Badge b = widget.customBadge!;
      effectiveBadgedIcon = Badge(
        label: b.label,
        backgroundColor: b.backgroundColor,
        textColor: b.textColor,
        smallSize: b.smallSize,
        largeSize: b.largeSize,
        textStyle: b.textStyle,
        padding: b.padding,
        alignment: b.alignment,
        offset: b.offset,
        isLabelVisible: b.isLabelVisible,
        child: data.themedIcon,
      );
    } else if (widget.badgeLabel != null) {
      final Widget badged = Badge(
        label: Text(widget.badgeLabel!),
        child: data.themedIcon,
      );
      effectiveBadgedIcon = railTheme.badgeThemeData != null
          ? BadgeTheme(data: railTheme.badgeThemeData!, child: badged)
          : badged;
    } else {
      // badge != null, not dot/hidden — resolve numeric style.
      Widget? badgeLabel;
      if (widget.badgeStyle == NavigationBadgeStyle.count) {
        badgeLabel = Text(widget.badge! > 99 ? "99+" : "${widget.badge}");
      } else if (widget.badgeStyle == NavigationBadgeStyle.exact) {
        badgeLabel = Text("${widget.badge}");
      }
      final Widget badged = Badge(label: badgeLabel, child: data.themedIcon);
      effectiveBadgedIcon = railTheme.badgeThemeData != null
          ? BadgeTheme(data: railTheme.badgeThemeData!, child: badged)
          : badged;
    }

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
          icon: effectiveBadgedIcon,
          minWidth: data.minWidth,
          material3: data.material3,
          direction: Axis.horizontal,
        );
        if (collapsed) {
          if (widget.showLabelsWhenCollapsed) {
            // Label is visible: switch to a proper column layout so the label
            // sits below the icon and the indicator stays centered over the
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
                    child: Center(child: effectiveBadgedIcon),
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
                        child: Center(child: effectiveBadgedIcon),
                      )
                    : effectiveBadgedIcon,
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
                      child: Center(child: effectiveBadgedIcon),
                    )
                  : effectiveBadgedIcon,
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
      // whenever the icon is centered inside a column — i.e. every layout
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
