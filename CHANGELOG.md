## 4.0.0

* **[FEAT] Configurable rail destination fill modes** —
  `CustomNavigationRail` now supports:
  * `destinationFillMode` (`NavigationDestinationFillMode`, default
    `icon`) to select fill/highlight scope:
    `none`, `icon`, `content`, `label`, `full`.
  * `destinationFillShape` (`ShapeBorder?`) to customize fill/highlight shape.
  * Fill color now resolves from theme indicator color
    (`NavigationRailThemeData.indicatorColor`).
* **[FEAT] AdaptiveScaffold rail helper support** —
  `AdaptiveScaffold.standardNavigationRail` now forwards:
  * `destinationFillMode`
  * `destinationFillShape`
* **[FEAT] AdaptiveScaffold navigation theme support** —
  `AdaptiveScaffoldNavigationThemeData` now supports:
  * `destinationFillMode`
  * `destinationFillShape`
  and `AdaptiveScaffold` applies these values to navigation rail rendering.
* **[MIGRATION] Re-enable legacy full-fill appearance explicitly** —
  If your app previously relied on full selected-destination fill, set
  `destinationFillMode: NavigationDestinationFillMode.full` on
  `CustomNavigationRail` (or via `AdaptiveScaffold.standardNavigationRail`)
  during upgrade.
* **[DOC] README updates** — documented the new opt-in API and clarified that
  Flutter-parity selection behavior remains the default.

* **[FEAT] Per-destination label visibility** — `CustomNavigationDestination`
  now accepts `hideLabel: true` to suppress the label on individual destinations
  independently of the bar-level `NavigationDestinationLabelBehavior`.
* **[FEAT] Destination-level full-content transitions** —
  `CustomNavigationDestination.transitionBuilder` can now animate icon and label
  state together using themed `unselected/selected` icon and label widgets.
* **[FEAT] Rail destination transitions** — `CustomNavigationRail` now supports:
  * `iconTransitionAnimation`
  * `iconTransitionCurve`
  * `iconTransitionDuration`
  * `destinationTransitionBuilder`
  for configurable destination transition behavior on rail layouts.
* **[FEAT] Animated icon transitions** — `CustomNavigationDestination` accepts:
  * `transitionAnimation` (`NavigationDestinationAnimation`) — built-in presets:
    `none` (default, existing snap behavior), `fadeSwap` (cross-fade), `scale`
    (scale-in / scale-out).
  * `transitionCurve` (`Curve`, default `Curves.easeInOut`) — curve applied to
    the transition.
  * `transitionDuration` (`Duration?`) — overrides the bar's animation duration.
  * `iconBuilder` (`NavigationDestinationIconBuilder?`) — fully custom builder
    receiving the `Animation<double>`, a `bool isSelecting` direction flag
    (`true` while transitioning toward selected, `false` toward deselected),
    and both themed icon widgets; takes priority over `transitionAnimation`
    when set.
  * New typedef `NavigationDestinationIconBuilder` and enum
    `NavigationDestinationAnimation` exported from the package root.
* **[FIX] Tooltip now truly optional** — `CustomNavigationDestination.tooltip`
  being `null` no longer falls back to the label text. Pass a non-null string
  to show a tooltip; omit it (or pass `null`) for no tooltip at all.
* **[SYNC] Upstream framework parity updates**:
  * Restores role-based semantics on the custom navigation bar (`tabBar` / `tab`).
  * Aligns destination semantics behavior with upstream (enabled/button semantics,
    web label semantics handling).
  * Aligns `NavigationIndicator` rendering with upstream `Ink` usage.
  * Aligns default label padding behavior with upstream defaults.
* **[FEAT] Scoped selection indicator** — `CustomNavigationDestination` accepts:
  * `iconIndicatorShape` (`ShapeBorder?`) — draws the selection indicator around
    the icon widget only; suppresses the default full-item indicator.
  * `labelIndicatorShape` (`ShapeBorder?`) — draws the selection indicator around
    the label widget only; suppresses the default full-item indicator.
  * Both fields can be set simultaneously for independent icon + label bubbles.
  * When both are null the existing full-item indicator behavior is preserved.

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
