import "package:flutter/foundation.dart" show kIsWeb;

import "../../material.dart";
import "../../navigation_bar_theme.dart";
import "../navigation_destination.dart";
import "../navigation_icon.dart";
import "../navigation_shared/destination_build_data.dart";
import "../navigation_shared/destination_surface_strategy.dart";
import "../navigation_shared/navigation_destination_tooltip.dart";
import "../navigation_shared/navigation_indicator.dart";
import "destination_info.dart";
import "theme_defaults.dart";

part "destination/builder.dart";
part "destination/layout.dart";
part "destination/layout_delegate.dart";
part "destination/semantics.dart";
part "destination/status_transition_builder.dart";

const double _kIndicatorHeight = 32;
const double _kMaxLabelTextScaleFactor = 1.3;

/// A typedef alias for [NavigationDestination].
///
/// Use this name when you need to import both this package and
/// `package:flutter/material.dart` without hiding Flutter's
/// `NavigationDestination`. Equivalent to [CustomNavigationDestination].
typedef CustomNavigationBarDestination = NavigationDestination;

/// A Material 3 [NavigationBar] destination.
///
/// Displays a label below an icon. Use with [NavigationBar.destinations].
///
/// This is the bar-specific subclass of [NavigationDestination]. It extends
/// [NavigationDestination] with bar-specific rendering: it resolves the
/// indicator color and shape from [NavigationBarThemeData], applies [margin]
/// and [padding] from the theme or the destination itself, and builds the
/// full bar destination visual hierarchy.
///
/// In most cases, [NavigationDestination] can be used directly in a
/// [NavigationBar]; use [NavigationBarDestination] explicitly when you need
/// bar-specific configuration that is not available on the base class.
///
/// See also:
///
///  * [NavigationBar], for an interactive code sample.
///  * [NavigationDestination], the shared base class.
///  * [NavigationRailDestination], the rail-specific counterpart.
class NavigationBarDestination extends NavigationDestination {
  /// Creates a navigation bar destination with an icon and a label, to be used
  /// in [NavigationBar.destinations].
  const NavigationBarDestination({
    required super.icon,
    super.key,
    super.label,
    super.selectedIcon,
    super.indicatorColor,
    super.indicatorShape,
    super.margin,
    super.padding,
    super.enabled,
    super.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final NavigationDestinationInfo info =
        NavigationDestinationInfo.of(context);
    final NavigationBarThemeData? maybeExplicitTheme =
        NavigationBarTheme.maybeOf(context);
    final NavigationBarThemeData navigationBarTheme =
        NavigationBarTheme.of(context);
    final Animation<double> animation = info.selectedAnimation;

    final Color indicatorColor = info.indicatorColor ??
        navigationBarTheme.indicatorColor ??
        navigationBarDefaultsFor(context).indicatorColor!;
    final ShapeBorder indicatorShape = info.indicatorShape ??
        navigationBarTheme.indicatorShape ??
        navigationBarDefaultsFor(context).indicatorShape!;

    final EdgeInsetsGeometry margin =
        this.margin ?? navigationBarTheme.margin ?? EdgeInsets.zero;
    final EdgeInsetsGeometry padding =
        this.padding ?? navigationBarTheme.padding ?? EdgeInsets.zero;

    final DestinationBuildData data = const BarDestinationStrategy().resolve(
      context,
      DestinationResolveInput(
        icon: icon, // fallback or dummy just to extract size metrics
        label: Text(label),
        selected: info.index == info.selectedIndex,
        disabled: !enabled,
        destinationAnimation: animation,
        indicatorShape: indicatorShape,
      ),
    );

    final bool hasExplicitPackageDestinationCustomization =
        maybeExplicitTheme?.destinationOverlayColor != null ||
            maybeExplicitTheme?.destinationIndicatorShape != null;
    final bool hasExplicitIconSizeOverride =
        info.iconTheme != null || maybeExplicitTheme?.iconTheme != null;
    final bool useExpandedIndicatorSlot =
        hasExplicitPackageDestinationCustomization ||
            hasExplicitIconSizeOverride;

    final double largeIconCompensation =
        ((data.resolvedIconSize ?? 0) - _kIndicatorHeight)
            .clamp(0.0, double.infinity);
    final double effectiveIndicatorHeight = useExpandedIndicatorSlot
        ? _kIndicatorHeight + largeIconCompensation
        : _kIndicatorHeight;

    return Container(
      margin: margin,
      child: _NavigationBarDestinationBuilder(
        key: ValueKey<String>(
          "bar-destination-${info.index}-${info.selectedIndex == info.index}",
        ),
        label: Text(label),
        tooltip: tooltip,
        disabled: !enabled,
        animation: animation,
        color: indicatorColor,
        shape: indicatorShape,
        padding: padding,
        indicatorHeight: effectiveIndicatorHeight,
        buildIcon: (BuildContext context) {
          final NavigationDestinationInfo currentInfo =
              NavigationDestinationInfo.of(context);
          final bool isSelected =
              currentInfo.index == currentInfo.selectedIndex;

          // Pre-select icon from current selected index so icon state flips
          // immediately when destination selection changes.
          final Widget activeIcon = KeyedSubtree(
            key: ValueKey<String>(
              "bar-icon-${currentInfo.index}-${isSelected ? "selected" : "unselected"}",
            ),
            child: isSelected ? selectedIcon : icon,
          );

          final DestinationBuildData data =
              const BarDestinationStrategy().resolve(
            context,
            DestinationResolveInput(
              icon: activeIcon,
              label: Text(label),
              selected: isSelected,
              disabled: !enabled,
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
                height: effectiveIndicatorHeight,
              ),
              Builder(
                builder: (BuildContext context) {
                  final NavigationDestinationInfo destinationInfo =
                      NavigationDestinationInfo.of(context);
                  final bool selectedForKey =
                      destinationInfo.index == destinationInfo.selectedIndex;
                  return KeyedSubtree(
                    key: ValueKey<String>(
                      "bar-ink-icon-${destinationInfo.index}-${selectedForKey ? "selected" : "unselected"}",
                    ),
                    child: NavigationIcon(
                      icon: data.themedIcon,
                      minWidth: data.minWidth,
                      material3: data.material3,
                      height: effectiveIndicatorHeight,
                      addSpacing: false,
                      direction: Axis.vertical,
                    ),
                  );
                },
              ),
            ],
          );
        },
        buildLabel: (BuildContext context) {
          // Label styling is already resolved by the strategy and stored in
          // [data.styledLabel], but the bar label wrapper needs the padding and
          // text-scale clamping applied here.  We resolve label style directly
          // from the bar theme to avoid calling the strategy twice.
          final NavigationDestinationInfo currentInfo =
              NavigationDestinationInfo.of(context);
          final bool isSelected =
              currentInfo.index == currentInfo.selectedIndex;
          final NavigationBarThemeData barTheme =
              NavigationBarTheme.of(context);
          final NavigationBarThemeData defaults =
              navigationBarDefaultsFor(context);

          final Set<WidgetState> widgetState = {
            if (!enabled) WidgetState.disabled,
            if (isSelected && enabled) WidgetState.selected,
          };

          final TextStyle? textStyle =
              currentInfo.labelTextStyle?.resolve(widgetState) ??
                  barTheme.labelTextStyle?.resolve(widgetState) ??
                  defaults.labelTextStyle!.resolve(widgetState);

          return Padding(
            padding: currentInfo.labelPadding ??
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
