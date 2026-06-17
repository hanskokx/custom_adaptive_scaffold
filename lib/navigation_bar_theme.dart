// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import "dart:ui" show Offset, lerpDouble;

import "package:flutter/foundation.dart";
import "package:flutter/material.dart" as m
    show NavigationBarThemeData, NavigationBarTheme;
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";

typedef CustomNavigationBarThemeData = NavigationBarThemeData;
typedef CustomNavigationBarTheme = NavigationBarTheme;

// Examples can assume:
// late BuildContext context;

/// Defines default property values for descendant [NavigationBar]
/// widgets.
///
/// Descendant widgets obtain the current [NavigationBarThemeData] object
/// using `NavigationBarTheme.of(context)`. Instances of
/// [NavigationBarThemeData] can be customized with
/// [NavigationBarThemeData.copyWith].
///
/// Typically a [NavigationBarThemeData] is specified as part of the
/// overall [Theme] with [ThemeData.navigationBarTheme]. Alternatively, a
/// [NavigationBarTheme] inherited widget can be used to theme [NavigationBar]s
/// in a subtree of widgets.
///
/// All [NavigationBarThemeData] properties are `null` by default.
/// When null, the [NavigationBar] will provide its own defaults based on the
/// overall [Theme]'s textTheme and colorScheme. See the individual
/// [NavigationBar] properties for details.
///
/// See also:
///
///  * [ThemeData], which describes the overall theme information for the
///    application.
@immutable
class NavigationBarThemeData
    with Diagnosticable
    implements m.NavigationBarThemeData {
  /// Creates a theme that can be used for [ThemeData.navigationBarTheme] and
  /// [NavigationBarTheme].
  const NavigationBarThemeData({
    this.height,
    this.backgroundColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.indicatorColor,
    this.indicatorShape,
    this.labelTextStyle,
    this.iconTheme,
    this.labelBehavior,
    this.overlayColor,
    this.navigationItemOverlayColor,
    this.navigationItemIndicatorShape,
    this.margin,
    this.padding,
    this.tooltipOffset,
    this.labelPadding,
    this.tooltipTrigger,
  });

  /// Overrides the default value of [NavigationBar.height].
  @override
  final double? height;

  /// Overrides the default value of [NavigationBar.backgroundColor].
  @override
  final Color? backgroundColor;

  /// Overrides the default value of [NavigationBar.elevation].
  @override
  final double? elevation;

  /// Overrides the default value of [NavigationBar.shadowColor].
  @override
  final Color? shadowColor;

  /// Overrides the default value of [NavigationBar.surfaceTintColor].
  @override
  final Color? surfaceTintColor;

  /// Overrides the default value of [NavigationBar]'s selection indicator.
  @override
  final Color? indicatorColor;

  /// Overrides the default shape of the [NavigationBar]'s selection indicator.
  @override
  final ShapeBorder? indicatorShape;

  /// The style to merge with the default text style for
  /// [NavigationDestination] labels.
  ///
  /// You can use this to specify a different style when the label is selected.
  @override
  final WidgetStateProperty<TextStyle?>? labelTextStyle;

  /// The theme to merge with the default icon theme for
  /// [NavigationDestination] icons.
  ///
  /// You can use this to specify a different icon theme when the icon is
  /// selected.
  @override
  final WidgetStateProperty<IconThemeData?>? iconTheme;

  /// Overrides the default value of [NavigationBar.labelBehavior].
  @override
  final NavigationDestinationLabelBehavior? labelBehavior;

  /// Overrides the default value of [NavigationBar.overlayColor].
  @override
  final WidgetStateProperty<Color?>? overlayColor;

  /// Overlay colors for the full navigation item container by widget state.
  ///
  /// This is separate from [overlayColor], which can still be used by custom
  /// indicator visuals.
  ///
  /// This has no effect when [ThemeData.useMaterial3] is false.
  final WidgetStateProperty<Color?>? navigationItemOverlayColor;

  /// Shape of the full navigation item container ink well.
  ///
  /// Defaults to [StadiumBorder] at resolution sites when this is null.
  final ShapeBorder? navigationItemIndicatorShape;

  /// Applies a margin around navigation items.
  final EdgeInsetsGeometry? margin;

  /// Applies padding around navigation item content.
  final EdgeInsetsGeometry? padding;

  /// Defines the x/y offset of tooltip popovers.
  final Offset? tooltipOffset;

  /// Controls which gesture triggers the tooltip popover.
  ///
  /// If null, Flutter's platform default is used (long press on mobile,
  /// long press and hover on desktop).
  ///
  /// For navigation destinations in this package, [TooltipTriggerMode.tap]
  /// is mapped to a secondary tap (such as right click) so the primary tap
  /// can continue to activate navigation.
  final TooltipTriggerMode? tooltipTrigger;

  /// Applies padding around navigation item labels. Defaults to [EdgeInsets.zero].
  @override
  final EdgeInsetsGeometry? labelPadding;

  /// Creates a copy of this object with the given fields replaced with the
  /// new values.
  @override
  NavigationBarThemeData copyWith({
    double? height,
    Color? backgroundColor,
    double? elevation,
    Color? shadowColor,
    Color? surfaceTintColor,
    Color? indicatorColor,
    ShapeBorder? indicatorShape,
    WidgetStateProperty<TextStyle?>? labelTextStyle,
    WidgetStateProperty<IconThemeData?>? iconTheme,
    NavigationDestinationLabelBehavior? labelBehavior,
    WidgetStateProperty<Color?>? overlayColor,
    WidgetStateProperty<Color?>? navigationItemOverlayColor,
    ShapeBorder? navigationItemIndicatorShape,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Offset? tooltipOffset,
    EdgeInsetsGeometry? labelPadding,
    TooltipTriggerMode? tooltipTrigger,
  }) {
    return NavigationBarThemeData(
      height: height ?? this.height,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      elevation: elevation ?? this.elevation,
      shadowColor: shadowColor ?? this.shadowColor,
      surfaceTintColor: surfaceTintColor ?? this.surfaceTintColor,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      indicatorShape: indicatorShape ?? this.indicatorShape,
      labelTextStyle: labelTextStyle ?? this.labelTextStyle,
      iconTheme: iconTheme ?? this.iconTheme,
      labelBehavior: labelBehavior ?? this.labelBehavior,
      overlayColor: overlayColor ?? this.overlayColor,
      navigationItemOverlayColor:
          navigationItemOverlayColor ?? this.navigationItemOverlayColor,
      navigationItemIndicatorShape:
          navigationItemIndicatorShape ?? this.navigationItemIndicatorShape,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      tooltipOffset: tooltipOffset ?? this.tooltipOffset,
      labelPadding: labelPadding ?? this.labelPadding,
      tooltipTrigger: tooltipTrigger ?? this.tooltipTrigger,
    );
  }

  /// Linearly interpolate between two navigation rail themes.
  ///
  /// If both arguments are null then null is returned.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static NavigationBarThemeData? lerp(
    NavigationBarThemeData? a,
    NavigationBarThemeData? b,
    double t,
  ) {
    if (identical(a, b)) {
      return a;
    }
    return NavigationBarThemeData(
      height: lerpDouble(a?.height, b?.height, t),
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      elevation: lerpDouble(a?.elevation, b?.elevation, t),
      shadowColor: Color.lerp(a?.shadowColor, b?.shadowColor, t),
      surfaceTintColor: Color.lerp(a?.surfaceTintColor, b?.surfaceTintColor, t),
      indicatorColor: Color.lerp(a?.indicatorColor, b?.indicatorColor, t),
      indicatorShape: ShapeBorder.lerp(a?.indicatorShape, b?.indicatorShape, t),
      labelTextStyle: WidgetStateProperty.lerp<TextStyle?>(
        a?.labelTextStyle,
        b?.labelTextStyle,
        t,
        TextStyle.lerp,
      ),
      iconTheme: WidgetStateProperty.lerp<IconThemeData?>(
        a?.iconTheme,
        b?.iconTheme,
        t,
        IconThemeData.lerp,
      ),
      labelBehavior: t < 0.5 ? a?.labelBehavior : b?.labelBehavior,
      overlayColor: WidgetStateProperty.lerp<Color?>(
        a?.overlayColor,
        b?.overlayColor,
        t,
        Color.lerp,
      ),
      navigationItemOverlayColor: WidgetStateProperty.lerp<Color?>(
        a?.navigationItemOverlayColor,
        b?.navigationItemOverlayColor,
        t,
        Color.lerp,
      ),
      navigationItemIndicatorShape: ShapeBorder.lerp(
        a?.navigationItemIndicatorShape,
        b?.navigationItemIndicatorShape,
        t,
      ),
      margin: EdgeInsetsGeometry.lerp(a?.margin, b?.margin, t),
      padding: EdgeInsetsGeometry.lerp(a?.padding, b?.padding, t),
      tooltipOffset: Offset.lerp(a?.tooltipOffset, b?.tooltipOffset, t),
      labelPadding: EdgeInsetsGeometry.lerp(
        a?.labelPadding,
        b?.labelPadding,
        t,
      ),
      tooltipTrigger: t < 0.5 ? a?.tooltipTrigger : b?.tooltipTrigger,
    );
  }

  @override
  int get hashCode => Object.hash(
        height,
        backgroundColor,
        elevation,
        shadowColor,
        surfaceTintColor,
        indicatorColor,
        indicatorShape,
        labelTextStyle,
        iconTheme,
        labelBehavior,
        overlayColor,
        navigationItemOverlayColor,
        navigationItemIndicatorShape,
        margin,
        padding,
        tooltipOffset,
        labelPadding,
        tooltipTrigger,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is NavigationBarThemeData &&
        other.height == height &&
        other.backgroundColor == backgroundColor &&
        other.elevation == elevation &&
        other.shadowColor == shadowColor &&
        other.surfaceTintColor == surfaceTintColor &&
        other.indicatorColor == indicatorColor &&
        other.indicatorShape == indicatorShape &&
        other.labelTextStyle == labelTextStyle &&
        other.iconTheme == iconTheme &&
        other.labelBehavior == labelBehavior &&
        other.overlayColor == overlayColor &&
        other.navigationItemOverlayColor == navigationItemOverlayColor &&
        other.navigationItemIndicatorShape == navigationItemIndicatorShape &&
        other.margin == margin &&
        other.padding == padding &&
        other.tooltipOffset == tooltipOffset &&
        other.tooltipOffset == tooltipOffset &&
        other.tooltipTrigger == tooltipTrigger &&
        other.labelPadding == labelPadding;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty("height", height, defaultValue: null));
    properties.add(
      ColorProperty("backgroundColor", backgroundColor, defaultValue: null),
    );
    properties.add(DoubleProperty("elevation", elevation, defaultValue: null));
    properties
        .add(ColorProperty("shadowColor", shadowColor, defaultValue: null));
    properties.add(
      ColorProperty(
        "surfaceTintColor",
        surfaceTintColor,
        defaultValue: null,
      ),
    );
    properties.add(
      ColorProperty("indicatorColor", indicatorColor, defaultValue: null),
    );
    properties.add(
      DiagnosticsProperty<ShapeBorder>(
        "indicatorShape",
        indicatorShape,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<WidgetStateProperty<TextStyle?>>(
        "labelTextStyle",
        labelTextStyle,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<WidgetStateProperty<IconThemeData?>>(
        "iconTheme",
        iconTheme,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<NavigationDestinationLabelBehavior>(
        "labelBehavior",
        labelBehavior,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<WidgetStateProperty<Color?>>(
        "overlayColor",
        overlayColor,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<WidgetStateProperty<Color?>>(
        "navigationItemOverlayColor",
        navigationItemOverlayColor,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<ShapeBorder>(
        "navigationItemIndicatorShape",
        navigationItemIndicatorShape,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry?>(
        "margin",
        margin,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry?>(
        "padding",
        padding,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<Offset?>(
        "tooltipOffset",
        tooltipOffset,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsetsGeometry?>(
        "labelPadding",
        labelPadding,
      ),
    );
    properties.add(
      DiagnosticsProperty<TooltipTriggerMode?>(
        "tooltipTrigger",
        tooltipTrigger,
        defaultValue: null,
      ),
    );
  }

  factory NavigationBarThemeData.fromMaterial(
    m.NavigationBarThemeData? other,
  ) {
    if (other is NavigationBarThemeData) {
      return other;
    }
    return NavigationBarThemeData(
      height: other?.height,
      backgroundColor: other?.backgroundColor,
      elevation: other?.elevation,
      shadowColor: other?.shadowColor,
      surfaceTintColor: other?.surfaceTintColor,
      indicatorColor: other?.indicatorColor,
      indicatorShape: other?.indicatorShape,
      labelTextStyle: other?.labelTextStyle,
      iconTheme: other?.iconTheme,
      labelBehavior: other?.labelBehavior,
      overlayColor: other?.overlayColor,
      navigationItemOverlayColor: null,
      navigationItemIndicatorShape: null,
      margin: null,
      padding: null,
      tooltipOffset: null,
      labelPadding: other?.labelPadding,
      tooltipTrigger: null,
    );
  }
}

/// An inherited widget that defines visual properties for [NavigationBar]s and
/// [NavigationDestination]s in this widget's subtree.
///
/// Values specified here are used for [NavigationBar] properties that are not
/// given an explicit non-null value.
///
/// See also:
///
///  * [ThemeData.navigationBarTheme], which describes the
///    [NavigationBarThemeData] in the overall theme for the application.
class NavigationBarTheme extends InheritedTheme
    implements m.NavigationBarTheme {
  /// Creates a navigation rail theme that controls the
  /// [NavigationBarThemeData] properties for a [NavigationBar].
  const NavigationBarTheme({
    required this.data,
    required super.child,
    super.key,
  });

  /// Specifies the background color, label text style, icon theme, and label
  /// type values for descendant [NavigationBar] widgets.
  @override
  final NavigationBarThemeData data;

  /// The closest instance of this class that encloses the given context.
  ///
  /// If there is no enclosing [NavigationBarTheme] widget, then
  /// [ThemeData.navigationBarTheme] is used.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// NavigationBarThemeData theme = NavigationBarTheme.of(context);
  /// ```
  static NavigationBarThemeData? maybeOf(BuildContext context) {
    // The user is using NavigationBarTheme from this package.
    final NavigationBarTheme? navigationBarTheme =
        context.dependOnInheritedWidgetOfExactType<NavigationBarTheme>();
    if (navigationBarTheme != null) {
      return navigationBarTheme.data;
    }

    // The user is using Flutter's Material NavigationBarThemeData, so we
    // convert it to our own NavigationBarThemeData.
    final m.NavigationBarThemeData materialNavigationBarTheme =
        m.NavigationBarTheme.of(context);

    if (materialNavigationBarTheme is NavigationBarThemeData) {
      return materialNavigationBarTheme;
    }

    final bool hasAnyExplicitValue =
        materialNavigationBarTheme.height != null ||
            materialNavigationBarTheme.backgroundColor != null ||
            materialNavigationBarTheme.elevation != null ||
            materialNavigationBarTheme.shadowColor != null ||
            materialNavigationBarTheme.surfaceTintColor != null ||
            materialNavigationBarTheme.indicatorColor != null ||
            materialNavigationBarTheme.indicatorShape != null ||
            materialNavigationBarTheme.labelTextStyle != null ||
            materialNavigationBarTheme.iconTheme != null ||
            materialNavigationBarTheme.labelBehavior != null ||
            materialNavigationBarTheme.overlayColor != null ||
            materialNavigationBarTheme.labelPadding != null;

    if (!hasAnyExplicitValue) {
      return null;
    }

    return NavigationBarThemeData.fromMaterial(materialNavigationBarTheme);
  }

  static NavigationBarThemeData of(BuildContext context) {
    final NavigationBarThemeData defaults = defaultsFor(context);

    final NavigationBarThemeData? explicitTheme = maybeOf(context);
    if (explicitTheme != null) {
      return defaults.copyWith(
        height: explicitTheme.height,
        backgroundColor: explicitTheme.backgroundColor,
        elevation: explicitTheme.elevation,
        shadowColor: explicitTheme.shadowColor,
        surfaceTintColor: explicitTheme.surfaceTintColor,
        indicatorColor: explicitTheme.indicatorColor,
        indicatorShape: explicitTheme.indicatorShape,
        labelTextStyle: explicitTheme.labelTextStyle,
        iconTheme: explicitTheme.iconTheme,
        labelBehavior: explicitTheme.labelBehavior,
        overlayColor: explicitTheme.overlayColor,
        navigationItemOverlayColor: explicitTheme.navigationItemOverlayColor,
        navigationItemIndicatorShape:
            explicitTheme.navigationItemIndicatorShape,
        margin: explicitTheme.margin,
        padding: explicitTheme.padding,
        tooltipOffset: explicitTheme.tooltipOffset,
        labelPadding: explicitTheme.labelPadding,
        tooltipTrigger: explicitTheme.tooltipTrigger,
      );
    }

    return defaults;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return NavigationBarTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(NavigationBarTheme oldWidget) =>
      data != oldWidget.data;
}

NavigationBarThemeData defaultsFor(BuildContext context) {
  return Theme.of(context).useMaterial3
      ? NavigationBarDefaultsM3(context)
      : NavigationBarDefaultsM2(context);
}

// Hand coded defaults based on Material Design 2.
class NavigationBarDefaultsM2 extends NavigationBarThemeData {
  NavigationBarDefaultsM2(BuildContext context)
      : _theme = Theme.of(context),
        _colors = Theme.of(context).colorScheme,
        super(
          height: 80.0,
          elevation: 0.0,
          labelPadding: const EdgeInsets.only(top: 4),
          indicatorShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        );

  final ThemeData _theme;
  final ColorScheme _colors;

  // With Material 2, the NavigationBar uses an overlay blend for the
  // default color regardless of light/dark mode.
  @override
  Color? get backgroundColor => ElevationOverlay.colorWithOverlay(
        _colors.surface,
        _colors.onSurface,
        3.0,
      );

  @override
  WidgetStateProperty<IconThemeData?>? get iconTheme {
    return WidgetStatePropertyAll<IconThemeData>(
      IconThemeData(
        size: 24,
        color: _colors.onSurface,
      ),
    );
  }

  @override
  Color? get indicatorColor => _colors.secondary.withValues(alpha: 0.24);

  @override
  WidgetStateProperty<TextStyle?>? get labelTextStyle =>
      WidgetStatePropertyAll<TextStyle?>(
        _theme.textTheme.labelSmall!.copyWith(color: _colors.onSurface),
      );

  @override
  WidgetStateProperty<Color?>? get overlayColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.pressed) ||
          states.contains(WidgetState.focused)) {
        return _colors.onSurface.withValues(alpha: 0.12);
      }
      if (states.contains(WidgetState.hovered)) {
        return _colors.onSurface.withValues(alpha: 0.08);
      }
      return null;
    });
  }

  @override
  WidgetStateProperty<Color?>? get navigationItemOverlayColor {
    return overlayColor;
  }
}

// BEGIN GENERATED TOKEN PROPERTIES - NavigationBar

// Do not edit by hand. The code between the "BEGIN GENERATED" and
// "END GENERATED" comments are generated from data in the Material
// Design token database by the script:
//   dev/tools/gen_defaults/bin/gen_defaults.dart.

class NavigationBarDefaultsM3 extends CustomNavigationBarThemeData {
  NavigationBarDefaultsM3(this.context)
      : super(
          height: 80.0,
          elevation: 3.0,
          labelPadding: const EdgeInsets.only(top: 4),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => _colors.surfaceContainer;

  @override
  Color? get shadowColor => Colors.transparent;

  @override
  Color? get surfaceTintColor => Colors.transparent;

  @override
  WidgetStateProperty<IconThemeData?>? get iconTheme {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      return IconThemeData(
        size: 24.0,
        color: states.contains(WidgetState.disabled)
            ? _colors.onSurfaceVariant.withValues(alpha: 0.38)
            : states.contains(WidgetState.selected)
                ? _colors.onSecondaryContainer
                : _colors.onSurfaceVariant,
      );
    });
  }

  @override
  Color? get indicatorColor => _colors.secondaryContainer;
  @override
  ShapeBorder? get indicatorShape => const StadiumBorder();

  @override
  WidgetStateProperty<TextStyle?>? get labelTextStyle {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      final TextStyle style = _textTheme.labelMedium!;
      return style.apply(
        color: states.contains(WidgetState.disabled)
            ? _colors.onSurfaceVariant.withValues(alpha: 0.38)
            : states.contains(WidgetState.selected)
                ? _colors.onSurface
                : _colors.onSurfaceVariant,
      );
    });
  }

  @override
  WidgetStateProperty<Color?>? get overlayColor {
    return WidgetStateProperty.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.pressed) ||
          states.contains(WidgetState.focused)) {
        return _colors.onSurface.withValues(alpha: 0.12);
      }
      if (states.contains(WidgetState.hovered)) {
        return _colors.onSurface.withValues(alpha: 0.08);
      }
      return null;
    });
  }

  @override
  WidgetStateProperty<Color?>? get navigationItemOverlayColor {
    return overlayColor;
  }
}

// END GENERATED TOKEN PROPERTIES - NavigationBar
