// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import "package:flutter/material.dart";

import "../../navigation_rail_theme.dart" as c;

/// The default minimum rail width used by the Material 2 fallback theme.
const double navigationRailMinWidthM2 = 72.0;

/// Returns the default [NavigationRailThemeData] for the active Material
/// version.
///
/// Material 3 uses token-based defaults, while Material 2 falls back to the
/// legacy hand-authored defaults until Material 2 support is removed.
c.NavigationRailThemeData navigationRailDefaultsFor(BuildContext context) {
  // TODO(v6.0.0): Remove useMaterial3 check and M2 fallback branch.
  return Theme.of(context).useMaterial3
      ? _NavigationRailDefaultsM3(context)
      : _NavigationRailDefaultsM2(context);
}

/// Hand-coded defaults based on Material Design 2.
@Deprecated(
  "Material 2 is deprecated in Flutter and will be removed in v6.0.0 of this package. "
  "Migrate to Material 3 by relying on the default M3 behavior.",
)
class _NavigationRailDefaultsM2 extends c.NavigationRailThemeData {
  _NavigationRailDefaultsM2(BuildContext context)
      : _theme = Theme.of(context),
        _colors = Theme.of(context).colorScheme,
        super(
          elevation: 0,
          groupAlignment: -1,
          labelType: NavigationRailLabelType.none,
          useIndicator: false,
          minWidth: navigationRailMinWidthM2,
          minExtendedWidth: 256,
        );

  final ThemeData _theme;
  final ColorScheme _colors;

  @override
  Color? get backgroundColor => _colors.surface;

  @override
  TextStyle? get unselectedLabelTextStyle {
    return _theme.textTheme.bodyLarge!
        .copyWith(color: _colors.onSurface.withValues(alpha: 0.64));
  }

  @override
  TextStyle? get selectedLabelTextStyle {
    return _theme.textTheme.bodyLarge!.copyWith(color: _colors.primary);
  }

  @override
  IconThemeData? get unselectedIconTheme {
    return IconThemeData(
      size: 24.0,
      color: _colors.onSurface,
      opacity: 0.64,
    );
  }

  @override
  IconThemeData? get selectedIconTheme {
    return IconThemeData(
      size: 24.0,
      color: _colors.primary,
      opacity: 1.0,
    );
  }

  @override
  WidgetStateProperty<Color?>? get destinationOverlayColor {
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
}

// BEGIN GENERATED TOKEN PROPERTIES - NavigationRail

// Do not edit by hand. The code between the "BEGIN GENERATED" and
// "END GENERATED" comments are generated from data in the Material
// Design token database by the script:
//   dev/tools/gen_defaults/bin/gen_defaults.dart.

/// Generated Material 3 defaults for [NavigationRail].
class _NavigationRailDefaultsM3 extends c.NavigationRailThemeData {
  _NavigationRailDefaultsM3(this.context)
      : super(
          elevation: 0.0,
          groupAlignment: -1,
          labelType: NavigationRailLabelType.none,
          useIndicator: true,
          minWidth: 80.0,
          minExtendedWidth: 256,
        );

  final BuildContext context;
  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;

  @override
  Color? get backgroundColor => _colors.surface;

  @override
  TextStyle? get unselectedLabelTextStyle {
    return _textTheme.labelMedium!.copyWith(color: _colors.onSurface);
  }

  @override
  TextStyle? get selectedLabelTextStyle {
    return _textTheme.labelMedium!.copyWith(color: _colors.onSurface);
  }

  @override
  IconThemeData? get unselectedIconTheme {
    return IconThemeData(
      size: 24.0,
      color: _colors.onSurfaceVariant,
    );
  }

  @override
  IconThemeData? get selectedIconTheme {
    return IconThemeData(
      size: 24.0,
      color: _colors.onSecondaryContainer,
    );
  }

  @override
  Color? get indicatorColor => _colors.secondaryContainer;

  @override
  ShapeBorder? get indicatorShape => const StadiumBorder();

  @override
  WidgetStateProperty<Color?>? get destinationOverlayColor {
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
}
