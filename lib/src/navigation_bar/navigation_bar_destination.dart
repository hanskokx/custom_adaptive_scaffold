import "../../navigation_bar_theme.dart";
import "../destination/destination_build_data.dart";
import "../destination/destination_surface_strategy.dart";
import "../destination/navigation_indicator.dart";
import "../material.dart";
import "../navigation_destination.dart";
import "../navigation_icon.dart";
import "navigation_destination_info.dart";

part "navigation_bar_destination/navigation_bar_destination_layout.dart";
part "navigation_bar_destination/navigation_bar_destination_semantics.dart";
part "navigation_bar_destination/navigation_bar_destination_tooltip.dart";
part "navigation_bar_destination/navigation_destination_builder.dart";
part "navigation_bar_destination/navigation_destination_layout_delegate.dart";
part "navigation_bar_destination/status_transition_widget_builder.dart";

const double _kIndicatorHeight = 32;
const double _kMaxLabelTextScaleFactor = 1.3;

/// A Material 3 [NavigationBar] destination.
///
/// Displays a label below an icon. Use with [NavigationBar.destinations].
///
/// See also:
///
///  * [NavigationBar], for an interactive code sample.
class NavigationBarDestination extends NavigationDestination {
  /// Creates a navigation bar destination with an icon and a label, to be used
  /// in the [NavigationBar.destinations].
  const NavigationBarDestination({
    required super.icon,
    super.key,
    super.label,
    super.selectedIcon,
    super.indicatorColor,
    super.indicatorShape,
    super.padding,
    super.disabled,
    super.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final NavigationDestinationInfo info =
        NavigationDestinationInfo.of(context);
    final NavigationBarThemeData navigationBarTheme =
        NavigationBarTheme.of(context);
    final Animation<double> animation = info.selectedAnimation;

    final Color indicatorColor = info.indicatorColor ??
        navigationBarTheme.indicatorColor ??
        defaultsFor(context).indicatorColor!;
    final ShapeBorder indicatorShape = info.indicatorShape ??
        navigationBarTheme.indicatorShape ??
        defaultsFor(context).indicatorShape!;

    final EdgeInsetsGeometry margin = navigationBarTheme.margin;
    final EdgeInsetsGeometry padding = navigationBarTheme.padding;

    return Container(
      margin: margin,
      child: _NavigationDestinationBuilder(
        label: Text(label),
        tooltip: tooltip,
        disabled: disabled,
        animation: animation,
        color: indicatorColor,
        shape: indicatorShape,
        padding: padding,
        buildIcon: (BuildContext context) {
          // Pre-select the icon widget based on animation status before
          // handing to the strategy — matches the parity contract where
          // both surfaces receive a single already-chosen icon.
          final bool isSelected = animation.isForwardOrCompleted;
          final Widget activeIcon = isSelected ? selectedIcon : icon;

          final DestinationBuildData data =
              const BarDestinationStrategy().resolve(
            context,
            DestinationResolveInput(
              icon: activeIcon,
              label: Text(label),
              selected: isSelected,
              disabled: disabled,
              destinationAnimation: animation,
              indicatorShape: indicatorShape,
            ),
          );

          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              NavigationIndicator(
                animation: animation,
                color: indicatorColor,
                shape: indicatorShape,
                width: data.minWidth,
                height: _kIndicatorHeight,
              ),
              NavigationIcon(
                icon: data.themedIcon,
                minWidth: data.minWidth,
                material3: data.material3,
                height: _kIndicatorHeight,
                addSpacing: false,
                direction: Axis.vertical,
              ),
            ],
          );
        },
        buildLabel: (BuildContext context) {
          // Label styling is already resolved by the strategy and stored in
          // data.styledLabel, but the bar label wrapper needs the padding and
          // text-scale clamping applied here.  We resolve label style directly
          // from the bar theme to avoid calling the strategy twice.
          final bool isSelected = animation.isForwardOrCompleted;
          final NavigationBarThemeData barTheme =
              NavigationBarTheme.of(context);
          final NavigationBarThemeData defaults = defaultsFor(context);
          final NavigationDestinationInfo info =
              NavigationDestinationInfo.of(context);

          final Set<WidgetState> widgetState = {
            if (disabled) WidgetState.disabled,
            if (isSelected && !disabled) WidgetState.selected,
          };

          final TextStyle? textStyle =
              barTheme.labelTextStyle?.resolve(widgetState) ??
                  defaults.labelTextStyle!.resolve(widgetState);

          return Padding(
            padding: info.labelPadding ??
                barTheme.labelPadding ??
                defaults.labelPadding ??
                const EdgeInsets.only(top: 4),
            child: MediaQuery.withClampedTextScaling(
              maxScaleFactor: _kMaxLabelTextScaleFactor,
              child: DefaultTextStyle(
                style: textStyle ??
                    Theme.of(context).textTheme.labelMedium ??
                    const TextStyle(),
                child: Text(label),
              ),
            ),
          );
        },
      ),
    );
  }
}
