import "../material.dart";
import "../navigation_destination.dart";
import "../navigation_icon.dart";
import "../navigation_rail/navigation_rail.dart";
import "../navigation_rail/navigation_rail_theme.dart";
import "../navigation_type.dart";
import "navigation_bar_theme.dart";
import "navigation_destination_info.dart";
import "selectable_animated_builder.dart";

part "navigation_bar_destination/navigation_bar_destination_layout.dart";
part "navigation_bar_destination/navigation_bar_destination_semantics.dart";
part "navigation_bar_destination/navigation_bar_destination_tooltip.dart";
part "navigation_bar_destination/navigation_destination_builder.dart";
part "navigation_bar_destination/navigation_destination_layout_delegate.dart";
part "navigation_bar_destination/navigation_indicator.dart";
part "navigation_bar_destination/status_transition_widget_builder.dart";

const double _kIndicatorHeight = 32;
const double _kIndicatorWidth = 64;
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
    const Set<WidgetState> selectedState = <WidgetState>{
      WidgetState.selected,
    };
    const Set<WidgetState> unselectedState = <WidgetState>{};
    const Set<WidgetState> disabledState = <WidgetState>{
      WidgetState.disabled,
    };

    final NavigationBarThemeData navigationBarTheme =
        NavigationBarTheme.of(context);
    final NavigationBarThemeData defaults = defaultsFor(context);
    final Animation<double> animation = info.selectedAnimation;

    final Color indicatorColor = info.indicatorColor ??
        navigationBarTheme.indicatorColor ??
        defaults.indicatorColor!;
    final ShapeBorder indicatorShape = info.indicatorShape ??
        navigationBarTheme.indicatorShape ??
        defaults.indicatorShape!;

    late final EdgeInsetsGeometry margin;
    late final EdgeInsetsGeometry padding;

    margin = navigationBarTheme.margin;
    padding = navigationBarTheme.padding;

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
          final ThemeData theme = Theme.of(context);
          final NavigationRailThemeData navigationRailTheme =
              NavigationRailTheme.of(context);
          final IconThemeData selectedIconTheme =
              navigationBarTheme.iconTheme?.resolve(selectedState) ??
                  defaults.iconTheme!.resolve(selectedState)!;
          final IconThemeData unselectedIconTheme =
              navigationBarTheme.iconTheme?.resolve(unselectedState) ??
                  defaults.iconTheme!.resolve(unselectedState)!;
          final IconThemeData disabledIconTheme =
              navigationBarTheme.iconTheme?.resolve(disabledState) ??
                  defaults.iconTheme!.resolve(disabledState)!;

          final Widget selectedIconWidget = IconTheme.merge(
            data: disabled ? disabledIconTheme : selectedIconTheme,
            child: selectedIcon,
          );
          final Widget unselectedIconWidget = IconTheme.merge(
            data: disabled ? disabledIconTheme : unselectedIconTheme,
            child: icon,
          );

          final Widget themedIcon = animation.isForwardOrCompleted
              ? selectedIconWidget
              : unselectedIconWidget;

          return NavigationIcon(
            type: NavigationType.bar,
            data: RailDestinationBuildData(
              theme: theme,
              navigationRailTheme: navigationRailTheme,
              textDirection: Directionality.of(context),
              material3: theme.useMaterial3,
              useIndicator: true,
              indicatorShape: indicatorShape,
              destinationPadding: EdgeInsets.zero,
              minWidth: _kIndicatorWidth,
              minExtendedWidth: _kIndicatorWidth,
              themedIcon: themedIcon,
              styledLabel: const SizedBox.shrink(),
              extendedAnimation: animation,
              indicatorOffset: const Offset(_kIndicatorWidth / 2, 0),
            ),
          );
        },
        buildLabel: (BuildContext context) {
          final TextStyle? effectiveSelectedLabelTextStyle =
              navigationBarTheme.labelTextStyle?.resolve(selectedState) ??
                  defaults.labelTextStyle!.resolve(selectedState);
          final TextStyle? effectiveUnselectedLabelTextStyle =
              navigationBarTheme.labelTextStyle?.resolve(unselectedState) ??
                  defaults.labelTextStyle!.resolve(unselectedState);
          final TextStyle? effectiveDisabledLabelTextStyle =
              navigationBarTheme.labelTextStyle?.resolve(disabledState) ??
                  defaults.labelTextStyle!.resolve(disabledState);

          final TextStyle? textStyle = (disabled
              ? effectiveDisabledLabelTextStyle
              : animation.isForwardOrCompleted
                  ? effectiveSelectedLabelTextStyle
                  : effectiveUnselectedLabelTextStyle);

          return Padding(
            padding: const EdgeInsets.only(top: 4),
            child: MediaQuery.withClampedTextScaling(
              // Set maximum text scale factor to _kMaxLabelTextScaleFactor for the
              // label to keep the visual hierarchy the same even with larger font
              // sizes. To opt out, wrap the [label] widget in a [MediaQuery] widget
              // with a different `TextScaler`.
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
