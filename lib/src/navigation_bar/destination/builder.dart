part of "../destination.dart";

/// Widget that handles the semantics and layout of a navigation bar
/// destination.
class _NavigationBarDestinationBuilder extends StatefulWidget {
  const _NavigationBarDestinationBuilder({
    required this.buildIcon,
    required this.buildLabel,
    required this.label,
    required this.animation,
    required this.indicatorHeight,
    super.key,
    this.color,
    this.shape,
    this.tooltip,
    this.disabled = false,
    this.padding = EdgeInsets.zero,
  });

  final double indicatorHeight;
  final WidgetBuilder buildIcon;
  final WidgetBuilder buildLabel;
  final Widget label;
  final String? tooltip;
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
  late final WidgetStatesController _statesController =
      WidgetStatesController();

  @override
  void dispose() {
    _statesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NavigationDestinationInfo info =
        NavigationDestinationInfo.of(context);
    final bool isDisabled = widget.disabled;

    final ThemeData theme = Theme.of(context);
    final CustomNavigationBarThemeData? maybeNavigationBarTheme =
        NavigationBarTheme.maybeOf(context);
    final CustomNavigationBarThemeData navigationBarTheme =
        NavigationBarTheme.of(context);
    final CustomNavigationBarThemeData defaults =
        navigationBarDefaultsFor(context);

    final bool hasExplicitPackageDestinationOverlay =
        maybeNavigationBarTheme?.destinationOverlayColor != null;
    final bool hasExplicitPackageDestinationShape =
        maybeNavigationBarTheme?.destinationIndicatorShape != null;

    final bool useEnhancedItemInk = theme.useMaterial3 &&
        (hasExplicitPackageDestinationOverlay ||
            hasExplicitPackageDestinationShape);

    final ShapeBorder effectiveNavigationItemIndicatorShape =
        navigationBarTheme.destinationIndicatorShape ??
            navigationBarTheme.indicatorShape ??
            defaults.indicatorShape ??
            const StadiumBorder();

    final WidgetStateProperty<Color?>? iconOverlayColor =
        info.overlayColor ?? maybeNavigationBarTheme?.overlayColor;
    final WidgetStateProperty<Color?>? fullItemOverlayColor =
        maybeNavigationBarTheme?.overlayColor ??
            maybeNavigationBarTheme?.destinationOverlayColor ??
            iconOverlayColor;

    final String labelText =
        widget.label is Text ? (widget.label as Text).data ?? "" : "";
    final String? tooltipMessage = widget.tooltip == null
        ? (labelText.isNotEmpty ? labelText : null)
        : (widget.tooltip!.isNotEmpty ? widget.tooltip : null);

    final bool isSelected = info.index == info.selectedIndex;

// Retain WidgetState.selected for default Flutter behavior when custom properties aren't in use
    _statesController.value = {
      if (isDisabled) WidgetState.disabled,
      if (isSelected && widget.indicatorHeight == 32.0) WidgetState.selected,
    };

    final WidgetStateProperty<Color?> effectiveFrameworkOverlayColor =
        WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
      final Set<WidgetState> resolvedStates = {
        ...states,
        if (isDisabled) WidgetState.disabled,
      };
      return iconOverlayColor?.resolve(resolvedStates);
    });

    final bool isLabelVisible = switch (info.labelBehavior) {
      NavigationDestinationLabelBehavior.alwaysShow => true,
      NavigationDestinationLabelBehavior.onlyShowSelected => isSelected,
      NavigationDestinationLabelBehavior.alwaysHide => false,
    };
    final Offset effectiveTooltipOffset =
        navigationBarTheme.tooltipOffset ?? const Offset(0, 42);
    final TooltipTriggerMode? effectiveTooltipTrigger = isLabelVisible
        ? navigationBarTheme.tooltipTriggerWhenLabelVisible ??
            navigationBarTheme.tooltipTrigger
        : navigationBarTheme.tooltipTriggerWhenLabelHidden ??
            navigationBarTheme.tooltipTrigger;

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
                height: widget.indicatorHeight,
                statesController: _statesController,
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
                indicatorHeight: widget.indicatorHeight,
                statesController: _statesController,
                customBorder: info.indicatorShape ??
                    navigationBarTheme.indicatorShape ??
                    defaults.indicatorShape,
                overlayColor: effectiveFrameworkOverlayColor,
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
    required this.height,
    required this.statesController,
  });

  final ShapeBorder effectiveNavigationItemIndicatorShape;
  final WidgetStateProperty<Color?>? fullItemOverlayColor;
  final bool isDisabled;
  final NavigationDestinationInfo info;
  final bool isSelected;
  final GlobalKey<State<StatefulWidget>> iconKey;
  final GlobalKey<State<StatefulWidget>> itemKey;
  final Widget child;
  final double height;
  final WidgetStatesController statesController;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _DestinationClipper(
        shape: effectiveNavigationItemIndicatorShape,
      ),
      child: Material(
        child: InkResponse(
          statesController: statesController,
          containedInkWell: true,
          highlightShape: BoxShape.rectangle,
          overlayColor: fullItemOverlayColor,
          hoverColor: fullItemOverlayColor?.resolve({
            if (isSelected) WidgetState.selected,
            WidgetState.hovered,
          }),
          focusColor: fullItemOverlayColor?.resolve({
            if (isSelected) WidgetState.selected,
            WidgetState.focused,
          }),
          splashColor: fullItemOverlayColor?.resolve({
            if (isSelected) WidgetState.selected,
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
    required this.indicatorHeight,
    super.statesController,
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
  final double indicatorHeight;

  @override
  RectCallback? getRectCallback(RenderBox referenceBox) {
    return () {
      final RenderBox iconBox =
          iconKey.currentContext!.findRenderObject()! as RenderBox;
      final Rect iconRect = iconBox.localToGlobal(Offset.zero) & iconBox.size;

      // Preserve standard Flutter behavior when custom properties aren't in use
      if (indicatorHeight == 32.0) {
        return referenceBox.globalToLocal(iconRect.topLeft) & iconBox.size;
      }

      final Rect localIconRect =
          referenceBox.globalToLocal(iconRect.topLeft) & iconBox.size;

      const double indicatorWidth = 64.0;

      return Rect.fromCenter(
        center: localIconRect.center,
        width: indicatorWidth,
        height: indicatorHeight,
      );
    };
  }
}
