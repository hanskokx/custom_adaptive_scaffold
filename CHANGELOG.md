## 4.1.0+1

* **[FEAT] `AdaptiveScaffoldThemeData` is now a `ThemeExtension`**
  * You can configure adaptive navigation defaults directly through
    `ThemeData.extensions`.
  * `AdaptiveScaffold` now resolves navigation theme values with this
    precedence:
    1. `AdaptiveScaffold.navigationTheme`
    2. nearest `AdaptiveScaffoldTheme`
    3. `ThemeData.extensions`
    4. defaults

* **[DOC] Updated migration guidance and examples**
  * Updated README and example app to use `AdaptiveScaffoldThemeData` and the
    new `ThemeData.extensions` integration path.

* **[CHANGE] `AdaptiveScaffoldNavigationThemeData` has been renamed to `AdaptiveScaffoldThemeData`**

* **[BREAKING] `destinationFillShape` and `destinationHoverShape` removed**
  * `destinationFillShape` and `destinationHoverShape` were removed from:
    * `AdaptiveScaffoldThemeData`
    * `AdaptiveScaffold` (navigation helpers / navigationTheme)
    * `CustomNavigationBar`
    * `CustomNavigationRail`
    * `RailDestination`
  * Added/standardized a single `shape` property for destination interaction
    geometry.
  * Selected fill and hover/pressed interaction now resolve from the same
    shape value.
  * The functionality is now consolidated into `navigationTheme.shape`.
  * Migration: remove the old parameters and set `navigationTheme.shape` via
    `AdaptiveScaffoldThemeData`.

Before:

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

After:

```dart
navigationTheme: const AdaptiveScaffoldThemeData(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(4)),
  ),
),
```

## 4.0.0 - REDACTED

* This version was redacted due to an incorrect attempt at specifying a theme object.

## 4.0.2

* **[FEAT] Destination hover shape is now configurable independently**
  * Added `destinationHoverShape` alongside `destinationFillShape` on
    `CustomNavigationBar`, `CustomNavigationRail`, `RailDestination`, and
    `AdaptiveScaffoldNavigationThemeData` (applied via `AdaptiveScaffold.navigationTheme`).
  * When set, `destinationHoverShape` controls the shape of the hover/ink
    interaction independently from the selected-fill shape.
  * When omitted, hover shape falls back to `destinationFillShape`, preserving
    existing behavior.

* **[FEAT] Full destination fill regions now render edge-to-edge with stable icon positioning**
  * Improved `NavigationDestinationRegion.full` behavior for
    `CustomNavigationRail`, `CustomNavigationBar`, and
    `AdaptiveScaffold.standardNavigationRail` so the fill region can use the
    full lane while keeping icon alignment stable.
  * In extended rail layouts, destination containers now expand to lane width
    while preserving expected icon/label composition.

* **[FIX] Content fill mode now preserves padded icon interaction bounds when labels are hidden**
  * In `NavigationDestinationRegion.content`, hidden-label destinations now
    keep a padded icon interaction rect instead of collapsing to icon-only
    bounds.

* **[FIX] Label-only fill mode no longer falls back to icon pills when labels are hidden**
  * In `NavigationDestinationRegion.label`, when labels are not visible,
    interaction/highlight rects now resolve to no label-region highlight rather
    than painting an icon-region fallback pill.

* No breaking API changes in this release.

## 4.0.1

* **[FEAT] Adaptive rail examples now support explicit expand/collapse flows**
  * Updated the primary example to demonstrate interactive expanded and
    collapsed navigation rail states.
  * Added menu affordances in the example to collapse and re-expand the rail.
  * Added smoother visual transition behavior between compact and extended
    rail states in the example experience.
* **[FEAT] AdaptiveScaffold standard rail helper now animates rail width changes**
  * `AdaptiveScaffold.standardNavigationRail` now transitions between compact
    and extended widths with an animated width tween.
  * Improves visual continuity for apps that toggle `extended` at runtime.
* **[FEAT] Tooltip behavior for custom navigation destinations was expanded**
  * Enhanced tooltip support across custom navigation rail and navigation bar
    destinations.
  * Added manual tooltip visibility handling for navigation components to
    improve behavior consistency across interaction modes.
  * Tooltip behavior now falls back to destination labels when no explicit
    tooltip text is provided.
* **[FIX] Rail destination transition overflow edge cases were addressed**
  * Refined extended/collapsed transition behavior in destination layout to
    avoid transient horizontal overflow during width-animation boundary frames.
  * Improved compact/extended handoff behavior so destination composition is
    more stable while animating.
* **[TEST] Framework-mirror and custom-feature coverage updates**
  * Added/updated tests for tooltip behavior and manual visibility handling.
  * Corrected formatting and expectations around long-press/focus semantics
    action assertions in framework-mirror tests.

* No breaking API changes in this release.

## 4.0.0

* **[CHANGE] Compact rail fill/highlight now defaults to Flutter-style
  icon-scoped rendering**
  * If your app relied on the previous full selected-destination
    fill treatment, set
    `destinationFillRegion: NavigationDestinationRegion.full` explicitly.
* **[CHANGE] Custom navigation theme data now uses nullable layout and
  tooltip fields**
  * `CustomNavigationBarThemeData.margin`, `padding`, and
    `tooltipVerticalOffset` are now nullable.
  * `CustomNavigationRailThemeData.margin` and `padding` are now nullable.
  * Migration: if you read these values directly, handle `null` and resolve
    defaults from the active widget/theme instead of assuming zero/`42`.
* **[FEAT] AdaptiveScaffold adds consolidated adaptive navigation overrides**
  * New `navigationTheme` accepts `AdaptiveScaffoldNavigationThemeData` for
    shared compact/small label behavior via `compactLabelType`, expanded
    rail label behavior via `expandedLabelType`, shared destination
    transition animation, compact rail transition curve/duration, and
    destination fill mode/shape.
  * `expandedLabelType` is scoped to extended rail layouts and defaults to
    `all`, while supporting `none`, `selected`, and `all`.
* **[FEAT] Navigation destination fill/highlight is now configurable across
  custom bars, rails, and AdaptiveScaffold helpers**
  * `CustomNavigationBar`, `CustomNavigationRail`,
    `AdaptiveScaffold.standardBottomNavigationBar`, and
    `AdaptiveScaffold.standardNavigationRail` support
    `destinationFillRegion` and `destinationFillShape`.
  * Supported fill modes are `none`, `icon`, `content`, `label`, and `full`.
  * Fill/highlight rendering now follows the resolved navigation indicator
    color and shape, and `AdaptiveScaffold.navigationTheme` can apply these
    settings across layouts.
* **[FEAT] Destination hover region is now configurable independently**
  * Added `destinationHoverRegion` alongside `destinationFillRegion` on
    `CustomNavigationBar`, `CustomNavigationRail`,
    `AdaptiveScaffold.standardBottomNavigationBar`,
    `AdaptiveScaffold.standardNavigationRail`, and
    `AdaptiveScaffoldNavigationThemeData`.
  * Hover mode defaults to the fill mode when omitted, preserving existing
    behavior.
* **[CHANGE] Destination region naming was aligned for shared fill/hover usage**
  * Renamed `destinationFillMode` to `destinationFillRegion`.
  * Renamed `destinationHoverMode` to `destinationHoverRegion`.
  * This rename is part of unreleased 4.0.0 work and is not treated as a
    breaking release migration.
  * Renamed `NavigationDestinationFillMode` to
    `NavigationDestinationRegion`.
  * Updated docs/examples to use the new enum name.
* **[FEAT] Navigation destination animation and composition APIs were added**
  * `CustomNavigationDestination` now supports:
    `hideLabel`, `transitionAnimation`, `transitionCurve`,
    `transitionDuration`, `iconBuilder`, `transitionBuilder`,
    `iconIndicatorShape`, and `labelIndicatorShape`.
  * `NavigationDestinationAnimation` adds built-in icon presets:
    `none`, `fadeSwap`, and `scale`.
  * Added public builder typedefs:
    `NavigationDestinationIconBuilder` and
    `NavigationDestinationTransitionBuilder`.
  * `CustomNavigationRail` now supports `iconTransitionAnimation`,
    `iconTransitionCurve`, `iconTransitionDuration`, and
    `destinationTransitionBuilder`.
* **[FEAT] Package root exports were expanded**
  * `CustomNavigationBar` and `NavigationIndicator` are now exported from the
    package root.
  * `navigation_destination_types.dart` is now exported, exposing
    `NavigationDestinationAnimation`, `NavigationDestinationRegion`, and the
    new destination builder typedefs.
* **[FIX] Tooltips are now truly opt-in on custom destinations**
  * `CustomNavigationDestination.tooltip` no longer falls back to the label
    text when `null`.
* **[FIX] Rail fill/highlight behavior was refined across edge cases**
  * Corrected the default indicator shape used for `full` fill mode.
  * Refined hover/highlight behavior for `label` fill mode and RTL-aware
    layout handling.
  * Refined interaction rect sizing to match the configured region mode.
* **[SYNC] Large Flutter framework parity update for custom navigation widgets**
  * Restores role-based semantics on the custom navigation bar (`tabBar` /
    `tab`).
  * Aligns destination semantics behavior with upstream enabled/button/web
    label handling.
  * Aligns `NavigationIndicator` rendering with upstream `Ink` usage.
  * Aligns default label padding and related presentation details with
    upstream defaults.
  * Adds broad framework-mirror regression coverage for custom navigation bar,
    rail, and theme behavior.
* **[DOC] README migration and customization docs were rewritten**
  * Documented `AdaptiveScaffold.navigationTheme`, the new transition and fill
    APIs, package-root exports, and the explicit migration step for apps that
    want to keep the legacy full-fill rail appearance.

## 3.0.2

* [FIX] `AdaptiveScaffold.standardBottomNavigationBar` now normalizes plain
  `NavigationDestination` values to `CustomNavigationDestination` to prevent
  `_NavigationDestinationInfo` assertion failures in `CustomNavigationBar`.
* Adds a regression test covering plain `NavigationDestination` input in
  `standardBottomNavigationBar`.

## 3.0.1

* [FIX] Attaching an `AdaptiveScaffoldController` without `initialIntent` now
  preserves legacy small-layout behavior until `showBody()` or
  `showSecondaryBody()` is called.
* `AdaptiveScaffoldController` now exposes:
  * optional `initialIntent`

## 3.0.0

* This version leveraged the usage of AI-assisted coding. Please submit bug
  reports for any behavioral regressions or unexpected behavior.
* Adds an optional collapsed-pane controller API to `AdaptiveScaffold` via the `controller` parameter.
* Adds `AdaptiveScaffoldController`, `AdaptiveScaffoldScope`, and `PanelFocus` for controlling collapsed body/secondaryBody visibility.
* `PanelFocus` uses slot-aligned values:
  * `PanelFocus.body`
  * `PanelFocus.secondaryBody`
* `AdaptiveScaffoldController` exposes:
  * `showBody()`
  * `showSecondaryBody()`
* Adds documentation and examples for collapsed body/secondaryBody pane control.

* [FIX] Fixed the shape of the indicators in both the navigation bar and
  navigation rail.

## 2.0.2

* Fixes compatibility with Flutter 3.35.x

## 2.0.1

* Backported memory leak fix (See: <https://github.com/flutter/packages/pull/8546>)

## 2.0.0

* Updated to support Flutter 3.19.0

## 1.0.0

* Forked from flutter_adaptive_scaffold

## 0.3.1

* Use improved MediaQuery methods.

## 0.3.0

* Adds `inDuration`, `outDuration`, `inCurve`, and `outCurve` parameters for
configuring additional `SlotLayoutConfig` animation behavior.
* **BREAKING CHANGES**:
  * Removes `duration` parameter from `SlotLayoutConfig`.

## 0.2.6

* Add new sample for using AdaptiveScaffold with GoRouter.

## 0.2.5

* Fix breakpoint not being active in certain cases like foldables.

## 0.2.4

* Compare breakpoints to each other using operators.

## 0.2.3

* Update the spacing and margins to the latest material m3 specs.
* Add `margin`, `spacing`, `padding`, `recommendedPanes` and `maxPanes` with their Material value to `Breakpoint`.

## 0.2.2

* Fix a bug where landscape would not show body when using `andUp`.

## 0.2.1

* Add `Breakpoint.activeBreakpointOf(context)` to find the currently active breakpoint.
* Don't check for height on Desktop platforms.

## 0.2.0

* Add breakpoints for mediumLarge and extraLarge.
* Add height and orientation based breakpoint checks.
* **BREAKING CHANGES**:
  * Removes `WidthPlatformBreakpoint`
  * Breakpoints can now be constructed directly with `Breakpoint`
  * Checks for `andUp` or `platform` can be done as parameter: `Breakpoint.small(andUp: true, platform: Breakpoint.mobile)`

## 0.1.12

* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.
* Updates minimum supported SDK version to Flutter 3.19/Dart 3.3.
* Expose `labelType` for NavigationRails.
* Add `navigationRailDestinationBuilder` to apply custom Destinations.
* Add `groupAlignment` property to change alignment.
* Set `navRailTheme` when using the Drawer just like the other NavigationRails.

## 0.1.11+1

* Allows custom animation duration for the NavigationRail and
  BottomNavigationBar transitions. [flutter/flutter#112938](https://github.com/flutter/flutter/issues/112938)

## 0.1.11

* Updates minimum supported SDK version to Flutter 3.19/Dart 3.3.
* Migrates deprecated MaterialState and MaterialStateProperty to WidgetState and WidgetStateProperty.

## 0.1.10+2

* Reduce rebuilds when invoking `isActive` method.

## 0.1.10+1

* Removes a broken design document link from the README.

## 0.1.10

* FIX : Assertion added when tried with less than 2 destinations - [flutter/flutter#110902](https://github.com/flutter/flutter/issues/110902)

## 0.1.9

* FIX : Drawer stays open even on destination tap - [flutter/flutter#141938](https://github.com/flutter/flutter/issues/141938)
* Updates minimum supported SDK version to Flutter 3.13/Dart 3.1.

## 0.1.8

* Adds `transitionDuration` parameter for specifying how long the animation should be.

## 0.1.7+2

* Fixes new lint warnings.

## 0.1.7+1

* Adds pub topics to package metadata.

## 0.1.7

* Fix top padding for NavigationBar.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 0.1.6

* Added support for displaying an AppBar on any Breakpoint by introducing appBarBreakpoint

## 0.1.5

* Added support for Right-to-left (RTL) directionality.
* Fixes stale ignore: prefer_const_constructors.
* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.

## 0.1.4

* Use Material 3 NavigationBar instead of BottomNavigationBar

## 0.1.3

* Fixes `groupAlignment` property not available in `standardNavigationRail` - [flutter/flutter#121994](https://github.com/flutter/flutter/issues/121994)

## 0.1.2

* Fixes `NavigationRail` items not considering `NavigationRailTheme` values - [flutter/flutter#121135](https://github.com/flutter/flutter/issues/121135)
* When `NavigationRailTheme` is provided, it will use the theme for values that the user has not given explicit theme-related values for.

## 0.1.1

* Fixes flutter/flutter#121135) `selectedIcon` parameter not displayed even if it is provided.

## 0.1.0+1

* Aligns Dart and Flutter SDK constraints.

## 0.1.0

* Change the `selectedIndex` parameter on `standardNavigationRail` to allow null values to indicate "no destination".
* An explicitly null `currentIndex` parameter passed to `standardBottomNavigationBar` will also default to 0, just like implicitly null missing parameters.

## 0.0.9

* Fix passthrough of `leadingExtendedNavRail`, `leadingUnextendedNavRail` and `trailingNavRail`

## 0.0.8

Make fuchsia a mobile platform.

## 0.0.7

* Patch duplicate key error in SlotLayout.

## 0.0.6

* Change type of `appBar` parameter from `AppBar?` to `PreferredSizeWidget?`

## 0.0.5

* Calls onDestinationChanged callback in bottom nav bar.

## 0.0.4

* Fix static analyzer warnings using `core` lint.

## 0.0.3

* First published version.

## 0.0.2

* Adds some more examples.

## 0.0.1+1

* Updates text theme parameters to avoid deprecation issues.

## 0.0.1

* Initial release
