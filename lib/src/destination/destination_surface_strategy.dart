import "package:flutter/material.dart"
    hide
        NavigationBarTheme,
        NavigationBarThemeData,
        NavigationRailTheme,
        NavigationRailThemeData;

import "../../navigation_bar_theme.dart";
import "../../navigation_rail_theme.dart";
import "../navigation_bar/navigation_bar_theme_defaults.dart";
import "../navigation_rail/navigation_rail_theme_defaults.dart";
import "destination_build_data.dart";

// Rail layout spacing constants (mirror values defined in rail_destination.dart
// so the strategy has no part-file coupling).
const double _kIndicatorHeight = 32.0;
const double _kRailIconSlotHeight = 44.0;

// Bar indicator constant.
const double _kBarIndicatorWidth = 64.0;

/// Input model supplied by the caller (a destination widget's build method)
/// to a [DestinationSurfaceStrategy].
///
/// All fields are surface-agnostic; the strategy implementation decides how to
/// map them onto the appropriate theme object.
class DestinationResolveInput {
  const DestinationResolveInput({
    required this.icon,
    required this.label,
    required this.selected,
    required this.disabled,
    required this.destinationAnimation,
    this.extendedTransitionAnimation,
    this.indicatorColor,
    this.indicatorShape,
    this.padding,
    this.margin,
    this.minWidth,
    this.minExtendedWidth,
    this.useIndicator,
    this.iconTheme,
    this.labelTextStyle,
  });

  /// The icon widget to display.
  ///
  /// For the rail surface the host pre-selects the icon (selected vs
  /// unselected) before constructing the destination widget.  For the bar
  /// surface the caller pre-selects based on `animation.isForwardOrCompleted`
  /// before building this input.
  final Widget icon;

  /// The label widget.
  final Widget label;

  /// Whether this destination is currently selected.
  final bool selected;

  /// Whether this destination is disabled.
  final bool disabled;

  /// Per-destination selection animation (drives position and label fade).
  final Animation<double> destinationAnimation;

  /// Animation for the rail's extended/collapsed state transition.
  /// Null for bar destinations.
  final Animation<double>? extendedTransitionAnimation;

  /// Per-widget indicator color override.
  final Color? indicatorColor;

  /// Per-widget indicator shape override.
  final ShapeBorder? indicatorShape;

  /// Per-widget content padding override.
  final EdgeInsetsGeometry? padding;

  /// Per-widget content margin override.
  final EdgeInsetsGeometry? margin;

  /// Per-widget minimum width override.
  final double? minWidth;

  /// Per-widget minimum extended width override.
  final double? minExtendedWidth;

  /// Per-widget indicator visibility override.
  final bool? useIndicator;

  /// Per-widget icon theme override applied on top of the surface theme.
  final IconThemeData? iconTheme;

  /// Per-widget label text style override applied on top of the surface theme.
  final TextStyle? labelTextStyle;
}

/// Abstract resolver that maps a [DestinationResolveInput] onto a
/// [DestinationBuildData] for a specific navigation surface.
///
/// Each surface provides its own implementation that reads the correct theme
/// object and applies the correct precedence chain.  Consumers hold a
/// `const` instance and call [resolve] inside their build method.
///
/// Two built-in implementations are provided:
/// - [RailDestinationStrategy] — reads [NavigationRailThemeData].
/// - [BarDestinationStrategy]  — reads [NavigationBarThemeData].
abstract class DestinationSurfaceStrategy {
  const DestinationSurfaceStrategy();

  DestinationBuildData resolve(
    BuildContext context,
    DestinationResolveInput input,
  );
}

/// Rail strategy: resolves destination visuals using [NavigationRailThemeData].
///
/// Precedence chain per field: widget override → rail component theme →
/// rail defaults (M3 or M2).
class RailDestinationStrategy extends DestinationSurfaceStrategy {
  const RailDestinationStrategy();

  @override
  DestinationBuildData resolve(
    BuildContext context,
    DestinationResolveInput input,
  ) {
    final ThemeData theme = Theme.of(context);
    final NavigationRailThemeData railTheme = NavigationRailTheme.of(context);
    final NavigationRailThemeData defaults = navigationRailDefaultsFor(context);

    // --- Indicator ---
    final bool useIndicator =
        input.useIndicator ?? railTheme.useIndicator ?? defaults.useIndicator!;

    final ShapeBorder? indicatorShape = useIndicator
        ? input.indicatorShape ??
            railTheme.indicatorShape ??
            defaults.indicatorShape
        : null;

    assert(
      useIndicator || input.indicatorColor == null,
      "[NavigationRail.indicatorColor] does not have an effect when "
      "[NavigationRail.useIndicator] is false",
    );

    // --- Geometry ---
    final TextDirection textDirection = Directionality.of(context);
    final bool material3 = theme.useMaterial3;

    final EdgeInsets destinationPadding =
        (input.padding ?? railTheme.padding ?? EdgeInsets.zero)
            .resolve(textDirection);
    final EdgeInsets destinationMargin =
        (input.margin ?? railTheme.margin ?? EdgeInsets.zero)
            .resolve(textDirection);

    final double paddingAndMarginWidth =
        destinationPadding.horizontal + destinationMargin.horizontal;

    final double minWidth =
        input.minWidth ?? railTheme.minWidth ?? defaults.minWidth!;
    final double minExtendedWidth = (input.minExtendedWidth ??
            railTheme.minExtendedWidth ??
            defaults.minExtendedWidth!) -
        paddingAndMarginWidth;

    // --- Icon and label theming ---
    final IconThemeData unselectedIconTheme =
        (input.selected ? null : input.iconTheme) ??
            railTheme.unselectedIconTheme ??
            defaults.unselectedIconTheme!;
    final IconThemeData selectedIconTheme =
        (input.selected ? input.iconTheme : null) ??
            railTheme.selectedIconTheme ??
            defaults.selectedIconTheme!;

    // In M2 with indicator enabled, selected icon color should contrast with
    // the indicator fill. Keep explicit widget/theme icon overrides intact.
    final bool hasSelectedIconOverride =
        (input.selected && input.iconTheme != null) ||
            railTheme.selectedIconTheme != null;
    final IconThemeData effectiveSelectedIconTheme =
        !material3 && useIndicator && !hasSelectedIconOverride
            ? selectedIconTheme.copyWith(
                color: theme.colorScheme.onSecondary,
                opacity: 1.0,
              )
            : selectedIconTheme;

    final TextStyle unselectedLabelTextStyle =
        (input.selected ? null : input.labelTextStyle) ??
            railTheme.unselectedLabelTextStyle ??
            defaults.unselectedLabelTextStyle!;
    final TextStyle selectedLabelTextStyle =
        (input.selected ? input.labelTextStyle : null) ??
            railTheme.selectedLabelTextStyle ??
            defaults.selectedLabelTextStyle!;

    final IconThemeData iconTheme =
        input.selected ? effectiveSelectedIconTheme : unselectedIconTheme;
    final TextStyle labelTextStyle =
        input.selected ? selectedLabelTextStyle : unselectedLabelTextStyle;

    final Widget themedIcon = IconTheme(
      data: input.disabled
          ? iconTheme.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
            )
          : iconTheme,
      child: input.icon,
    );

    final Widget styledLabel = DefaultTextStyle(
      style: input.disabled
          ? labelTextStyle.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
            )
          : labelTextStyle,
      child: input.label,
    );

    // --- Animations ---
    final Animation<double> extendedAnimation =
        input.extendedTransitionAnimation ?? kAlwaysCompleteAnimation;

    // --- Compact indicator offset (labelType.none / expanded layout) ---
    final bool isLargeIconSize =
        iconTheme.size != null && iconTheme.size! > _kIndicatorHeight;
    final double indicatorVerticalOffset =
        isLargeIconSize ? (iconTheme.size! - _kIndicatorHeight) / 2 : 0;

    final Offset indicatorOffset = Offset(
      minWidth / 2,
      destinationPadding.top +
          (_kRailIconSlotHeight / 2) +
          indicatorVerticalOffset,
    );

    // --- Indicator color ---
    // Resolved separately from splashBase so consumers (e.g. WrappedRailDestination)
    // can render a NavigationIndicator fill independent of the ripple tint.
    final Color? indicatorColor = useIndicator
        ? input.indicatorColor ??
            railTheme.indicatorColor ??
            defaults.indicatorColor
        : null;

    // --- Interaction colors ---
    final Color splashBase =
        railTheme.indicatorColor ?? theme.colorScheme.primary;
    final bool splashAlphaModified =
        (splashBase.a * 255.0).round().clamp(0, 255) < 255;

    return DestinationBuildData(
      themedIcon: themedIcon,
      styledLabel: styledLabel,
      minWidth: minWidth,
      minExtendedWidth: minExtendedWidth,
      material3: material3,
      useIndicator: useIndicator,
      indicatorColor: indicatorColor,
      indicatorShape: indicatorShape,
      destinationPadding: destinationPadding,
      textDirection: textDirection,
      extendedAnimation: extendedAnimation,
      indicatorOffset: indicatorOffset,
      splashColor:
          splashAlphaModified ? splashBase : splashBase.withValues(alpha: 0.12),
      hoverColor:
          splashAlphaModified ? splashBase : splashBase.withValues(alpha: 0.04),
      resolvedIconSize: iconTheme.size,
    );
  }
}

/// Bar strategy: resolves destination visuals using [NavigationBarThemeData].
///
/// Precedence chain per field: widget override → bar component theme →
/// bar defaults.  Icon and label themes are resolved via [WidgetStateProperty]
/// using the combined selected + disabled widget state.
class BarDestinationStrategy extends DestinationSurfaceStrategy {
  const BarDestinationStrategy();

  @override
  DestinationBuildData resolve(
    BuildContext context,
    DestinationResolveInput input,
  ) {
    final ThemeData theme = Theme.of(context);
    final NavigationBarThemeData barTheme = NavigationBarTheme.of(context);
    final NavigationBarThemeData defaults = navigationBarDefaultsFor(context);

    // Compute the combined widget state so icon/label styles respond to
    // disabled and selected simultaneously.
    final Set<WidgetState> widgetState = {
      if (input.disabled) WidgetState.disabled,
      if (input.selected && !input.disabled) WidgetState.selected,
    };

    // --- Icon theming ---
    final bool material3 = theme.useMaterial3;
    final IconThemeData iconTheme = barTheme.iconTheme?.resolve(widgetState) ??
        defaults.iconTheme!.resolve(widgetState)!;

    final Widget themedIcon = IconTheme.merge(
      data: iconTheme,
      child: input.icon,
    );

    // --- Label theming ---
    final TextStyle? labelTextStyle =
        barTheme.labelTextStyle?.resolve(widgetState) ??
            defaults.labelTextStyle!.resolve(widgetState);

    final Widget styledLabel = DefaultTextStyle(
      style: labelTextStyle ?? theme.textTheme.labelMedium ?? const TextStyle(),
      child: input.label,
    );

    // --- Geometry ---
    final TextDirection textDirection = Directionality.of(context);

    final ShapeBorder indicatorShape = input.indicatorShape ??
        barTheme.indicatorShape ??
        defaults.indicatorShape!;

    // --- Interaction colors ---
    // Bar uses the indicator color (or primary) as the base for ripple/hover.
    final Color splashBase = barTheme.indicatorColor ??
        defaults.indicatorColor ??
        theme.colorScheme.secondaryContainer;
    final bool splashAlphaModified =
        (splashBase.a * 255.0).round().clamp(0, 255) < 255;

    return DestinationBuildData(
      themedIcon: themedIcon,
      styledLabel: styledLabel,
      minWidth: _kBarIndicatorWidth,
      minExtendedWidth: _kBarIndicatorWidth,
      material3: material3,
      useIndicator: true,
      indicatorColor: null, // bar sources indicator color directly from theme
      indicatorShape: indicatorShape,
      destinationPadding: EdgeInsets.zero,
      textDirection: textDirection,
      extendedAnimation:
          input.extendedTransitionAnimation ?? kAlwaysCompleteAnimation,
      indicatorOffset: const Offset(_kBarIndicatorWidth / 2, 0),
      splashColor:
          splashAlphaModified ? splashBase : splashBase.withValues(alpha: 0.12),
      hoverColor:
          splashAlphaModified ? splashBase : splashBase.withValues(alpha: 0.04),
    );
  }
}
