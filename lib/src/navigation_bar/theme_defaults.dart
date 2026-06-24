// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import "package:flutter/material.dart";

import "../../navigation_bar_theme.dart" as c;

c.NavigationBarThemeData navigationBarDefaultsFor(BuildContext context) {
  return Theme.of(context).useMaterial3
      ? _NavigationBarDefaultsM3(context)
      : _NavigationBarDefaultsM2(context);
}

// Hand coded defaults based on Material Design 2.
class _NavigationBarDefaultsM2 extends c.NavigationBarThemeData {
  _NavigationBarDefaultsM2(BuildContext context)
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
  Color? get indicatorColor => _colors.secondary.withValues(alpha: 61 / 255);

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
        return _colors.onSurface.withValues(alpha: 0.04);
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

class _NavigationBarDefaultsM3 extends c.NavigationBarThemeData {
  _NavigationBarDefaultsM3(this.context)
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
