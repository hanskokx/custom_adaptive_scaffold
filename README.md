<div align="center">

# (Custom) Adaptive Scaffold

`AdaptiveScaffold` reacts to input from users, devices and screen elements and renders your Flutter application according to the [Material 3](https://m3.material.io/foundations/adaptive-design/overview) guidelines.

```bash
flutter pub add custom_adaptive_scaffold
```

<!-- Badges -->

[![style: arcane analysis](https://img.shields.io/badge/style-arcane_analysis-6E35AE)](https://pub.dev/packages/arcane_analysis)
<br />
[![tests](https://github.com/hanskokx/custom_adaptive_scaffold/actions/workflows/tests.yml/badge.svg)](https://github.com/hanskokx/custom_adaptive_scaffold/actions/workflows/tests.yml)
[![example](https://github.com/hanskokx/custom_adaptive_scaffold/actions/workflows/example.yml/badge.svg)](https://github.com/hanskokx/custom_adaptive_scaffold/actions/workflows/example.yml)
[![stars](https://img.shields.io/github/stars/hanskokx/custom_adaptive_scaffold.svg)](https://github.com/hanskokx/custom_adaptive_scaffold/stargazers)
<br/>
[![pub package](https://img.shields.io/pub/v/custom_adaptive_scaffold?logo=dart)](https://pub.dev/packages/custom_adaptive_scaffold)
[![pub score](https://img.shields.io/pub/points/custom_adaptive_scaffold?logo=dart)](https://pub.dev/packages/custom_adaptive_scaffold/score)
[![likes](https://img.shields.io/pub/likes/custom_adaptive_scaffold?logo=dart)](https://pub.dev/packages/custom_adaptive_scaffold/likes)

</div>

<img width="1060" height="852" alt="Example of a display made with AdaptiveScaffold" src="https://raw.githubusercontent.com/hanskokx/custom_adaptive_scaffold/main/example/demo_files/adaptiveScaffold.gif" />

**Important**: This source code is derived from the original code found in `package:flutter_adaptive_scaffold` as well as the Flutter framework, itself.
Modifications have been made to the original source code that provide some additional customizations, such as padding and margins, extended theming controls, and tooltip configuration.

## Table of Contents

- [(Custom) Adaptive Scaffold](#custom-adaptive-scaffold)
  - [Table of Contents](#table-of-contents)
  - [Drop-in Replacement](#drop-in-replacement)
  - [How Is This Different From Flutter?](#how-is-this-different-from-flutter)
    - [Extended theme data](#extended-theme-data)
    - [Richer `NavigationDestination` base class](#richer-navigationdestination-base-class)
    - [New public APIs not present in Flutter](#new-public-apis-not-present-in-flutter)
    - [Extra `NavigationRail` parameters](#extra-navigationrail-parameters)
    - [Collapsed-pane controller](#collapsed-pane-controller)
  - [AdaptiveScaffold](#adaptivescaffold)
    - [Panel Primary/Secondary Behavior](#panel-primarysecondary-behavior)
    - [AdaptiveBody Context](#adaptivebody-context)
    - [Primary/Secondary API Summary](#primarysecondary-api-summary)
    - [Primary/Secondary Example](#primarysecondary-example)
    - [Migration Notes](#migration-notes)
    - [Example Usage](#example-usage)
  - [The Background Widget Suite](#the-background-widget-suite)
    - [Breakpoint](#breakpoint)
    - [AdaptiveLayout](#adaptivelayout)
    - [SlotLayout](#slotlayout)
    - [SlotLayout.from](#slotlayoutfrom)
    - [Example Usage](#example-usage-1)
  - [Migrating from 4.x](#migrating-from-4x)
    - [Full-item fill / highlight (was `destinationFillRegion`)](#full-item-fill--highlight-was-destinationfillregion)
    - [Label type per breakpoint (was `AdaptiveScaffoldNavigationThemeData`)](#label-type-per-breakpoint-was-adaptivescaffoldnavigationthemedata)
    - [Hiding a destination label (was `hideLabel`)](#hiding-a-destination-label-was-hidelabel)
    - [Per-destination indicator shape (was `iconIndicatorShape` / `labelIndicatorShape`)](#per-destination-indicator-shape-was-iconindicatorshape--labelindicatorshape)
    - [Tooltip offset (was `tooltipVerticalOffset`)](#tooltip-offset-was-tooltipverticaloffset)
    - [Destination transition animations (was `NavigationDestinationAnimation`)](#destination-transition-animations-was-navigationdestinationanimation)

## Drop-in Replacement

This package is designed to function as a **drop-in replacement** for the corresponding Flutter framework widgets. Because the package exports widgets
under the same names (`NavigationBar`, `NavigationRail`, `NavigationDestination`, etc.), you must resolve the name conflict with one of three approaches:

**Option 1 — Use the package's re-exported Material** (recommended):

```dart
// Replace `import 'package:flutter/material.dart'; with:
import "package:custom_adaptive_scaffold/material.dart";
import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart';
```

**Option 2 — Hide the Flutter originals**:

```dart
import 'package:flutter/material.dart' hide
    NavigationBar,
    NavigationRail,
    NavigationDestination,
    NavigationRailDestination,
    NavigationIndicator,
    NavigationBarTheme,
    NavigationBarThemeData,
    NavigationRailTheme,
    NavigationRailThemeData;
import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart';
```

**Option 3 — Use the `Custom*` aliases**:

Every package widget that shadows a Flutter name also exports a `Custom*` typedef (e.g. `CustomNavigationBar`, `CustomNavigationRail`, `CustomNavigationDestination`, `CustomNavigationBarThemeData`, `CustomNavigationRailThemeData`, `CustomNavigationIndicator`). Rename your existing usages with the `Custom` prefix and import both packages without hiding:

```dart
import 'package:flutter/material.dart';
import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart';

// Use CustomNavigationBar, CustomNavigationRail, etc.
```

## How Is This Different From Flutter?

This package keeps Flutter's default look and feel but exposes opt-in customization points that the framework does not provide.
When package-specific extension properties are not set, bar/rail behavior follows Flutter framework-mirror defaults.

### Extended theme data

Both `NavigationBarThemeData` and `NavigationRailThemeData` are package-owned classes that implement the Flutter framework interfaces, so they are usable
everywhere Flutter's types are expected. They add:

| Property                         | New vs Flutter | Description                                   |
| -------------------------------- | -------------- | --------------------------------------------- |
| `margin`                         | ✓              | Margin around each navigation item            |
| `padding`                        | ✓              | Padding inside each navigation item           |
| `destinationOverlayColor`        | ✓              | Full-item ink/highlight color by widget state |
| `navigationItemIndicatorShape`   | ✓              | Shape for the full-item ink well              |
| `tooltipOffset`                  | ✓              | X/Y offset for tooltip popovers               |
| `tooltipTrigger`                 | ✓              | Which gesture triggers the tooltip            |
| `tooltipTriggerWhenLabelVisible` | ✓              | Override trigger when label is shown          |
| `tooltipTriggerWhenLabelHidden`  | ✓              | Override trigger when label is hidden         |

`NavigationRailThemeData` additionally provides:

- `showLabelsWhenCollapsed` (show labels while the rail is collapsed and `labelType` is `none`)
- `iconTheme` (state-aware icon theming for rail destinations, including explicit large icon sizing)
  - The maximum supported icon size for the `NavigationRail` is `72.0`.
  - The maximum supported icon size for the `NavigationBar` is `60.0`.

### Richer `NavigationDestination` base class

The package's `NavigationDestination` is a full base class (not just a wrapper) with `margin`, `padding`, `indicatorColor`, `indicatorShape`, and `disabled`.
`CustomNavigationDestination` is a typedef alias for it.

### New public APIs not present in Flutter

| API                                    | Description                             |
| -------------------------------------- | --------------------------------------- |
| `NavigationBarTheme.maybeOf(context)`  | Nullable theme lookup                   |
| `NavigationRailTheme.maybeOf(context)` | Nullable theme lookup                   |
| `SelectableAnimatedBuilder`            | Publicly exported 0→1 animation builder |
| `NavigationDestinationInfo`            | Publicly exported inherited data widget |
| `CustomNavigationIndicator`            | Typedef alias for `NavigationIndicator` |

### Extra `NavigationRail` parameters

| Parameter                 | Description                                             |
| ------------------------- | ------------------------------------------------------- |
| `showLabelsWhenCollapsed` | Show labels while the rail is collapsed                 |
| `leadingAtTop`            | Pin the leading widget to the top of the rail           |
| `trailingAtBottom`        | Pin the trailing widget to the bottom of the rail       |
| `scrollable`              | Scroll destinations when vertical space is insufficient |
| `mainAxisAlignment`       | Override alignment of the destination group             |

### Collapsed-pane controller

`AdaptiveScaffoldController`, `PanelFocus`, `AdaptiveScaffoldScope`, and `AdaptiveBody` provide an opt-in API for controlling which pane is visible on
narrow layouts. See the [Panel Primary/Secondary Behavior](#panel-primarysecondary-behavior) section below for full documentation.

To see examples of using these widgets to make a simple but common adaptive layout:

```bash
cd example/
flutter run
```

## AdaptiveScaffold

`AdaptiveScaffold` implements the basic visual layout structure for Material Design 3 that adapts to a variety of screens. It provides a preset of layout,
including positions and animations, by handling macro changes in navigational elements and bodies based on the current features of the screen, namely screen
width and platform. For example, the navigational elements would be a `BottomNavigationBar` on a small mobile device and a `NavigationRail` on larger
devices. The body is the primary screen that takes up the space left by the navigational elements. The secondaryBody acts as an option to split the space
between two panes for purposes such as having a detail view. There is some automatic functionality with foldables to handle the split between panels
properly. `AdaptiveScaffold` is much simpler to use but is not the best if you would like high customizability. Apps that would like more refined layout and/or
animation should use `AdaptiveLayout`.

### Panel Primary/Secondary Behavior

`AdaptiveScaffold` now supports an optional pane-intent controller for primary/secondary style flows:

- `controller: AdaptiveScaffoldController?`

When a controller is provided, pane visibility on collapsed layouts can be controlled explicitly:

- On the `smallBreakpoint`:
  - `PanelFocus.body` shows the body/list pane.
  - `PanelFocus.secondaryBody` shows the secondary/details pane.
- On `mediumBreakpoint` and larger:
  - Layout remains dual-pane according to existing slot configuration.
  - Controller intent does not force one pane to hide.

Important behavior details:

- This is fully opt-in. If `controller` is not supplied, behavior remains unchanged.
- The collapsed pane switch is only active when both
  `controller != null`, `secondaryBody != null`, and the controller has an explicit pane intent.
- `AdaptiveScaffoldController()` starts with no explicit pane intent, so collapsed layouts preserve legacy dual-pane behavior until `showBody()` or `showSecondaryBody()` is called.
- Pass `initialIntent` to opt into immediate collapsed single-pane behavior:
  - `AdaptiveScaffoldController(initialIntent: PanelFocus.body)`
  - `AdaptiveScaffoldController(initialIntent: PanelFocus.secondaryBody)`
- `AdaptiveScaffold` listens to controller updates and rebuilds automatically.
- `AdaptiveScaffoldScope` is inserted only when a controller is provided.

This design keeps routing concerns outside the package. The package controls pane intent and layout visibility only.

### AdaptiveBody Context

`AdaptiveScaffold` now wraps active body and secondaryBody slot content in `AdaptiveBody`, which exposes whether the current layout is collapsed:

```dart
final bool isCollapsed = AdaptiveBody.of(context)?.viewIsCollapsed ?? false;
```

This allows descendants to adapt UI behavior (for example, showing an inline back affordance only on collapsed layouts) without coupling to route state.

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

### Example Usage

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
      ),
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
        label: "Inbox",
      ),
      NavigationDestination(
        icon: Icon(Icons.article_outlined),
        selectedIcon: Icon(Icons.article),
        label: "Articles",
      ),
      NavigationDestination(
        icon: Icon(Icons.chat_outlined),
        selectedIcon: Icon(Icons.chat),
        label: "Chat",
      ),
      NavigationDestination(
        icon: Icon(Icons.video_call_outlined),
        selectedIcon: Icon(Icons.video_call),
        label: "Video",
      ),
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: "Inbox",
      ),
    ],
    controller: _scaffoldController,
    smallBody: (_) => ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Small-screen controller demo",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Tap to switch from body to secondaryBody on compact layouts.",
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _scaffoldController.showSecondaryBody,
                    child: const Text("Show secondaryBody"),
                  ),
                ],
              ),
            ),
          ),
        ),
        ...children,
      ],
    ),
    body: (_) => GridView.count(crossAxisCount: 2, children: children),
    mediumLargeBody: (_) =>
        GridView.count(crossAxisCount: 3, children: children),
    largeBody: (_) => GridView.count(crossAxisCount: 4, children: children),
    extraLargeBody: (_) =>
        GridView.count(crossAxisCount: 5, children: children),
    smallSecondaryBody: (_) => Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                "secondaryBody",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "This pane is shown on small screens when the controller focus is secondaryBody.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: _scaffoldController.showBody,
                child: const Text("Back to body"),
              ),
            ],
          ),
        ),
      ),
    ),
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

These are the set of widgets that are used on a lower level and offer more customizability at a cost of more lines of code.

### Breakpoint

A `Breakpoint` controls the responsive behavior at different screens and configurations.

You can either use a predefined Material3 breakpoint or create your own.

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

<img src="https://raw.githubusercontent.com/hanskokx/custom_adaptive_scaffold/main/example/demo_files/screenSlots.png" alt="AdaptiveLayout's Assigned Slots Displayed on Screen" />

`AdaptiveLayout` is the top-level widget class that arranges the layout of the slots and their animation, similar to Scaffold. It takes in several LayoutSlots and returns an appropriate layout based on the diagram above. `AdaptiveScaffold` is built upon `AdaptiveLayout` internally but abstracts some of the complexity with presets based on the Material 3 Design specification.

### SlotLayout

`SlotLayout` handles the adaptivity or the changes between widgets at certain `Breakpoints`. It also holds the logic for animating between breakpoints. It takes
SlotLayoutConfigs mapped to Breakpoints in a config and displays a widget based on that information.

### SlotLayout.from

SlotLayout.from creates a SlotLayoutConfig holds the actual widget to be displayed and the entrance animation and exit animation.

### Example Usage

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
        key: const Key("Primary Navigation Medium"),
        builder: (_) => AdaptiveScaffold.standardNavigationRail(
          selectedIndex: selectedNavigation,
          onDestinationSelected: (int newIndex) {
            setState(() {
              selectedNavigation = newIndex;
            });
          },
          leading: const Icon(Icons.menu),
          destinations: destinations
              .map(
                (NavigationDestination destination) =>
                    AdaptiveScaffold.toRailDestination(destination),
              )
              .toList(),
          backgroundColor: navRailTheme.backgroundColor,
          selectedIconTheme: navRailTheme.selectedIconTheme,
          unselectedIconTheme: navRailTheme.unselectedIconTheme,
          selectedLabelTextStyle: navRailTheme.selectedLabelTextStyle,
          unSelectedLabelTextStyle: navRailTheme.unselectedLabelTextStyle,
        ),
      ),
      Breakpoints.mediumLarge: SlotLayout.from(
        key: const Key("Primary Navigation MediumLarge"),
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
                "REPLY",
                style: headerColor,
              ),
              const Icon(Icons.menu_open),
            ],
          ),
          destinations: destinations
              .map(
                (NavigationDestination destination) =>
                    AdaptiveScaffold.toRailDestination(destination),
              )
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
        key: const Key("Primary Navigation Large"),
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
                "REPLY",
                style: headerColor,
              ),
              const Icon(Icons.menu_open),
            ],
          ),
          destinations: destinations
              .map(
                (NavigationDestination destination) =>
                    AdaptiveScaffold.toRailDestination(destination),
              )
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
        key: const Key("Primary Navigation ExtraLarge"),
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
                "REPLY",
                style: headerColor,
              ),
              const Icon(Icons.menu_open),
            ],
          ),
          destinations: destinations
              .map(
                (NavigationDestination destination) =>
                    AdaptiveScaffold.toRailDestination(destination),
              )
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
        key: const Key("Body Small"),
        builder: (_) => ListView.builder(
          itemCount: children.length,
          itemBuilder: (BuildContext context, int index) => children[index],
        ),
      ),
      Breakpoints.medium: SlotLayout.from(
        key: const Key("Body Medium"),
        builder: (_) =>
            GridView.count(crossAxisCount: 2, children: children),
      ),
      Breakpoints.mediumLarge: SlotLayout.from(
        key: const Key("Body MediumLarge"),
        builder: (_) =>
            GridView.count(crossAxisCount: 3, children: children),
      ),
      Breakpoints.large: SlotLayout.from(
        key: const Key("Body Large"),
        builder: (_) =>
            GridView.count(crossAxisCount: 4, children: children),
      ),
      Breakpoints.extraLarge: SlotLayout.from(
        key: const Key("Body ExtraLarge"),
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
        key: const Key("Bottom Navigation Small"),
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
      ),
    },
  ),
);
```

Both of the examples shown here produce the same output:

<img width="1060" height="852" alt="Example of a display made with AdaptiveScaffold" src="https://raw.githubusercontent.com/hanskokx/custom_adaptive_scaffold/main/example/demo_files/adaptiveScaffold.gif" />

## Migrating from 4.x

Feature parity with 4.x is maintained via a redesigned API. The mapping below covers the most common 4.x patterns.

### Full-item fill / highlight (was `destinationFillRegion`)

```dart
// 4.x — full-item row fill:
navigationTheme: AdaptiveScaffoldNavigationThemeData(
  destinationFillRegion: NavigationDestinationRegion.full,
  destinationFillShape: const StadiumBorder(),
),

// Current — via NavigationRailThemeData / NavigationBarThemeData:
NavigationRailThemeData(
  destinationOverlayColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) {
      return colorScheme.secondaryContainer.withValues(alpha: 0.24);
    }
    if (states.contains(WidgetState.hovered)) {
      return colorScheme.onSurface.withValues(alpha: 0.08);
    }
    return null;
  }),
  navigationItemIndicatorShape: const StadiumBorder(),
),
```

Omitting `destinationOverlayColor` (the default) restores icon-only highlighting — equivalent to the old `NavigationDestinationRegion.icon`.

### Label type per breakpoint (was `AdaptiveScaffoldNavigationThemeData`)

```dart
// 4.x:
navigationTheme: AdaptiveScaffoldNavigationThemeData(
  compactLabelType: NavigationRailLabelType.selected,
  expandedLabelType: NavigationRailLabelType.all,
),

// Current — pass labelType directly to NavigationRail,
// or set NavigationRailThemeData.labelType in ThemeData:
NavigationRail(
  labelType: isExtended
      ? NavigationRailLabelType.all
      : NavigationRailLabelType.selected,
  extended: isExtended,
  destinations: /* … */,
)
```

### Hiding a destination label (was `hideLabel`)

```dart
// 4.x:
CustomNavigationDestination(icon: Icon(Icons.inbox), hideLabel: true),

// Current — use labelBehavior on the bar theme to hide all labels:
NavigationBarThemeData(
  labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
),
// Or omit the label entirely and rely on the tooltip for accessibility:
NavigationDestination(icon: Icon(Icons.inbox), tooltip: 'Inbox'),
```

### Per-destination indicator shape (was `iconIndicatorShape` / `labelIndicatorShape`)

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

### Tooltip offset (was `tooltipVerticalOffset`)

```dart
// 4.x (CustomNavigationBarThemeData):
tooltipVerticalOffset: 48.0,

// Current:
NavigationBarThemeData(tooltipOffset: Offset(0, 48)),
```

### Destination transition animations (was `NavigationDestinationAnimation`)

`NavigationDestinationAnimation` (`none`, `fadeSwap`, `scale`) and the related `transitionAnimation`, `transitionCurve`, `transitionDuration`, `iconBuilder`,
and `transitionBuilder` parameters are not present in this version. The selection transition uses the standard Flutter animation. Custom icon
transition logic can be implemented by subclassing `NavigationDestination` and overriding `build`.
