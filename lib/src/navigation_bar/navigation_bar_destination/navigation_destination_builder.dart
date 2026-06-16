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
class _NavigationDestinationBuilder extends StatefulWidget {
  /// Builds a destination (icon + label) to use in a Material 3 [NavigationBar].
  const _NavigationDestinationBuilder({
    required this.buildIcon,
    required this.buildLabel,
    required this.label,
    required this.animation,
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
  State<_NavigationDestinationBuilder> createState() =>
      _NavigationDestinationBuilderState();
}

class _NavigationDestinationBuilderState
    extends State<_NavigationDestinationBuilder> {
  final GlobalKey itemKey = GlobalKey();
  late final WidgetStatesController _statesController;

  @override
  void initState() {
    super.initState();
    _statesController = WidgetStatesController();
    _statesController.addListener(_handleStatesChanged);
  }

  @override
  void dispose() {
    _statesController.removeListener(_handleStatesChanged);
    _statesController.dispose();
    super.dispose();
  }

  void _handleStatesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final NavigationDestinationInfo info =
        NavigationDestinationInfo.of(context);
    final CustomNavigationBarThemeData navigationBarTheme =
        NavigationBarTheme.of(context);
    final WidgetStateProperty<Color?>? effectiveNavigationItemOverlayColor =
        navigationBarTheme.navigationItemOverlayColor;
    final bool disableFullItemInk = effectiveNavigationItemOverlayColor == null;
    final ShapeBorder effectiveNavigationItemIndicatorShape =
        navigationBarTheme.navigationItemIndicatorShape ??
            const StadiumBorder();
    final WidgetStateProperty<Color?>? effectiveOverlayColor =
        info.overlayColor ??
            navigationBarTheme.overlayColor ??
            defaultsFor(context).overlayColor;

    return _NavigationBarDestinationSemantics(
      enabled: !widget.disabled,
      child: _NavigationBarDestinationTooltip(
        message: widget.tooltip ??
            (widget.label is Text ? (widget.label as Text).data : "") ??
            "",
        child: ClipRect(
          child: _IndicatorInkWell(
            itemKey: itemKey,
            labelBehavior: info.labelBehavior,
            disableFullItemInk: disableFullItemInk,
            customBorder: effectiveNavigationItemIndicatorShape,
            overlayColor: effectiveNavigationItemOverlayColor,
            statesController: _statesController,
            onTap: widget.disabled ? null : info.onTap,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                _StatusTransitionWidgetBuilder(
                  animation: widget.animation,
                  builder: (context, child) => Row(
                    children: <Widget>[
                      Expanded(
                        child: _NavigationBarDestinationLayout(
                          icon: _NavigationBarIndicatorStates(
                            states: _statesController.value,
                            overlayColor: effectiveOverlayColor,
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
    );
  }
}

class _IndicatorInkWell extends InkResponse {
  const _IndicatorInkWell({
    required this.itemKey,
    required this.labelBehavior,
    required this.disableFullItemInk,
    super.statesController,
    super.overlayColor,
    super.customBorder,
    super.onTap,
    super.child,
  }) : super(
          containedInkWell: true,
          highlightColor: disableFullItemInk ? Colors.transparent : null,
          splashColor: disableFullItemInk ? Colors.transparent : null,
          hoverColor: disableFullItemInk ? Colors.transparent : null,
        );

  final GlobalKey itemKey;
  final NavigationDestinationLabelBehavior labelBehavior;
  final bool disableFullItemInk;

  @override
  RectCallback? getRectCallback(RenderBox referenceBox) {
    return () {
      final RenderBox itemBox =
          itemKey.currentContext!.findRenderObject()! as RenderBox;
      final Rect itemRect = itemBox.localToGlobal(Offset.zero) & itemBox.size;
      return referenceBox.globalToLocal(itemRect.topLeft) & itemBox.size;
    };
  }
}

class _NavigationBarIndicatorStates extends InheritedWidget {
  const _NavigationBarIndicatorStates({
    required this.states,
    required this.overlayColor,
    required super.child,
  });

  final Set<WidgetState> states;
  final WidgetStateProperty<Color?>? overlayColor;

  static _NavigationBarIndicatorStates? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_NavigationBarIndicatorStates>();
  }

  @override
  bool updateShouldNotify(_NavigationBarIndicatorStates oldWidget) {
    return states.length != oldWidget.states.length ||
        !states.containsAll(oldWidget.states) ||
        overlayColor != oldWidget.overlayColor;
  }
}
