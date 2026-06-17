part of "../navigation_bar_destination.dart";

/// Tooltip widget for use in a [NavigationBar].
///
/// It appears just above the navigation bar when one of the destinations is
/// long pressed.
class _NavigationBarDestinationTooltip extends StatelessWidget {
  /// Adds a tooltip to the [child] widget.
  const _NavigationBarDestinationTooltip({
    required this.message,
    required this.child,
  });

  /// The text that is rendered in the tooltip when it appears.
  final String? message;

  /// The widget that, when pressed, will show a tooltip.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final NavigationBarThemeData navigationBarTheme =
        NavigationBarTheme.of(context);

    if (message == null || message!.isEmpty) {
      return child;
    }

    return Tooltip(
      message: message!,
      verticalOffset: navigationBarTheme.tooltipVerticalOffset ?? 42,
      excludeFromSemantics: true,
      preferBelow: false,
      child: child,
    );
  }
}
