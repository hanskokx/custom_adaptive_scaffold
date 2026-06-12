[![style: arcane analysis](https://img.shields.io/badge/style-arcane_analysis-6E35AE)](https://pub.dev/packages/arcane_analysis)

# (Custom) Adaptive Scaffold

`AdaptiveScaffold` reacts to input from users, devices and screen elements and
renders your Flutter application according to the [Material 3](https://m3.material.io/foundations/adaptive-design/overview) guidelines.

**Important**: This source code is derived from the original code found in `package:flutter_adaptive_scaffold` as well as the Flutter framework, itself. Modifications have been made to the original source code that provide some
additional customizations, such as padding and margins. The package keeps
Flutter-parity defaults where possible and exposes opt-in customization points
for behavior that intentionally diverges.

## Table Of Contents

- [How This Package Differs From Flutter](#how-this-package-differs-from-flutter)
- [AdaptiveScaffold](#adaptivescaffold)
  - [Panel Primary/Secondary Behavior](#panel-primarysecondary-behavior)
  - [AdaptiveBody Context](#adaptivebody-context)
  - [Primary/Secondary API Summary](#primarysecondary-api-summary)
  - [Primary/Secondary Example](#primarysecondary-example)
  - [Migration Notes](#migration-notes)
- [CustomNavigationDestination](#customnavigationdestination)
  - [Per-destination label visibility](#per-destination-label-visibility)
  - [Animated icon transitions](#animated-icon-transitions)
  - [Full icon+label transition composition](#full-iconlabel-transition-composition)
  - [Custom navigation rail transitions](#custom-navigation-rail-transitions)
  - [Destination Fill And Hover Regions](#destination-fill-and-hover-regions)
  - [Add Adaptive Theme Via Theme Extensions](#add-adaptive-theme-via-theme-extensions)
  - [Styling Reference](#styling-reference)
  - [Scoped selection indicator](#scoped-selection-indicator)
  - [Tooltip](#tooltip)
  - [Example Usage](#example-usage)
- [The Background Widget Suite](#the-background-widget-suite)
  - [Breakpoint](#breakpoint)
  - [AdaptiveLayout](#adaptivelayout)
  - [SlotLayout](#slotlayout)
  - [SlotLayout.from](#slotlayoutfrom)
  - [Example Usage](#example-usage-1)

## How This Package Differs From Flutter

This package intentionally diverges from Flutter framework/adaptive defaults in
several places:

- Adaptive layout helpers:
  - Adds `AdaptiveScaffoldController`, `AdaptiveScaffoldScope`, and
    `AdaptiveBody` for explicit collapsed pane intent control.
- Navigation bar destination customization:
  - `CustomNavigationDestination.hideLabel` for per-destination label hiding.
  - `transitionAnimation`, `transitionCurve`, `transitionDuration` for built-in
    icon transition presets.
  - `iconBuilder` for fully custom icon transitions.
  - `transitionBuilder` for full-content icon+label transition composition.
  - `iconIndicatorShape` and `labelIndicatorShape` for scoped indicator bubbles.
- Navigation rail customization:
  - Rail destination icon transitions (`iconTransitionAnimation`, curve,
    duration) and destination-level `destinationTransitionBuilder`.
  - Extended layout controls (`leadingAtTop`, `trailingAtBottom`, `scrollable`,
    `mainAxisAlignment`).
  - Configurable rail destination fill/highlight via
    `destinationFillRegion`, `destinationHoverRegion`,
    and `interactionShape`.
  - `AdaptiveScaffold` exposes the same fill options through
    `navigationTheme: AdaptiveScaffoldThemeData(...)` and
    `ThemeData.extensions`.
- Theme extensions:
  - `CustomNavigationRailThemeData`: `backgroundColor`, `elevation`,
    `shadowColor`, `surfaceTintColor`, `border`, `margin`, `padding`,
    icon/label styles, compact/expanded label behavior,
    `extendedNavigationRailWidth`, and rail-local `indicatorStyle`.
  - `CustomNavigationBarThemeData`: framework-compatible bar fields like
    `height`, `backgroundColor`, `elevation`, `shadowColor`,
    `surfaceTintColor`, `indicatorColor`, `indicatorShape`,
    `labelTextStyle`, `iconTheme`, `labelBehavior`, `overlayColor`, and
    `labelPadding`, plus package-only `border`, `margin`, `padding`,
    `tooltipVerticalOffset`, and bar-local `indicatorStyle`.
- Compatibility bridge behavior:
  - Adaptive destination normalization allows using plain
    `NavigationDestination` inputs in APIs that render custom destinations.
  - `CustomNavigationBarTheme` and `CustomNavigationRailTheme` can be used as
    namespaced wrappers alongside Flutter's framework themes.

To see examples of using these widgets to make a simple but common adaptive
layout:

```bash
cd example/
flutter run --release
```

## AdaptiveScaffold

`AdaptiveScaffold` implements the basic visual layout structure for Material
Design 3 that adapts to a variety of screens. It provides a preset of layout,
including positions and animations, by handling macro changes in navigational
elements and bodies based on the current features of the screen, namely screen
width and platform. For example, the navigational elements would be a
`BottomNavigationBar` on a small mobile device and a `CustomNavigationRail` on larger
devices. The body is the primary screen that takes up the space left by the
navigational elements. The secondaryBody acts as an option to split the space
between two panes for purposes such as having a detail view. There is some
automatic functionality with foldable devices to handle the split between panels
properly. `AdaptiveScaffold` is much simpler to use but is not the best if you
would like high customizability. Apps that would like more refined layout and/or
animation should use `AdaptiveLayout`.

### Panel Primary/Secondary Behavior

`AdaptiveScaffold` now supports an optional pane-intent controller for
primary/secondary style flows:

- `controller: AdaptiveScaffoldController?`

When a controller is provided, pane visibility on collapsed layouts can be
controlled explicitly:

- On the `smallBreakpoint`:
  - `PanelFocus.body` shows the body/list pane.
  - `PanelFocus.secondaryBody` shows the secondary/details pane.
- On `mediumBreakpoint` and larger:
  - Layout remains dual-pane according to existing slot configuration.
  - Controller intent does not force one pane to hide.

Important behavior details:

- This is fully opt-in. If `controller` is not supplied, behavior
  remains unchanged.
- The collapsed pane switch is only active when both
  `controller != null`, `secondaryBody != null`, and the controller has an
  explicit pane intent.
- `AdaptiveScaffoldController()` starts with no explicit pane intent, so
  collapsed layouts preserve legacy dual-pane behavior until
  `showBody()` or `showSecondaryBody()` is called.
- Pass `initialIntent` to opt into immediate collapsed single-pane behavior:
  - `AdaptiveScaffoldController(initialIntent: PanelFocus.body)`
  - `AdaptiveScaffoldController(initialIntent: PanelFocus.secondaryBody)`
- `AdaptiveScaffold` listens to controller updates and rebuilds automatically.
- `AdaptiveScaffoldScope` is inserted only when a controller is provided.

This design keeps routing concerns outside the package. The package controls
pane intent and layout visibility only.

### AdaptiveBody Context

`AdaptiveScaffold` now wraps active body and secondaryBody slot content in
`AdaptiveBody`, which exposes whether the current layout is collapsed:

```dart
final bool isCollapsed = AdaptiveBody.of(context)?.viewIsCollapsed ?? false;
```

This allows descendants to adapt UI behavior (for example, showing an inline
back affordance only on collapsed layouts) without coupling to route state.

### Primary/Secondary API Summary

New exports are available from `package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart`:

- `PanelFocus` enum (`body`, `secondaryBody`)
- `AdaptiveScaffoldController`
  - `showBody()`
  - `showSecondaryBody()`
- `AdaptiveScaffoldScope`
  - `AdaptiveScaffoldScope.of(context)`
  - `AdaptiveScaffoldScope.maybeOf(context)`
- `AdaptiveBody`
  - `AdaptiveBody.of(context)`
  - `viewIsCollapsed`

### Primary/Secondary Example

```dart
class _MailScreenState extends State<MailScreen> {
  final AdaptiveScaffoldController _controller = AdaptiveScaffoldController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      destinations: const <NavigationDestination>[
        NavigationDestination(icon: Icon(Icons.inbox), label: "Inbox"),
        NavigationDestination(icon: Icon(Icons.send), label: "Sent"),
      ],
      controller: _controller,
      smallBody: (context) => MessageList(
        onMessageTap: () => _controller.showSecondaryBody(),
      ),
      body: (context) => MessageList(
        onMessageTap: () => _controller.showSecondaryBody(),
      ),
      smallSecondaryBody: (context) => MessageDetails(
        onBack: _controller.showBody,
      ),
      secondaryBody: (context) => const MessageDetails(),
    );
  }
}
```

### Migration Notes

- Existing users of `AdaptiveScaffold` do not need to change anything.
- To adopt pane intent behavior incrementally:
  1. Add an `AdaptiveScaffoldController`.
  2. Pass it to `AdaptiveScaffold(controller: ...)`.
  3. Toggle intent with `showBody()` and `showSecondaryBody()` from UI events.
  4. Use `AdaptiveBody.of(context)?.viewIsCollapsed` in descendants when
     collapsed-specific behavior is needed.

## CustomNavigationDestination

Use `NavigationDestination` by default for standard Material behavior.
`CustomNavigationDestination` is an advanced option that extends
`NavigationDestination` with additional capabilities for per-destination label
control, animated icon transitions, and fine-grained selection indicator
placement.

### Per-destination label visibility

Set `hideLabel: true` to suppress the label on a single destination without
affecting the bar-level `NavigationDestinationLabelBehavior`:

```dart
const CustomNavigationDestination(
  icon: Icon(Icons.search_outlined),
  label: "Search",  // still used for semantics and tooltip
  hideLabel: true,  // not rendered visually
),
```

### Animated icon transitions

Use the built-in presets for common animations:

```dart
const CustomNavigationDestination(
  icon: Icon(Icons.home_outlined),
  selectedIcon: Icon(Icons.home),
  label: "Home",
  transitionAnimation: NavigationDestinationAnimation.fadeSwap,
  transitionCurve: Curves.easeInOut,
  transitionDuration: Duration(milliseconds: 250),
),
```

Available presets:

- `NavigationDestinationAnimation.none` — instant swap (default)
- `NavigationDestinationAnimation.fadeSwap` — cross-fade between icons
- `NavigationDestinationAnimation.scale` — scale-in / scale-out

For fully custom icon animation, use `iconBuilder`. It receives the raw
`Animation<double>`, an `isSelecting` flag indicating the direction of the
transition, and both pre-themed icon widgets:

```dart
CustomNavigationDestination(
  icon: const Icon(Icons.inbox_outlined),
  selectedIcon: const Icon(Icons.inbox),
  label: "Inbox",
  iconBuilder: (
    BuildContext context,
    Animation<double> animation,
    bool isSelecting,
    Widget unselectedIcon,
    Widget selectedIcon,
  ) {
    // isSelecting is true when transitioning toward selected,
    // false when transitioning toward deselected.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => SlideTransition(
        position: Tween<Offset>(
          begin: isSelecting ? const Offset(0, 1) : const Offset(0, -1),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
      child: animation.isForwardOrCompleted
          ? KeyedSubtree(key: const ValueKey("sel"), child: selectedIcon)
          : KeyedSubtree(key: const ValueKey("unsel"), child: unselectedIcon),
    );
  },
),
```

### Full icon+label transition composition

Use `transitionBuilder` when icon and label should transition together:

```dart
CustomNavigationDestination(
  icon: const Icon(Icons.video_call_outlined),
  selectedIcon: const Icon(Icons.video_call),
  label: "Video",
  transitionBuilder: (
    BuildContext context,
    Animation<double> animation,
    bool isSelecting,
    Widget unselectedIcon,
    Widget selectedIcon,
    Widget unselectedLabel,
    Widget selectedLabel,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FadeTransition(
          opacity: animation,
          child: animation.isForwardOrCompleted ? selectedIcon : unselectedIcon,
        ),
        const SizedBox(height: 4),
        FadeTransition(
          opacity: animation,
          child: animation.isForwardOrCompleted ? selectedLabel : unselectedLabel,
        ),
      ],
    );
  },
),
```

### Custom navigation rail transitions

`CustomNavigationRail` supports destination transition controls similar to
`CustomNavigationDestination`, including a destination-level
`destinationTransitionBuilder` for coordinated icon/label transitions.

### Destination Fill And Hover Regions

By default, `CustomNavigationRail` follows Flutter-style selection rendering,
where the indicator sits behind the icon area.

When you want custom destination fill/highlight scopes, choose a
`destinationFillRegion`:

- `none`
- `icon`
- `content`
- `label`
- `full`

Example using full-widget fill plus an indicator shape:

```dart
CustomNavigationRail(
  selectedIndex: selectedIndex,
  destinationFillRegion: NavigationDestinationRegion.full,
  indicatorShape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  destinations: destinations,
)
```

Color is resolved from theme indicator color (`NavigationRailThemeData.indicatorColor`).

`AdaptiveScaffold.standardNavigationRail` exposes the same options:

```dart
AdaptiveScaffold.standardNavigationRail(
  selectedIndex: selectedIndex,
  destinations: railDestinations,
  destinationFillRegion: NavigationDestinationRegion.full,
  indicatorShape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
)
```

For `AdaptiveScaffold`, configure fill/highlight through
`AdaptiveScaffoldThemeData`:

```dart
AdaptiveScaffold(
  destinations: destinations,
  navigationTheme: const AdaptiveScaffoldThemeData(
    indicatorStyle: NavigationIndicatorThemeData(
      destinationFillRegion: NavigationDestinationRegion.label,
      interactionShape: WidgetStatePropertyAll<ShapeBorder?>(StadiumBorder()),
    ),
  ),
  body: (BuildContext context) => const Placeholder(),
)
```

To control hover/pressed interaction region independently, use
`destinationHoverRegion` (defaults to `destinationFillRegion` when omitted).
Selected-fill and hover/pressed interactions both use `interactionShape`:

```dart
AdaptiveScaffold(
  destinations: destinations,
  navigationTheme: const AdaptiveScaffoldThemeData(
    indicatorStyle: NavigationIndicatorThemeData(
      destinationFillRegion: NavigationDestinationRegion.icon,
      destinationHoverRegion: NavigationDestinationRegion.full,
      interactionShape: WidgetStatePropertyAll<ShapeBorder?>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  ),
  body: (BuildContext context) => const Placeholder(),
)
```

Navigation behavior overrides are also configured through
`AdaptiveScaffoldThemeData`:

```dart
AdaptiveScaffold(
  destinations: destinations,
  navigationTheme: const AdaptiveScaffoldThemeData(
    navigationRailTheme: CustomNavigationRailThemeData(
      compactLabelType: NavigationRailLabelType.selected,
      expandedLabelType: NavigationRailLabelType.all,
      extendedNavigationRailWidth: 224,
    ),
    transitionAnimation: NavigationDestinationAnimation.fadeSwap,
    transitionCurve: Curves.easeOutCubic,
    transitionDuration: Duration(milliseconds: 220),
  ),
  body: (BuildContext context) => const Placeholder(),
)
```

For app-wide defaults, add `AdaptiveScaffoldThemeData` directly to
`ThemeData.extensions`:

```dart
MaterialApp(
  theme: ThemeData(
    extensions: const <ThemeExtension<dynamic>>[
      AdaptiveScaffoldThemeData(
        navigationRailTheme: CustomNavigationRailThemeData(
          compactLabelType: NavigationRailLabelType.selected,
        ),
        indicatorStyle: NavigationIndicatorThemeData(
          destinationFillRegion: NavigationDestinationRegion.content,
          interactionShape:
              WidgetStatePropertyAll<ShapeBorder?>(StadiumBorder()),
        ),
      ),
    ],
  ),
)
```

### Add Adaptive Theme Via Theme Extensions

Use `AdaptiveScaffoldThemeData` in `ThemeData.extensions` when you want app-wide
adaptive navigation defaults without wrapping each subtree in
`AdaptiveScaffoldTheme`.

Minimal setup:

```dart
MaterialApp(
  theme: ThemeData(
    extensions: const <ThemeExtension<dynamic>>[
      AdaptiveScaffoldThemeData(
        navigationRailTheme: CustomNavigationRailThemeData(
          compactLabelType: NavigationRailLabelType.selected,
        ),
      ),
    ],
  ),
)
```

Expanded setup with stateful shape resolution:

```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    extensions: const <ThemeExtension<dynamic>>[
      AdaptiveScaffoldThemeData(
        navigationRailTheme: CustomNavigationRailThemeData(
          compactLabelType: NavigationRailLabelType.selected,
          expandedLabelType: NavigationRailLabelType.all,
          extendedNavigationRailWidth: 224,
        ),
        transitionAnimation: NavigationDestinationAnimation.fadeSwap,
        transitionCurve: Curves.easeOutCubic,
        transitionDuration: Duration(milliseconds: 220),
        indicatorStyle: NavigationIndicatorThemeData(
          destinationFillRegion: NavigationDestinationRegion.content,
          destinationHoverRegion: NavigationDestinationRegion.full,
          interactionShape: WidgetStateProperty<ShapeBorder?>.fromMap(
            <WidgetStatesConstraint, ShapeBorder?>{
              WidgetState.selected: StadiumBorder(),
              WidgetState.hovered: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              WidgetState.any: StadiumBorder(),
            },
          ),
        ),
      ),
    ],
  ),
  home: const MyHomePage(),
)
```

In this setup:

- `selected` controls the destination selected-fill shape.
- `hovered` controls hover/pressed interaction shape.
- `WidgetState.any` provides a default fallback shape.

To style the small-breakpoint bar surface and destination presentation through
the adaptive theme, use `navigationBarTheme`:

```dart
AdaptiveScaffold(
  destinations: destinations,
  navigationTheme: const AdaptiveScaffoldThemeData(
    navigationRailTheme: CustomNavigationRailThemeData(
      border: BorderSide(color: Color(0xFFCCCDD3)),
      indicatorStyle: NavigationIndicatorThemeData(
        destinationFillRegion: NavigationDestinationRegion.content,
      ),
    ),
    navigationBarTheme: CustomNavigationBarThemeData(
      height: 88,
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      border: BorderSide(color: Color(0xFFCCCDD3)),
      margin: EdgeInsets.symmetric(horizontal: 12),
      padding: EdgeInsets.symmetric(horizontal: 8),
      labelPadding: EdgeInsets.only(top: 6),
      tooltipVerticalOffset: 56,
      indicatorStyle: NavigationIndicatorThemeData(
        destinationFillRegion: NavigationDestinationRegion.full,
      ),
    ),
    indicatorStyle: NavigationIndicatorThemeData(
      interactionShape:
          WidgetStatePropertyAll<ShapeBorder?>(StadiumBorder()),
    ),
  ),
  body: (BuildContext context) => const Placeholder(),
)
```

You can also provide app-wide defaults via `ThemeData.extensions`:

```dart
MaterialApp(
  theme: ThemeData(
    extensions: const <ThemeExtension<dynamic>>[
      AdaptiveScaffoldThemeData(
        navigationBarTheme: CustomNavigationBarThemeData(
          height: 84,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      ),
    ],
  ),
)
```

### Styling Reference

Use this table to map each styled part of the library to the theme object that
controls it.

| Library part                            | Theme entry point                                                                   | Common fields                                                                                                                   | Notes                                                                                                                    |
| --------------------------------------- | ----------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| Shared adaptive destination interaction | `AdaptiveScaffoldThemeData.indicatorStyle`                                          | `color`, `shape`, `interactionShape`, `destinationFillRegion`, `destinationHoverRegion`                                         | Applies to both bar and rail unless a component-local `indicatorStyle` overrides it.                                     |
| Small-breakpoint navigation bar surface | `AdaptiveScaffoldThemeData.navigationBarTheme` or `CustomNavigationBarTheme.data`   | `height`, `backgroundColor`, `elevation`, `shadowColor`, `surfaceTintColor`, `border`, `margin`, `padding`                      | Shared fields align with Flutter `NavigationBarThemeData`; `border`, `margin`, and `padding` are package-only additions. |
| Navigation bar selected indicator       | `CustomNavigationBarThemeData`                                                      | `indicatorColor`, `indicatorShape`, `indicatorStyle`                                                                            | Use `indicatorStyle` when you also need custom fill-region or interaction-shape behavior.                                |
| Navigation bar icons and labels         | `CustomNavigationBarThemeData`                                                      | `iconTheme`, `labelTextStyle`, `labelBehavior`, `labelPadding`, `overlayColor`                                                  | These mirror the framework bar theme fields and flow through `ThemeData.navigationBarTheme` fallback.                    |
| Navigation bar tooltips                 | `CustomNavigationBarThemeData`                                                      | `tooltipVerticalOffset`                                                                                                         | Package-only field for adjusting tooltip position on `CustomNavigationBar`.                                              |
| Medium and large rail surface           | `AdaptiveScaffoldThemeData.navigationRailTheme` or `CustomNavigationRailTheme.data` | `backgroundColor`, `elevation`, `shadowColor`, `surfaceTintColor`, `border`, `margin`, `padding`                                | Shared rail fields align with Flutter `NavigationRailThemeData`; `border`, `margin`, and `padding` stay additive.        |
| Rail selected indicator                 | `CustomNavigationRailThemeData`                                                     | `indicatorColor`, `indicatorShape`, `indicatorStyle`, `useIndicator`                                                            | Use local `indicatorStyle` to override the shared adaptive indicator only for rail layouts.                              |
| Rail icons and labels                   | `CustomNavigationRailThemeData`                                                     | `selectedIconTheme`, `unselectedIconTheme`, `selectedLabelTextStyle`, `unselectedLabelTextStyle`, `labelType`, `groupAlignment` | Works for direct `CustomNavigationRail` usage and adaptive rail breakpoints.                                             |
| Adaptive compact rail label behavior    | `CustomNavigationRailThemeData`                                                     | `compactLabelType`                                                                                                              | Controls the compact rail used at the medium breakpoint in `AdaptiveScaffold`.                                           |
| Adaptive expanded rail behavior         | `CustomNavigationRailThemeData`                                                     | `expandedLabelType`, `extendedNavigationRailWidth`                                                                              | Applies to extended rails at medium-large and above in `AdaptiveScaffold`.                                               |
| App-wide adaptive defaults              | `ThemeData.extensions` with `AdaptiveScaffoldThemeData`                             | Any `AdaptiveScaffoldThemeData`, `CustomNavigationBarThemeData`, or `CustomNavigationRailThemeData` field                       | Best for package-wide defaults that should participate in adaptive precedence.                                           |
| Direct widget-scoped package theming    | `CustomNavigationBarTheme` / `CustomNavigationRailTheme`                            | `data: CustomNavigationBarThemeData(...)` / `CustomNavigationRailThemeData(...)`                                                | Useful when styling only a local subtree while still coexisting with Flutter's framework theme wrappers.                 |

For widget-level namespaced theming that still cooperates with Flutter's own
`NavigationBarTheme`, you can also wrap package widgets directly:

```dart
MaterialApp(
  theme: ThemeData(
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Color(0xFFF1F3F4),
    ),
  ),
  home: CustomNavigationBarTheme(
    data: const CustomNavigationBarThemeData(
      margin: EdgeInsets.symmetric(horizontal: 12),
      tooltipVerticalOffset: 56,
    ),
    child: Scaffold(
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: 0,
        destinations: const <Widget>[
          CustomNavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          CustomNavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: "Settings",
          ),
        ],
        onDestinationSelected: (_) {},
      ),
    ),
  ),
)
```

When both Flutter and package theme APIs are imported in the same file,
prefer import aliases for clarity:

```dart
import "package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart" as cas;
import "package:flutter/material.dart" as m3;

final cas.CustomNavigationBarThemeData customBar =
    const cas.CustomNavigationBarThemeData(
  margin: EdgeInsets.symmetric(horizontal: 12),
);

final m3.NavigationBarThemeData frameworkBar =
    customBar.toNavigationBarThemeData();
```

Theme precedence is:

1. `AdaptiveScaffold.navigationTheme`
2. nearest `AdaptiveScaffoldTheme`
3. `ThemeData.extensions`
4. `ThemeData.navigationRailTheme` / `ThemeData.navigationBarTheme`
5. defaults

Notes:

- `transitionAnimation` is shared by both compact rail and small navigation
  bar destination transitions.
- `navigationRailTheme.compactLabelType` configures compact rail labels
  directly, and maps to the corresponding small navigation bar label behavior.
- `navigationRailTheme.expandedLabelType` applies only to expanded rails
  (medium-large and up). Defaults to `NavigationRailLabelType.all` and
  supports `none`, `selected`, and `all`.
- `navigationRailTheme.extendedNavigationRailWidth` controls extended-rail
  width across medium-large and larger breakpoints. When omitted,
  `AdaptiveScaffold` keeps its default width of `192`.
- Local `indicatorStyle` on `navigationBarTheme` and `navigationRailTheme`
  takes precedence over top-level `AdaptiveScaffoldThemeData.indicatorStyle`
  for that component.
- `CustomNavigationBarThemeData` and `CustomNavigationRailThemeData` are
  framework-first theme objects: shared fields align with Flutter's
  `NavigationBarThemeData` and `NavigationRailThemeData`, and package-only
  fields stay additive.
- Both custom theme data classes expose conversion helpers for shared-field
  interop with Flutter themes.

3.x compatibility note:

- Top-level `compactLabelType`, `expandedLabelType`, and
  `extendedNavigationRailWidth` fields on `AdaptiveScaffoldThemeData` remain
  available for migration from 3.x configurations, but are deprecated in favor
  of `navigationRailTheme`.

Compatibility note:

If your app previously depended on full selected-destination fill behavior,
set `destinationFillRegion: NavigationDestinationRegion.full` on
`CustomNavigationRail` (or on `AdaptiveScaffold.standardNavigationRail` when
using the helper).

Behavior notes:

- `NavigationDestinationRegion.full` now expands to the destination lane more
  consistently in rail layouts (including extended rails) while keeping icon
  positioning stable.
- `NavigationDestinationRegion.content` keeps a padded icon interaction/highlight
  rect when labels are hidden.
- `NavigationDestinationRegion.label` does not fall back to an icon-region pill
  when labels are hidden; in hidden-label states there is no label-region pill.

### Scoped selection indicator

By default the selection indicator fills the entire destination item.
Use `iconIndicatorShape` or `labelIndicatorShape` to scope it to just the icon
or just the label. Setting either field suppresses the full-item indicator.

```dart
// Indicator around icon only:
const CustomNavigationDestination(
  icon: Icon(Icons.person_outline),
  label: "Profile",
  iconIndicatorShape: CircleBorder(),
),

// Indicator around label only:
const CustomNavigationDestination(
  icon: Icon(Icons.notifications_outlined),
  label: "Alerts",
  labelIndicatorShape: StadiumBorder(),
),

// Separate bubbles for icon and label:
const CustomNavigationDestination(
  icon: Icon(Icons.chat_outlined),
  label: "Chat",
  iconIndicatorShape: CircleBorder(),
  labelIndicatorShape: StadiumBorder(),
),
```

### Tooltip

`tooltip` is `null` by default and truly suppresses the tooltip when omitted.
Pass a non-null string to show a custom tooltip on long press:

```dart
const CustomNavigationDestination(
  icon: Icon(Icons.settings_outlined),
  label: "Settings",
  tooltip: "App settings",  // shown on long press
),

const CustomNavigationDestination(
  icon: Icon(Icons.search_outlined),
  label: "Search",
  // tooltip omitted → no tooltip shown
),
```

### Example Usage

<?code-excerpt "example/lib/adaptive_scaffold_demo.dart (Example)"?>

```dart
@override
Widget build(BuildContext context) {
  // Define the children to display within the body at different breakpoints.
  final List<Widget> children = <Widget>[
    for (int i = 0; i < 10; i++)
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: const Color.fromARGB(255, 255, 201, 197),
          height: 400,
        ),
      )
  ];
  return AdaptiveScaffold(
    // An option to override the default transition duration.
    transitionDuration: Duration(milliseconds: _transitionDuration),
    // An option to override the default breakpoints used for small, medium,
    // mediumLarge, large, and extraLarge.
    smallBreakpoint: const Breakpoint(endWidth: 700),
    mediumBreakpoint: const Breakpoint(beginWidth: 700, endWidth: 1000),
    mediumLargeBreakpoint: const Breakpoint(beginWidth: 1000, endWidth: 1200),
    largeBreakpoint: const Breakpoint(beginWidth: 1200, endWidth: 1600),
    extraLargeBreakpoint: const Breakpoint(beginWidth: 1600),
    useDrawer: false,
    selectedIndex: _selectedTab,
    onSelectedIndexChange: (int index) {
      setState(() {
        _selectedTab = index;
      });
    },
    destinations: const <NavigationDestination>[
      NavigationDestination(
        icon: Icon(Icons.inbox_outlined),
        selectedIcon: Icon(Icons.inbox),
        label: 'Inbox',
      ),
      NavigationDestination(
        icon: Icon(Icons.article_outlined),
        selectedIcon: Icon(Icons.article),
        label: 'Articles',
      ),
      NavigationDestination(
        icon: Icon(Icons.chat_outlined),
        selectedIcon: Icon(Icons.chat),
        label: 'Chat',
      ),
      NavigationDestination(
        icon: Icon(Icons.video_call_outlined),
        selectedIcon: Icon(Icons.video_call),
        label: 'Video',
      ),
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Inbox',
      ),
    ],
    smallBody: (_) => ListView.builder(
      itemCount: children.length,
      itemBuilder: (_, int idx) => children[idx],
    ),
    body: (_) => GridView.count(crossAxisCount: 2, children: children),
    mediumLargeBody: (_) =>
        GridView.count(crossAxisCount: 3, children: children),
    largeBody: (_) => GridView.count(crossAxisCount: 4, children: children),
    extraLargeBody: (_) =>
        GridView.count(crossAxisCount: 5, children: children),
    // Define a default secondaryBody.
    // Override the default secondaryBody during the smallBreakpoint to be
    // empty. Must use AdaptiveScaffold.emptyBuilder to ensure it is properly
    // overridden.
    smallSecondaryBody: AdaptiveScaffold.emptyBuilder,
    secondaryBody: (_) => Container(
      color: const Color.fromARGB(255, 234, 158, 192),
    ),
    mediumLargeSecondaryBody: (_) => Container(
      color: const Color.fromARGB(255, 234, 158, 192),
    ),
    largeSecondaryBody: (_) => Container(
      color: const Color.fromARGB(255, 234, 158, 192),
    ),
    extraLargeSecondaryBody: (_) => Container(
      color: const Color.fromARGB(255, 234, 158, 192),
    ),
  );
}
```

## The Background Widget Suite

These are the set of widgets that are used on a lower level and offer more
customizability at a cost of more lines of code.

### Breakpoint

A `Breakpoint` controls the responsive behavior at different screens and configurations.

You can either use a predefined Material3 breakpoint or create your own.

<?code-excerpt "lib/src/breakpoints.dart (Breakpoints)"?>

```dart
/// Returns a const [Breakpoint] with the given constraints.
const Breakpoint({
  this.beginWidth,
  this.endWidth,
  this.beginHeight,
  this.endHeight,
  this.andUp = false,
  this.platform,
  this.spacing = kMaterialMediumAndUpSpacing,
  this.margin = kMaterialMediumAndUpMargin,
  this.padding = kMaterialPadding,
  this.recommendedPanes = 1,
  this.maxPanes = 1,
});

/// Returns a [Breakpoint] that can be used as a fallthrough in the
/// case that no other breakpoint is active.
const Breakpoint.standard({this.platform})
    : beginWidth = -1,
      endWidth = null,
      beginHeight = null,
      endHeight = null,
      spacing = kMaterialMediumAndUpSpacing,
      margin = kMaterialMediumAndUpMargin,
      padding = kMaterialPadding,
      recommendedPanes = 1,
      maxPanes = 1,
      andUp = true;

/// Returns a [Breakpoint] with the given constraints for a small screen.
const Breakpoint.small({this.andUp = false, this.platform})
    : beginWidth = 0,
      endWidth = 600,
      beginHeight = null,
      endHeight = 480,
      spacing = kMaterialCompactSpacing,
      margin = kMaterialCompactMargin,
      padding = kMaterialPadding,
      recommendedPanes = 1,
      maxPanes = 1;

/// Returns a [Breakpoint] with the given constraints for a medium screen.
const Breakpoint.medium({this.andUp = false, this.platform})
    : beginWidth = 600,
      endWidth = 840,
      beginHeight = 480,
      endHeight = 900,
      spacing = kMaterialMediumAndUpSpacing,
      margin = kMaterialMediumAndUpMargin,
      padding = kMaterialPadding * 2,
      recommendedPanes = 1,
      maxPanes = 2;

/// Returns a [Breakpoint] with the given constraints for a mediumLarge screen.
const Breakpoint.mediumLarge({this.andUp = false, this.platform})
    : beginWidth = 840,
      endWidth = 1200,
      beginHeight = 900,
      endHeight = null,
      spacing = kMaterialMediumAndUpSpacing,
      margin = kMaterialMediumAndUpMargin,
      padding = kMaterialPadding * 3,
      recommendedPanes = 2,
      maxPanes = 2;

/// Returns a [Breakpoint] with the given constraints for a large screen.
const Breakpoint.large({this.andUp = false, this.platform})
    : beginWidth = 1200,
      endWidth = 1600,
      beginHeight = 900,
      endHeight = null,
      spacing = kMaterialMediumAndUpSpacing,
      margin = kMaterialMediumAndUpMargin,
      padding = kMaterialPadding * 4,
      recommendedPanes = 2,
      maxPanes = 2;

/// Returns a [Breakpoint] with the given constraints for an extraLarge screen.
const Breakpoint.extraLarge({this.andUp = false, this.platform})
    : beginWidth = 1600,
      endWidth = null,
      beginHeight = 900,
      endHeight = null,
      spacing = kMaterialMediumAndUpSpacing,
      margin = kMaterialMediumAndUpMargin,
      padding = kMaterialPadding * 5,
      recommendedPanes = 2,
      maxPanes = 3;
```

It is possible to compare Breakpoints:

<?code-excerpt "lib/src/breakpoints.dart (Breakpoint operators)"?>

```dart
/// Returns true if this [Breakpoint] is greater than the given [Breakpoint].
bool operator >(Breakpoint breakpoint)
// ···
/// Returns true if this [Breakpoint] is less than the given [Breakpoint].
bool operator <(Breakpoint breakpoint)
// ···
/// Returns true if this [Breakpoint] is greater than or equal to the
/// given [Breakpoint].
bool operator >=(Breakpoint breakpoint)
// ···
/// Returns true if this [Breakpoint] is less than or equal to the
/// given [Breakpoint].
bool operator <=(Breakpoint breakpoint)
// ···
/// Returns true if this [Breakpoint] is between the given [Breakpoint]s.
bool between(Breakpoint lower, Breakpoint upper)
```

### AdaptiveLayout

!["AdaptiveLayout's Assigned Slots Displayed on Screen"](example/demo_files/screenSlots.png)
`AdaptiveLayout` is the top-level widget class that arranges the layout of the
slots and their animation, similar to Scaffold. It takes in several LayoutSlots
and returns an appropriate layout based on the diagram above. `AdaptiveScaffold`
is built upon `AdaptiveLayout` internally but abstracts some of the complexity
with presets based on the Material 3 Design specification.

### SlotLayout

`SlotLayout` handles the adaptivity or the changes between widgets at certain
`Breakpoints`. It also holds the logic for animating between breakpoints. It takes
SlotLayoutConfigs mapped to Breakpoints in a config and displays a widget based
on that information.

### SlotLayout.from

SlotLayout.from creates a SlotLayoutConfig holds the actual widget to be
displayed and the entrance animation and exit animation.

### Example Usage

<?code-excerpt "example/lib/adaptive_layout_demo.dart (Example)"?>

```dart
// AdaptiveLayout has a number of slots that take SlotLayouts and these
// SlotLayouts' configs take maps of Breakpoints to SlotLayoutConfigs.
return AdaptiveLayout(
  // An option to override the default transition duration.
  transitionDuration: Duration(milliseconds: _transitionDuration),
  // Primary navigation config has nothing from 0 to 600 dp screen width,
  // then an unextended NavigationRail with no labels and just icons then an
  // extended NavigationRail with both icons and labels.
  primaryNavigation: SlotLayout(
    config: <Breakpoint, SlotLayoutConfig>{
      Breakpoints.medium: SlotLayout.from(
        inAnimation: AdaptiveScaffold.leftOutIn,
        key: const Key('Primary Navigation Medium'),
        builder: (_) => AdaptiveScaffold.standardNavigationRail(
          selectedIndex: selectedNavigation,
          onDestinationSelected: (int newIndex) {
            setState(() {
              selectedNavigation = newIndex;
            });
          },
          leading: const Icon(Icons.menu),
          destinations: destinations
              .map((NavigationDestination destination) =>
                  AdaptiveScaffold.toRailDestination(destination))
              .toList(),
          backgroundColor: navRailTheme.backgroundColor,
          selectedIconTheme: navRailTheme.selectedIconTheme,
          unselectedIconTheme: navRailTheme.unselectedIconTheme,
          selectedLabelTextStyle: navRailTheme.selectedLabelTextStyle,
          unSelectedLabelTextStyle: navRailTheme.unselectedLabelTextStyle,
        ),
      ),
      Breakpoints.mediumLarge: SlotLayout.from(
        key: const Key('Primary Navigation MediumLarge'),
        inAnimation: AdaptiveScaffold.leftOutIn,
        builder: (_) => AdaptiveScaffold.standardNavigationRail(
          selectedIndex: selectedNavigation,
          onDestinationSelected: (int newIndex) {
            setState(() {
              selectedNavigation = newIndex;
            });
          },
          extended: true,
          leading: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                'REPLY',
                style: headerColor,
              ),
              const Icon(Icons.menu_open)
            ],
          ),
          destinations: destinations
              .map((NavigationDestination destination) =>
                  AdaptiveScaffold.toRailDestination(destination))
              .toList(),
          trailing: trailingNavRail,
          backgroundColor: navRailTheme.backgroundColor,
          selectedIconTheme: navRailTheme.selectedIconTheme,
          unselectedIconTheme: navRailTheme.unselectedIconTheme,
          selectedLabelTextStyle: navRailTheme.selectedLabelTextStyle,
          unSelectedLabelTextStyle: navRailTheme.unselectedLabelTextStyle,
        ),
      ),
      Breakpoints.large: SlotLayout.from(
        key: const Key('Primary Navigation Large'),
        inAnimation: AdaptiveScaffold.leftOutIn,
        builder: (_) => AdaptiveScaffold.standardNavigationRail(
          selectedIndex: selectedNavigation,
          onDestinationSelected: (int newIndex) {
            setState(() {
              selectedNavigation = newIndex;
            });
          },
          extended: true,
          leading: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                'REPLY',
                style: headerColor,
              ),
              const Icon(Icons.menu_open)
            ],
          ),
          destinations: destinations
              .map((NavigationDestination destination) =>
                  AdaptiveScaffold.toRailDestination(destination))
              .toList(),
          trailing: trailingNavRail,
          backgroundColor: navRailTheme.backgroundColor,
          selectedIconTheme: navRailTheme.selectedIconTheme,
          unselectedIconTheme: navRailTheme.unselectedIconTheme,
          selectedLabelTextStyle: navRailTheme.selectedLabelTextStyle,
          unSelectedLabelTextStyle: navRailTheme.unselectedLabelTextStyle,
        ),
      ),
      Breakpoints.extraLarge: SlotLayout.from(
        key: const Key('Primary Navigation ExtraLarge'),
        inAnimation: AdaptiveScaffold.leftOutIn,
        builder: (_) => AdaptiveScaffold.standardNavigationRail(
          selectedIndex: selectedNavigation,
          onDestinationSelected: (int newIndex) {
            setState(() {
              selectedNavigation = newIndex;
            });
          },
          extended: true,
          leading: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                'REPLY',
                style: headerColor,
              ),
              const Icon(Icons.menu_open)
            ],
          ),
          destinations: destinations
              .map((NavigationDestination destination) =>
                  AdaptiveScaffold.toRailDestination(destination))
              .toList(),
          trailing: trailingNavRail,
          backgroundColor: navRailTheme.backgroundColor,
          selectedIconTheme: navRailTheme.selectedIconTheme,
          unselectedIconTheme: navRailTheme.unselectedIconTheme,
          selectedLabelTextStyle: navRailTheme.selectedLabelTextStyle,
          unSelectedLabelTextStyle: navRailTheme.unselectedLabelTextStyle,
        ),
      ),
    },
  ),
  // Body switches between a ListView and a GridView from small to medium
  // breakpoints and onwards.
  body: SlotLayout(
    config: <Breakpoint, SlotLayoutConfig>{
      Breakpoints.small: SlotLayout.from(
        key: const Key('Body Small'),
        builder: (_) => ListView.builder(
          itemCount: children.length,
          itemBuilder: (BuildContext context, int index) => children[index],
        ),
      ),
      Breakpoints.medium: SlotLayout.from(
        key: const Key('Body Medium'),
        builder: (_) =>
            GridView.count(crossAxisCount: 2, children: children),
      ),
      Breakpoints.mediumLarge: SlotLayout.from(
        key: const Key('Body MediumLarge'),
        builder: (_) =>
            GridView.count(crossAxisCount: 3, children: children),
      ),
      Breakpoints.large: SlotLayout.from(
        key: const Key('Body Large'),
        builder: (_) =>
            GridView.count(crossAxisCount: 4, children: children),
      ),
      Breakpoints.extraLarge: SlotLayout.from(
        key: const Key('Body ExtraLarge'),
        builder: (_) =>
            GridView.count(crossAxisCount: 5, children: children),
      ),
    },
  ),
  // BottomNavigation is only active in small views defined as under 600 dp
  // width.
  bottomNavigation: SlotLayout(
    config: <Breakpoint, SlotLayoutConfig>{
      Breakpoints.small: SlotLayout.from(
        key: const Key('Bottom Navigation Small'),
        inAnimation: AdaptiveScaffold.bottomToTop,
        outAnimation: AdaptiveScaffold.topToBottom,
        builder: (_) => AdaptiveScaffold.standardBottomNavigationBar(
          destinations: destinations,
          currentIndex: selectedNavigation,
          onDestinationSelected: (int newIndex) {
            setState(() {
              selectedNavigation = newIndex;
            });
          },
        ),
      )
    },
  ),
);
```

Both of the examples shown here produce the same output:
!["Example of a display made with AdaptiveScaffold"](example/demo_files/adaptiveScaffold.gif)
