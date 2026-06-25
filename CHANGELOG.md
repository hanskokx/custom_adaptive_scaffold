## 5.2.0

- **[FEAT]** Added M3 small and large badge support to `NavigationDestination`, `NavigationBar`, and `NavigationRail`.
  - `NavigationDestination.badge` (`int?`): set to a positive integer to show a badge. Values greater than `99` automatically display as `"99+"`. Must be `null` or greater than `0`.
  - `NavigationDestination.badgeStyle` (`NavigationBadgeStyle`): controls the badge presentation.
    - `count` (default) — shows the numeric value.
    - `dot` — shows a small dot indicator regardless of the count.
    - `hidden` — suppresses the badge entirely while retaining the count value in the widget tree.
  - `NavigationRailThemeData.badgeThemeData` and `NavigationBarThemeData.badgeThemeData` (`BadgeThemeData?`): theme-level badge styling (color, text style, size) scoped to navigation destinations.

## 5.1.0

- **[FEAT]** Improved large icon support for `NavigationBar` and `NavigationRail`.
  - Indicator and icon-slot sizing now scale correctly for explicit large icon theme overrides.
  - Rail destination spacing and indicator alignment were refined for large icon use cases.
  - The maximum allowed sizes are `72` for the `NavigationRail` and `60` for the `NavigationBar`.
- **[FEAT]** Added `NavigationRailThemeData.iconTheme` support to the package-owned rail theme data.
  - This brings the `NavigationRailThemeData.iconTheme` into parity with the pre-existing `NavigationBarThemeData.iconTheme`
- **[IMPROVEMENT]** `NavigationBarTheme.maybeOf(context)` now resolves explicit theme intent more accurately.
- **[IMPROVEMENT]** `AdaptiveScaffold.standardBottomNavigationBar` now better respects existing themed icon sizes.
  - `iconSize` is now optional and falls back to themed icon size before defaulting to `24.0` (the Material 3 default).
  - Legacy `iconSize`, `padding`, and `margin` overrides are marked deprecated in favor of theme-driven configuration.
    - This is in preparation for the upcoming 6.0.0 release, wherein Material 2 support is planned to be removed.

## 5.0.1

- No package changes
- Documentation has been updated

## 5.0.0

This release is a near-complete rewrite of the navigation layer. The package now more closely mirrors the look, feel, and API of the corresponding Flutter framework widgets, while maintaining feature parity with 4.x through a redesigned extension surface described below.

Furthermore, great care was taken in porting over the latest changes from the Flutter framework to capture any upstream changes which includes bugfixes. In addition to this, the entire suite of upstream tests were brought into this package and now all pass when using the default package configuration.

This release represents a massive milestone in stability and maturity for this package, as I strive to become the de-facto standard replacement for the work that the Flutter team will/has deprecate(d).

The future 6.0.0 release of this package will seek to remove Material 2 support, as it is no longer supported by default in the Material package.

### Breaking changes

- All 4.x navigation customization APIs have been removed. Feature parity is maintained; see **Migration from 4.x** below for the new equivalents.

  Removed APIs:
  - `NavigationDestinationRegion` enum and `destinationFillRegion` / `destinationHoverRegion` parameters.
  - `AdaptiveScaffoldNavigationThemeData` and the `navigationTheme` parameter on `AdaptiveScaffold`.
  - `destinationFillShape` and `destinationHoverShape` parameters.
  - `NavigationDestinationAnimation` enum and the `transitionAnimation`, `transitionCurve`, `transitionDuration`, `iconBuilder`, `transitionBuilder`, `iconIndicatorShape`, and `labelIndicatorShape` parameters on `CustomNavigationDestination`.
  - `NavigationDestinationIconBuilder` and `NavigationDestinationTransitionBuilder` typedefs.
  - `hideLabel` on destinations.

### New APIs

- `NavigationDestination` is now the package's own full base class (not a thin wrapper around Flutter's widget). It can be used directly or
  subclassed. `CustomNavigationDestination` remains as a typedef alias.
- New `NavigationBarDestination` subclass for bar-specific rendering.
- New `NavigationRailDestination` subclass for rail-specific rendering.
- `NavigationBarThemeData` and `NavigationRailThemeData` are now package-owned classes implementing the Flutter framework interfaces.
  `CustomNavigationBarThemeData`, `CustomNavigationBarTheme`, `CustomNavigationRailThemeData`, and `CustomNavigationRailTheme` are typedef aliases for the package types.
- Both theme types gain the following fields not present in Flutter or 4.x:
  - `destinationOverlayColor` — overlay colors for the full destination item container by widget state (replaces `destinationFillRegion`).
  - `navigationItemIndicatorShape` — shape for the full-item ink well (replaces `destinationFillShape` / `destinationHoverShape`).
  - `margin` — margin around each navigation item.
  - `padding` — padding inside each navigation item content area.
  - `tooltipOffset` — x/y offset for tooltip popovers (replaces `tooltipVerticalOffset`).
  - `tooltipTrigger` — gesture that triggers the tooltip.
  - `tooltipTriggerWhenLabelVisible` — override trigger when label is shown.
  - `tooltipTriggerWhenLabelHidden` — override trigger when label is hidden.
- `NavigationRailThemeData` additionally gains `showLabelsWhenCollapsed` — show labels while the rail is collapsed and `labelType` is `NavigationRailLabelType.none` (new capability not present in 4.x).
- `NavigationDestination` gains per-destination `indicatorShape` (replaces per-destination `iconIndicatorShape` / `labelIndicatorShape` from 4.x).

### Fixes and improvements

- `AdaptiveScaffold.destinations` is no longer `required` and defaults to `const []`, allowing 0 or 1 destinations without assertion errors.
- Bottom navigation bar is suppressed when fewer than 2 destinations are provided, matching the underlying `NavigationBar` widget's constraint.
- `selectedIndex` is now normalized at the `AdaptiveScaffold` boundary: if the index is out of range or destinations is empty, `null` is passed to
  navigation components to avoid downstream assertion failures.
- All rail breakpoints (medium, mediumLarge, large, extraLarge) now share a single destination conversion pipeline that consistently applies
  `navigationRailDestinationBuilder` when provided. Previously, the large and extraLarge breakpoints bypassed the custom builder.
- Fixed a bug where duplicate destinations in the list caused `navigationRailDestinationBuilder` to receive the first-match index instead
  of the positional index.

### Migration from 4.x

#### Full-item fill / highlight region

The `destinationFillRegion` / `destinationHoverRegion` / `destinationFillShape` / `destinationHoverShape` parameters are replaced by theme data properties.

```dart
// 4.x — destination fill covering the entire item row:
navigationTheme: const AdaptiveScaffoldNavigationThemeData(
  destinationFillRegion: NavigationDestinationRegion.full,
  destinationFillShape: StadiumBorder(),
),

// Current — same effect via theme:
theme: ThemeData(
  navigationRailTheme: NavigationRailThemeData(
    destinationOverlayColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.24)
          : states.contains(WidgetState.hovered)
              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08)
              : null,
    ),
    navigationItemIndicatorShape: const StadiumBorder(),
  ),
),
```

To use the default icon-only rendering (equivalent to 4.x's `NavigationDestinationRegion.icon`, and the current default when `destinationOverlayColor` is `null`), simply omit `destinationOverlayColor` from the theme.

#### Label type per breakpoint

The `AdaptiveScaffoldNavigationThemeData(compactLabelType: ..., expandedLabelType: ...)` pattern is replaced by standard `NavigationRailThemeData.labelType`.

```dart
// 4.x:
navigationTheme: const AdaptiveScaffoldNavigationThemeData(
  compactLabelType: NavigationRailLabelType.selected,
  expandedLabelType: NavigationRailLabelType.all,
),

// Current — set via ThemeData or build two separate NavigationRail instances
// for compact vs extended, each with their own labelType:
NavigationRail(
  labelType: NavigationRailLabelType.selected, // compact
  extended: false,
  destinations: /* … */,
)
NavigationRail(
  labelType: NavigationRailLabelType.all,      // extended
  extended: true,
  destinations: /* … */,
)
// Or theme-wide:
theme: ThemeData(
  navigationRailTheme: NavigationRailThemeData(
    labelType: NavigationRailLabelType.selected,
  ),
),
```

#### Hiding a destination label

```dart
// 4.x:
CustomNavigationDestination(icon: Icon(Icons.inbox), hideLabel: true),

// Current — use labelBehavior on the bar theme for bar destinations:
NavigationBarThemeData(
  labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
),
// Or for a single destination, omit the label and use tooltip only:
NavigationDestination(icon: Icon(Icons.inbox), tooltip: 'Inbox'),
```

#### Per-destination indicator shape

```dart
// 4.x:
CustomNavigationDestination(
  icon: Icon(Icons.inbox),
  iconIndicatorShape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
),

// Current:
NavigationDestination(
  icon: Icon(Icons.inbox),
  indicatorShape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
),
```

#### Tooltip vertical offset

```dart
// 4.x (CustomNavigationBarThemeData):
tooltipVerticalOffset: 48.0,

// Current:
NavigationBarThemeData(
  tooltipOffset: Offset(0, 48),
),
```

#### Destination transition animations

`NavigationDestinationAnimation` (`none`, `fadeSwap`, `scale`) and the related `transitionAnimation`, `transitionCurve`, `transitionDuration`, `iconBuilder`, and `transitionBuilder` destination parameters are not present in this version. The icon/label transition uses the standard Flutter selection animation. Custom icon transition logic can be implemented by subclassing [NavigationDestination] and overriding `build`.

## 4.1.0

- **[BREAKING]** `destinationFillShape` and `destinationHoverShape` removed.
  Removed from `AdaptiveScaffoldNavigationThemeData`, `AdaptiveScaffold`,
  `CustomNavigationBar`, `CustomNavigationRail`, and `RailDestination`.
  Functionality is now consolidated into `ThemeData.appBarTheme.shape`.

  **Before:**

  ```dart
  navigationTheme: const AdaptiveScaffoldNavigationThemeData(
    destinationFillShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
    ),
    destinationHoverShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
    ),
  ),
  ```

  **After:**

  ```dart
  appBarTheme: const AppBarTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
    ),
  ),
  ```

## 4.0.2

- **[FEAT]** `destinationHoverShape` is now independently configurable
  alongside `destinationFillShape` on `CustomNavigationBar`,
  `CustomNavigationRail`, `RailDestination`, and
  `AdaptiveScaffoldNavigationThemeData`.
- **[FEAT]** `NavigationDestinationRegion.full` now renders edge-to-edge with
  stable icon positioning in `CustomNavigationRail`,
  `CustomNavigationBar`, and `AdaptiveScaffold.standardNavigationRail`.
- **[FIX]** `NavigationDestinationRegion.content` preserves padded icon
  interaction bounds when labels are hidden.
- **[FIX]** `NavigationDestinationRegion.label` no longer falls back to icon
  pills when labels are hidden.

## 4.0.1

- **[FEAT]** Adaptive rail examples updated with interactive expand/collapse
  flows.
- **[FEAT]** `AdaptiveScaffold.standardNavigationRail` now animates rail
  width changes with a width tween.
- **[FEAT]** Expanded tooltip support across custom navigation rail and bar
  destinations; tooltip falls back to destination labels when no explicit
  tooltip text is provided.
- **[FIX]** Rail destination transition overflow edge cases addressed;
  refined compact/extended handoff behavior.
- **[TEST]** Added/updated tests for tooltip behavior and manual visibility
  handling.

## 4.0.0

- **[CHANGE]** Compact rail fill/highlight defaults to Flutter-style
  icon-scoped rendering. To keep legacy full-fill, set
  `destinationFillRegion: NavigationDestinationRegion.full` explicitly.
- **[CHANGE]** `CustomNavigationBarThemeData.margin`, `padding`,
  `tooltipVerticalOffset` and `CustomNavigationRailThemeData.margin`,
  `padding` are now nullable.
- **[FEAT]** `AdaptiveScaffold` adds `navigationTheme`
  (`AdaptiveScaffoldNavigationThemeData`) for consolidated adaptive
  navigation overrides: `compactLabelType`, `expandedLabelType` (defaults to
  `all`), destination transition animation/curve/duration, fill mode/shape.
- **[FEAT]** `destinationFillRegion` and `destinationFillShape` supported on
  `CustomNavigationBar`, `CustomNavigationRail`,
  `standardBottomNavigationBar`, `standardNavigationRail`. Modes: `none`,
  `icon`, `content`, `label`, `full`.
- **[FEAT]** `destinationHoverRegion` configurable independently; defaults
  to fill mode.
- **[CHANGE]** `destinationFillMode` → `destinationFillRegion`;
  `destinationHoverMode` → `destinationHoverRegion`;
  `NavigationDestinationFillMode` → `NavigationDestinationRegion`.
- **[FEAT]** `CustomNavigationDestination` now supports: `hideLabel`,
  `transitionAnimation`, `transitionCurve`, `transitionDuration`,
  `iconBuilder`, `transitionBuilder`, `iconIndicatorShape`,
  `labelIndicatorShape`. `NavigationDestinationAnimation` presets: `none`,
  `fadeSwap`, `scale`. Public builder typedefs:
  `NavigationDestinationIconBuilder`,
  `NavigationDestinationTransitionBuilder`.
- **[FEAT]** `CustomNavigationRail` supports `iconTransitionAnimation`,
  `iconTransitionCurve`, `iconTransitionDuration`,
  `destinationTransitionBuilder`.
- **[FEAT]** `CustomNavigationBar` and `NavigationIndicator` now exported
  from the package root. `navigation_destination_types.dart` exported.
- **[FIX]** `CustomNavigationDestination.tooltip` no longer falls back to
  label text when `null`.
- **[SYNC]** Large Flutter framework parity update: role-based semantics on
  navigation bar (`tabBar`/`tab`), destination semantics,
  `NavigationIndicator` rendering, label padding, broad
  framework-mirror regression coverage.

## 3.0.2

- **[FIX]** `AdaptiveScaffold.standardBottomNavigationBar` now normalises
  plain `NavigationDestination` values to `CustomNavigationDestination` to
  prevent `_NavigationDestinationInfo` assertion failures.
- Adds regression test.

## 3.0.1

- [FIX] Attaching an `AdaptiveScaffoldController` without `initialIntent` now
  preserves legacy small-layout behavior until `showBody()` or
  `showSecondaryBody()` is called.
- `AdaptiveScaffoldController` now exposes:
  - optional `initialIntent`

## 3.0.0

- This version leveraged the usage of AI-assisted coding. Please submit bug
  reports for any behavioral regressions or unexpected behavior.
- Adds an optional collapsed-pane controller API to `AdaptiveScaffold` via the `controller` parameter.
- Adds `AdaptiveScaffoldController`, `AdaptiveScaffoldScope`, and `PanelFocus` for controlling collapsed body/secondaryBody visibility.
- `PanelFocus` uses slot-aligned values:
  - `PanelFocus.body`
  - `PanelFocus.secondaryBody`
- `AdaptiveScaffoldController` exposes:
  - `showBody()`
  - `showSecondaryBody()`
- Adds documentation and examples for collapsed body/secondaryBody pane control.

- [FIX] Fixed the shape of the indicators in both the navigation bar and
  navigation rail.

## 2.0.2

- Fixes compatibility with Flutter 3.35.x

## 2.0.1

- Backported memory leak fix (See: <https://github.com/flutter/packages/pull/8546>)

## 2.0.0

- Updated to support Flutter 3.19.0

## 1.0.0

- Forked from flutter_adaptive_scaffold

## 0.3.1

- Use improved MediaQuery methods.

## 0.3.0

- Adds `inDuration`, `outDuration`, `inCurve`, and `outCurve` parameters for
configuring additional `SlotLayoutConfig` animation behavior.
- **BREAKING CHANGES**:
  - Removes `duration` parameter from `SlotLayoutConfig`.

## 0.2.6

- Add new sample for using AdaptiveScaffold with GoRouter.

## 0.2.5

- Fix breakpoint not being active in certain cases like foldables.

## 0.2.4

- Compare breakpoints to each other using operators.

## 0.2.3

- Update the spacing and margins to the latest material m3 specs.
- Add `margin`, `spacing`, `padding`, `recommendedPanes` and `maxPanes` with their Material value to `Breakpoint`.

## 0.2.2

- Fix a bug where landscape would not show body when using `andUp`.

## 0.2.1

- Add `Breakpoint.activeBreakpointOf(context)` to find the currently active breakpoint.
- Don't check for height on Desktop platforms.

## 0.2.0

- Add breakpoints for mediumLarge and extraLarge.
- Add height and orientation based breakpoint checks.
- **BREAKING CHANGES**:
  - Removes `WidthPlatformBreakpoint`
  - Breakpoints can now be constructed directly with `Breakpoint`
  - Checks for `andUp` or `platform` can be done as parameter: `Breakpoint.small(andUp: true, platform: Breakpoint.mobile)`

## 0.1.12

- Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.
- Updates minimum supported SDK version to Flutter 3.19/Dart 3.3.
- Expose `labelType` for NavigationRails.
- Add `navigationRailDestinationBuilder` to apply custom Destinations.
- Add `groupAlignment` property to change alignment.
- Set `navRailTheme` when using the Drawer just like the other NavigationRails.

## 0.1.11+1

- Allows custom animation duration for the NavigationRail and
  BottomNavigationBar transitions. [flutter/flutter#112938](https://github.com/flutter/flutter/issues/112938)

## 0.1.11

- Updates minimum supported SDK version to Flutter 3.19/Dart 3.3.
- Migrates deprecated MaterialState and MaterialStateProperty to WidgetState and WidgetStateProperty.

## 0.1.10+2

- Reduce rebuilds when invoking `isActive` method.

## 0.1.10+1

- Removes a broken design document link from the README.

## 0.1.10

- FIX : Assertion added when tried with less than 2 destinations - [flutter/flutter#110902](https://github.com/flutter/flutter/issues/110902)

## 0.1.9

- FIX : Drawer stays open even on destination tap - [flutter/flutter#141938](https://github.com/flutter/flutter/issues/141938)
- Updates minimum supported SDK version to Flutter 3.13/Dart 3.1.

## 0.1.8

- Adds `transitionDuration` parameter for specifying how long the animation should be.

## 0.1.7+2

- Fixes new lint warnings.

## 0.1.7+1

- Adds pub topics to package metadata.

## 0.1.7

- Fix top padding for NavigationBar.
- Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 0.1.6

- Added support for displaying an AppBar on any Breakpoint by introducing appBarBreakpoint

## 0.1.5

- Added support for Right-to-left (RTL) directionality.
- Fixes stale ignore: prefer_const_constructors.
- Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.

## 0.1.4

- Use Material 3 NavigationBar instead of BottomNavigationBar

## 0.1.3

- Fixes `groupAlignment` property not available in `standardNavigationRail` - [flutter/flutter#121994](https://github.com/flutter/flutter/issues/121994)

## 0.1.2

- Fixes `NavigationRail` items not considering `NavigationRailTheme` values - [flutter/flutter#121135](https://github.com/flutter/flutter/issues/121135)
- When `NavigationRailTheme` is provided, it will use the theme for values that the user has not given explicit theme-related values for.

## 0.1.1

- Fixes flutter/flutter#121135) `selectedIcon` parameter not displayed even if it is provided.

## 0.1.0+1

- Aligns Dart and Flutter SDK constraints.

## 0.1.0

- Change the `selectedIndex` parameter on `standardNavigationRail` to allow null values to indicate "no destination".
- An explicitly null `currentIndex` parameter passed to `standardBottomNavigationBar` will also default to 0, just like implicitly null missing parameters.

## 0.0.9

- Fix passthrough of `leadingExtendedNavRail`, `leadingUnextendedNavRail` and `trailingNavRail`

## 0.0.8

Make fuchsia a mobile platform.

## 0.0.7

- Patch duplicate key error in SlotLayout.

## 0.0.6

- Change type of `appBar` parameter from `AppBar?` to `PreferredSizeWidget?`

## 0.0.5

- Calls onDestinationChanged callback in bottom nav bar.

## 0.0.4

- Fix static analyzer warnings using `core` lint.

## 0.0.3

- First published version.

## 0.0.2

- Adds some more examples.

## 0.0.1+1

- Updates text theme parameters to avoid deprecation issues.

## 0.0.1

- Initial release
