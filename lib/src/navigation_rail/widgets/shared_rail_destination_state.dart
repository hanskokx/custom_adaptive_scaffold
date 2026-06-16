part of "../navigation_rail.dart";

abstract class _BaseRailDestination extends StatefulWidget {
  const _BaseRailDestination({
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
    this.padding,
    this.margin,
    super.key,
  });

  final double? minWidth;
  final double? minExtendedWidth;
  final Widget icon;
  final Widget label;
  final Animation<double>? destinationAnimation;
  final NavigationRailLabelType? labelType;
  final bool? selected;
  final Animation<double>? extendedTransitionAnimation;
  final IconThemeData? iconTheme;
  final TextStyle? labelTextStyle;
  final VoidCallback? onTap;
  final String? indexLabel;
  final bool? useIndicator;
  final Color? indicatorColor;
  final ShapeBorder? indicatorShape;
  final bool disabled;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
}

class RailDestinationBuildData {
  RailDestinationBuildData({
    required this.theme,
    required this.navigationRailTheme,
    required this.textDirection,
    required this.material3,
    required this.useIndicator,
    required this.indicatorShape,
    required this.destinationPadding,
    required this.minWidth,
    required this.minExtendedWidth,
    required this.themedIcon,
    required this.styledLabel,
    required this.extendedAnimation,
    required this.indicatorOffset,
  });

  final ThemeData theme;
  final NavigationRailThemeData navigationRailTheme;
  final TextDirection textDirection;
  final bool material3;
  final bool useIndicator;
  final ShapeBorder? indicatorShape;
  final EdgeInsets destinationPadding;
  final double minWidth;
  final double minExtendedWidth;
  final Widget themedIcon;
  final Widget styledLabel;
  final Animation<double> extendedAnimation;
  final Offset indicatorOffset;
}

abstract class _SharedNavigationDestinationState<T extends _BaseRailDestination>
    extends State<T> with TickerProviderStateMixin {
  RailDestinationBuildData resolveBuildData(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NavigationRailThemeData navigationRailTheme = NavigationRailTheme.of(
      context,
    );

    final NavigationRailThemeData defaults = Theme.of(context).useMaterial3
        ? NavigationRailDefaultsM3(context)
        : NavigationRailDefaultsM2(context);

    final bool useIndicator = widget.useIndicator ??
        navigationRailTheme.useIndicator ??
        defaults.useIndicator!;

    final Color? indicatorColor = useIndicator
        ? widget.indicatorColor ??
            navigationRailTheme.indicatorColor ??
            defaults.indicatorColor
        : null;

    final ShapeBorder? indicatorShape = useIndicator
        ? widget.indicatorShape ??
            navigationRailTheme.indicatorShape ??
            defaults.indicatorShape
        : null;

    assert(
      useIndicator || indicatorColor == null,
      "[NavigationRail.indicatorColor] does not have an effect when [NavigationRail.useIndicator] is false",
    );

    final TextDirection textDirection = Directionality.of(context);
    final bool material3 = theme.useMaterial3;

    final EdgeInsets destinationPadding =
        (widget.padding ?? navigationRailTheme.padding)?.resolve(
              textDirection,
            ) ??
            EdgeInsets.zero;

    final double minWidth =
        widget.minWidth ?? navigationRailTheme.minWidth ?? defaults.minWidth!;

    final double minExtendedWidth = (widget.minExtendedWidth ??
            navigationRailTheme.minExtendedWidth ??
            defaults.minExtendedWidth!) -
        destinationPadding.horizontal;

    final bool selected = widget.selected ?? false;

    final IconThemeData unselectedIconTheme =
        (selected ? null : widget.iconTheme) ??
            navigationRailTheme.unselectedIconTheme ??
            defaults.unselectedIconTheme!;
    final IconThemeData selectedIconTheme =
        (selected ? widget.iconTheme : null) ??
            navigationRailTheme.selectedIconTheme ??
            defaults.selectedIconTheme!;

    final TextStyle unselectedLabelTextStyle =
        (selected ? null : widget.labelTextStyle) ??
            navigationRailTheme.unselectedLabelTextStyle ??
            defaults.unselectedLabelTextStyle!;
    final TextStyle selectedLabelTextStyle =
        (selected ? widget.labelTextStyle : null) ??
            navigationRailTheme.selectedLabelTextStyle ??
            defaults.selectedLabelTextStyle!;

    final IconThemeData iconTheme =
        selected ? selectedIconTheme : unselectedIconTheme;

    final TextStyle labelTextStyle =
        selected ? selectedLabelTextStyle : unselectedLabelTextStyle;

    final Widget themedIcon = IconTheme(
      data: widget.disabled
          ? iconTheme.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
            )
          : iconTheme,
      child: widget.icon,
    );

    final Widget styledLabel = DefaultTextStyle(
      style: widget.disabled
          ? labelTextStyle.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
            )
          : labelTextStyle,
      child: widget.label,
    );

    final Animation<double> extendedAnimation =
        widget.extendedTransitionAnimation ?? kAlwaysCompleteAnimation;

    // The indicator height is fixed and equal to _kIndicatorHeight.
    // When the icon height is larger than the indicator height the indicator
    // vertical offset is used to vertically center the indicator.
    final bool isLargeIconSize =
        iconTheme.size != null && iconTheme.size! > _kIndicatorHeight;
    final double indicatorVerticalOffset =
        isLargeIconSize ? (iconTheme.size! - _kIndicatorHeight) / 2 : 0;

    final Offset indicatorOffset = Offset(
      minWidth / 2 + destinationPadding.left,
      _verticalDestinationSpacingM3 / 2 +
          destinationPadding.top +
          indicatorVerticalOffset,
    );

    return RailDestinationBuildData(
      theme: theme,
      navigationRailTheme: navigationRailTheme,
      textDirection: textDirection,
      material3: material3,
      useIndicator: useIndicator,
      indicatorShape: indicatorShape,
      destinationPadding: destinationPadding,
      minWidth: minWidth,
      minExtendedWidth: minExtendedWidth,
      themedIcon: themedIcon,
      styledLabel: styledLabel,
      extendedAnimation: extendedAnimation,
      indicatorOffset: indicatorOffset,
    );
  }

  Widget wrapDestination({
    required RailDestinationBuildData data,
    required bool applyXOffset,
    required Widget child,
  }) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color splashColor =
        data.navigationRailTheme.indicatorColor ?? colors.primary;
    final bool primaryColorAlphaModified = splashColor.a < 255.0;

    final Color effectiveSplashColor = primaryColorAlphaModified
        ? splashColor
        : splashColor.withValues(alpha: 0.12);
    final Color effectiveHoverColor = primaryColorAlphaModified
        ? splashColor
        : splashColor.withValues(alpha: 0.04);

    return WrappedRailDestination(
      selected: widget.selected,
      disabled: widget.disabled,
      onTap: widget.onTap,
      indexLabel: widget.indexLabel,
      minWidth: data.minWidth,
      indicatorShape: data.indicatorShape,
      material3: data.material3,
      indicatorOffset: data.indicatorOffset,
      applyXOffset: applyXOffset,
      textDirection: data.textDirection,
      splashColor: effectiveSplashColor,
      hoverColor: effectiveHoverColor,
      child: child,
    );
  }
}

class WrappedRailDestination extends StatelessWidget {
  const WrappedRailDestination({
    required this.selected,
    required this.disabled,
    required this.onTap,
    required this.indexLabel,
    required this.minWidth,
    required this.indicatorShape,
    required this.material3,
    required this.indicatorOffset,
    required this.applyXOffset,
    required this.textDirection,
    required this.splashColor,
    required this.hoverColor,
    required this.child,
    super.key,
  });

  final bool? selected;
  final bool disabled;
  final VoidCallback? onTap;
  final String? indexLabel;
  final double minWidth;
  final ShapeBorder? indicatorShape;
  final bool material3;
  final Offset indicatorOffset;
  final bool applyXOffset;
  final TextDirection textDirection;
  final Color splashColor;
  final Color hoverColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      selected: selected,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: <Widget>[
            IndicatorInkWell(
              onTap: disabled ? null : onTap,
              borderRadius: BorderRadius.all(
                Radius.circular(minWidth / 2.0),
              ),
              customBorder: indicatorShape,
              splashColor: splashColor,
              hoverColor: hoverColor,
              useMaterial3: material3,
              indicatorOffset: indicatorOffset,
              applyXOffset: applyXOffset,
              textDirection: textDirection,
              child: child,
            ),
            Semantics(
              label: indexLabel,
            ),
          ],
        ),
      ),
    );
  }
}
