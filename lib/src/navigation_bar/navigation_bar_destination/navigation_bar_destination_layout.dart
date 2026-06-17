part of "../navigation_bar_destination.dart";

/// Widget that handles the layout of the icon + label in a navigation bar
/// destination, based on [NavigationDestinationInfo.labelBehavior] and
/// [NavigationDestinationInfo.selectedAnimation].
///
/// Depending on the [NavigationDestinationInfo.labelBehavior], the labels
/// will shift and fade accordingly.
class _NavigationBarDestinationLayout extends StatelessWidget {
  /// Builds a widget to layout an icon + label for a destination in a Material
  /// 3 [NavigationBar].
  const _NavigationBarDestinationLayout({
    required this.icon,
    required this.itemKey,
    required this.label,
    this.padding = EdgeInsets.zero,
  });

  /// The icon widget that sits on top of the label.
  ///
  /// See [NavigationDestination.icon].
  final Widget icon;

  /// The global key for the icon of this destination.
  ///
  /// This is used to determine the position of the icon.
  final GlobalKey itemKey;

  /// The label widget that sits below the icon.
  ///
  /// This widget will sometimes be faded out, depending on
  /// [NavigationDestinationInfo.selectedAnimation].
  ///
  /// See [NavigationDestination.label].
  final Widget label;

  final EdgeInsetsGeometry padding;

  static final Key _labelKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return _DestinationLayoutAnimationBuilder(
      builder: (BuildContext context, Animation<double> animation) {
        return KeyedSubtree(
          key: itemKey,
          child: Padding(
            padding: padding,
            child: CustomMultiChildLayout(
              delegate: _NavigationDestinationLayoutDelegate(
                animation: animation,
              ),
              children: <Widget>[
                LayoutId(
                  id: _NavigationDestinationLayoutDelegate.iconId,
                  child: icon,
                ),
                LayoutId(
                  id: _NavigationDestinationLayoutDelegate.labelId,
                  child: FadeTransition(
                    key: _labelKey,
                    alwaysIncludeSemantics: true,
                    opacity: animation,
                    child: label,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Determines the appropriate [Curve] and [Animation] to use for laying out the
/// [NavigationDestination], based on
/// [NavigationDestinationInfo.labelBehavior].
///
/// The animation controlling the position and fade of the labels differs
/// from the selection animation, depending on the
/// [NavigationDestinationLabelBehavior]. This widget determines what
/// animation should be used for the position and fade of the labels.
class _DestinationLayoutAnimationBuilder extends StatelessWidget {
  /// Builds a child with the appropriate animation [Curve] based on the
  /// [NavigationDestinationInfo.labelBehavior].
  const _DestinationLayoutAnimationBuilder({required this.builder});

  /// Builds the child of this widget.
  ///
  /// The [Animation] will be the appropriate [Animation] to use for the layout
  /// and fade of the [NavigationDestination], either a curve, always
  /// showing (1), or always hiding (0).
  final Widget Function(BuildContext, Animation<double>) builder;

  @override
  Widget build(BuildContext context) {
    final NavigationDestinationInfo info =
        NavigationDestinationInfo.of(context);
    switch (info.labelBehavior) {
      case NavigationDestinationLabelBehavior.alwaysShow:
        return builder(context, kAlwaysCompleteAnimation);
      case NavigationDestinationLabelBehavior.alwaysHide:
        return builder(context, kAlwaysDismissedAnimation);
      case NavigationDestinationLabelBehavior.onlyShowSelected:
        return _CurvedAnimationBuilder(
          animation: info.selectedAnimation,
          curve: Curves.easeInOutCubicEmphasized,
          reverseCurve: Curves.easeInOutCubicEmphasized.flipped,
          builder: builder,
        );
    }
  }
}

/// Watches [animation] and calls [builder] with the appropriate [Curve]
/// depending on the direction of the [animation] status.
///
/// If [animation.status] is forward or complete, [curve] is used. If
/// [animation.status] is reverse or dismissed, [reverseCurve] is used.
///
/// If the [animation] changes direction while it is already running, the curve
/// used will not change, this will keep the animations smooth until it
/// completes.
///
/// This is similar to [CurvedAnimation] except the animation status listeners
/// are removed when this widget is disposed.
class _CurvedAnimationBuilder extends StatefulWidget {
  const _CurvedAnimationBuilder({
    required this.animation,
    required this.curve,
    required this.reverseCurve,
    required this.builder,
  });

  final Animation<double> animation;
  final Curve curve;
  final Curve reverseCurve;
  final Widget Function(BuildContext, Animation<double>) builder;

  @override
  _CurvedAnimationBuilderState createState() => _CurvedAnimationBuilderState();
}

class _CurvedAnimationBuilderState extends State<_CurvedAnimationBuilder> {
  late AnimationStatus _animationDirection;
  AnimationStatus? _preservedDirection;

  @override
  void initState() {
    super.initState();
    _animationDirection = widget.animation.status;
    _updateStatus(widget.animation.status);
    widget.animation.addStatusListener(_updateStatus);
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_updateStatus);
    super.dispose();
  }

  // Keeps track of the current animation status, as well as the "preserved
  // direction" when the animation changes direction mid animation.
  //
  // The preserved direction is reset when the animation finishes in either
  // direction.
  void _updateStatus(AnimationStatus status) {
    if (_animationDirection != status) {
      setState(() {
        _animationDirection = status;
      });
    }
    switch (status) {
      case AnimationStatus.forward || AnimationStatus.reverse
          when _preservedDirection != null:
        break;
      case AnimationStatus.forward || AnimationStatus.reverse:
        setState(() {
          _preservedDirection = status;
        });
      case AnimationStatus.completed || AnimationStatus.dismissed:
        setState(() {
          _preservedDirection = null;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldUseForwardCurve =
        (_preservedDirection ?? _animationDirection) != AnimationStatus.reverse;

    final Animation<double> curvedAnimation = CurveTween(
      curve: shouldUseForwardCurve ? widget.curve : widget.reverseCurve,
    ).animate(widget.animation);

    return widget.builder(context, curvedAnimation);
  }
}
