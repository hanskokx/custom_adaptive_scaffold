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

  @override
  Widget build(BuildContext context) {
    final NavigationDestinationInfo info =
        NavigationDestinationInfo.of(context);
    final NavigationBarThemeData navigationBarTheme =
        NavigationBarTheme.of(context);
    final bool isSelected = widget.animation.isForwardOrCompleted;

    final WidgetStateProperty<Color?>? baseOverlayColor =
        info.overlayColor ?? navigationBarTheme.overlayColor;
    final WidgetStateProperty<Color?>? effectiveOverlayColor = isSelected
        ? WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused) ||
                states.contains(WidgetState.pressed)) {
              return Colors.transparent;
            }
            return baseOverlayColor?.resolve(states);
          })
        : baseOverlayColor;

    return _NavigationBarDestinationSemantics(
      child: _NavigationBarDestinationTooltip(
        message: widget.tooltip ??
            (widget.label is Text ? (widget.label as Text).data : "") ??
            "",
        child: ClipRect(
          child: InkWell(
            customBorder: widget.shape,
            overlayColor: effectiveOverlayColor,
            onTap: widget.disabled ? null : info.onTap,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                // This is the background color of the currently selected
                // navigation bar item
                NavigationIndicator(
                  animation: widget.animation,
                  color: widget.color,
                  shape: widget.shape,
                ),
                _StatusTransitionWidgetBuilder(
                  animation: widget.animation,
                  builder: (context, child) => Row(
                    children: <Widget>[
                      Expanded(
                        child: _NavigationBarDestinationLayout(
                          icon: widget.buildIcon(context),
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
