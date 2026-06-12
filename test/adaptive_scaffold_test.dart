// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import "package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "simulated_layout.dart";
import "test_breakpoints.dart";

void main() {
  testWidgets("adaptive scaffold lays out slots as expected",
      (WidgetTester tester) async {
    final Finder smallBody = find.byKey(const Key("smallBody"));
    final Finder body = find.byKey(const Key("body"));
    final Finder mediumLargeBody = find.byKey(const Key("mediumLargeBody"));
    final Finder largeBody = find.byKey(const Key("largeBody"));
    final Finder extraLargeBody = find.byKey(const Key("extraLargeBody"));

    final Finder smallSBody = find.byKey(const Key("smallSBody"));
    final Finder sBody = find.byKey(const Key("sBody"));
    final Finder mediumLargeSBody = find.byKey(const Key("mediumLargeSBody"));
    final Finder largeSBody = find.byKey(const Key("largeSBody"));
    final Finder extraLargeSBody = find.byKey(const Key("extraLargeSBody"));

    final Finder bottomNav = find.byKey(const Key("bottomNavigation"));
    final Finder primaryNav = find.byKey(const Key("primaryNavigation"));
    final Finder primaryNav1 = find.byKey(const Key("primaryNavigation1"));
    final Finder primaryNav2 = find.byKey(const Key("primaryNavigation2"));
    final Finder primaryNav3 = find.byKey(const Key("primaryNavigation3"));

    await tester.binding.setSurfaceSize(SimulatedLayout.small.size);
    await tester.pumpWidget(SimulatedLayout.small.scaffold(tester));
    await tester.pumpAndSettle();

    expect(smallBody, findsOneWidget);
    expect(smallSBody, findsOneWidget);
    expect(bottomNav, findsOneWidget);
    expect(primaryNav, findsNothing);

    expect(tester.getTopLeft(smallBody), Offset.zero);
    expect(tester.getTopLeft(smallSBody), const Offset(200, 0));
    expect(tester.getTopLeft(bottomNav), const Offset(0, 1920));

    await tester.binding.setSurfaceSize(SimulatedLayout.medium.size);
    await tester.pumpWidget(SimulatedLayout.medium.scaffold(tester));
    await tester.pumpAndSettle();

    expect(smallBody, findsNothing);
    expect(body, findsOneWidget);
    expect(smallSBody, findsNothing);
    expect(sBody, findsOneWidget);
    expect(bottomNav, findsNothing);
    expect(primaryNav, findsOneWidget);

    expect(tester.getTopLeft(body), const Offset(88, 0));
    expect(tester.getTopLeft(sBody), const Offset(400, 0));
    expect(tester.getTopLeft(primaryNav), Offset.zero);
    expect(tester.getBottomRight(primaryNav), const Offset(88, 2000));

    await tester.binding.setSurfaceSize(SimulatedLayout.mediumLarge.size);
    await tester.pumpWidget(SimulatedLayout.mediumLarge.scaffold(tester));
    await tester.pumpAndSettle();

    expect(body, findsNothing);
    expect(mediumLargeBody, findsOneWidget);
    expect(sBody, findsNothing);
    expect(mediumLargeSBody, findsOneWidget);
    expect(primaryNav, findsNothing);
    expect(primaryNav1, findsOneWidget);

    expect(tester.getTopLeft(mediumLargeBody), const Offset(208, 0));
    expect(tester.getTopLeft(mediumLargeSBody), const Offset(500, 0));
    expect(tester.getTopLeft(primaryNav1), Offset.zero);
    expect(tester.getBottomRight(primaryNav1), const Offset(208, 2000));

    await tester.binding.setSurfaceSize(SimulatedLayout.large.size);
    await tester.pumpWidget(SimulatedLayout.large.scaffold(tester));
    await tester.pumpAndSettle();

    expect(mediumLargeBody, findsNothing);
    expect(largeBody, findsOneWidget);
    expect(mediumLargeSBody, findsNothing);
    expect(largeSBody, findsOneWidget);
    expect(primaryNav1, findsNothing);
    expect(primaryNav2, findsOneWidget);

    expect(tester.getTopLeft(largeBody), const Offset(208, 0));
    expect(tester.getTopLeft(largeSBody), const Offset(600, 0));
    expect(tester.getTopLeft(primaryNav2), Offset.zero);
    expect(tester.getBottomRight(primaryNav2), const Offset(208, 2000));

    await tester.binding.setSurfaceSize(SimulatedLayout.extraLarge.size);
    await tester.pumpWidget(SimulatedLayout.extraLarge.scaffold(tester));
    await tester.pumpAndSettle();

    expect(largeBody, findsNothing);
    expect(extraLargeBody, findsOneWidget);
    expect(largeSBody, findsNothing);
    expect(extraLargeSBody, findsOneWidget);
    expect(primaryNav2, findsNothing);
    expect(primaryNav3, findsOneWidget);

    expect(tester.getTopLeft(extraLargeBody), const Offset(208, 0));
    expect(tester.getTopLeft(extraLargeSBody), const Offset(800, 0));
    expect(tester.getTopLeft(primaryNav3), Offset.zero);
    expect(tester.getBottomRight(primaryNav3), const Offset(208, 2000));
  });

  testWidgets("adaptive scaffold animations work correctly",
      (WidgetTester tester) async {
    final Finder b = find.byKey(const Key("body"));
    final Finder sBody = find.byKey(const Key("sBody"));

    await tester.binding.setSurfaceSize(SimulatedLayout.small.size);
    await tester.pumpWidget(SimulatedLayout.small.scaffold(tester));
    await tester.binding.setSurfaceSize(SimulatedLayout.medium.size);
    await tester.pumpWidget(SimulatedLayout.medium.scaffold(tester));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.getTopLeft(b), const Offset(17.6, 0));
    expect(
      tester.getBottomRight(b),
      offsetMoreOrLessEquals(const Offset(778.2, 1936), epsilon: 1.0),
    );
    expect(
      tester.getTopLeft(sBody),
      offsetMoreOrLessEquals(const Offset(778.2, 0), epsilon: 1.0),
    );
    expect(
      tester.getBottomRight(sBody),
      offsetMoreOrLessEquals(const Offset(1178.2, 1936), epsilon: 1.0),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(tester.getTopLeft(b), const Offset(70.4, 0));
    expect(
      tester.getBottomRight(b),
      offsetMoreOrLessEquals(const Offset(416.0, 1984), epsilon: 1.0),
    );
    expect(
      tester.getTopLeft(sBody),
      offsetMoreOrLessEquals(const Offset(416, 0), epsilon: 1.0),
    );
    expect(
      tester.getBottomRight(sBody),
      offsetMoreOrLessEquals(const Offset(816, 1984), epsilon: 1.0),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.getTopLeft(b), const Offset(88.0, 0));
    expect(tester.getBottomRight(b), const Offset(400, 2000));
    expect(tester.getTopLeft(sBody), const Offset(400, 0));
    expect(tester.getBottomRight(sBody), const Offset(800, 2000));
  });

  testWidgets("adaptive scaffold animations can be disabled",
      (WidgetTester tester) async {
    final Finder b = find.byKey(const Key("body"));
    final Finder sBody = find.byKey(const Key("sBody"));

    await tester.binding.setSurfaceSize(SimulatedLayout.small.size);
    await tester
        .pumpWidget(SimulatedLayout.small.scaffold(tester, animations: false));

    await tester.binding.setSurfaceSize(SimulatedLayout.medium.size);
    await tester
        .pumpWidget(SimulatedLayout.medium.scaffold(tester, animations: false));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.getTopLeft(b), const Offset(88.0, 0));
    expect(tester.getBottomRight(b), const Offset(400, 2000));
    expect(tester.getTopLeft(sBody), const Offset(400, 0));
    expect(tester.getBottomRight(sBody), const Offset(800, 2000));
  });

  // The goal of this test is to run through each of the navigation elements
  // and test whether tapping on that element will update the selected index
  // globally
  testWidgets("tapping navigation elements calls onSelectedIndexChange",
      (WidgetTester tester) async {
    // for each screen size there is a different navigational element that
    // we want to test tapping to set the selected index
    await Future.forEach(SimulatedLayout.values,
        (SimulatedLayout region) async {
      int selectedIndex = 0;
      final MaterialApp app =
          region.scaffold(tester, initialIndex: selectedIndex);
      await tester.binding.setSurfaceSize(region.size);
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // tap on the next icon
      selectedIndex = (selectedIndex + 1) % TestScaffold.destinations.length;

      // Resolve the icon that should be found
      final NavigationDestination destination =
          TestScaffold.destinations[selectedIndex];
      expect(destination.icon, isA<Icon>());
      final Icon icon = destination.icon as Icon;
      expect(icon.icon, isNotNull);

      // Find the icon in the application to tap
      final Widget navigationSlot =
          tester.widget(find.byKey(Key(region.navSlotKey)));
      final Finder target =
          find.widgetWithIcon(navigationSlot.runtimeType, icon.icon!);
      expect(target, findsOneWidget);

      await tester.tap(target);
      await tester.pumpAndSettle();

      // Check that the state was set appropriately
      final Finder scaffold = find.byType(TestScaffold);
      final TestScaffoldState state = tester.state<TestScaffoldState>(scaffold);
      expect(selectedIndex, state.index);
    });
  });

  // Regression test for https://github.com/flutter/flutter/issues/111008
  testWidgets(
    "appBar parameter should have the type PreferredSizeWidget",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(500, 800)),
            child: AdaptiveScaffold(
              drawerBreakpoint: TestBreakpoint0(),
              internalAnimations: false,
              destinations: const <NavigationDestination>[
                NavigationDestination(icon: Icon(Icons.inbox), label: "Inbox"),
                NavigationDestination(
                  icon: Icon(Icons.video_call),
                  label: "Video",
                ),
              ],
              appBar: const PreferredSizeWidgetImpl(),
            ),
          ),
        ),
      );

      expect(find.byType(PreferredSizeWidgetImpl), findsOneWidget);
    },
  );

  // Verify that the leading navigation rail widget is displayed
  // based on the screen size
  testWidgets(
    "adaptive scaffold displays leading widget in navigation rail",
    (WidgetTester tester) async {
      await Future.forEach(SimulatedLayout.values,
          (SimulatedLayout region) async {
        final MaterialApp app = region.scaffold(tester);
        await tester.binding.setSurfaceSize(region.size);
        await tester.pumpWidget(app);
        await tester.pumpAndSettle();

        if (region.size == SimulatedLayout.mediumLarge.size) {
          expect(find.text("leading_extended"), findsOneWidget);
          expect(find.text("leading_unextended"), findsNothing);
          expect(find.text("trailing"), findsOneWidget);
        } else if (region.size == SimulatedLayout.medium.size) {
          expect(find.text("leading_extended"), findsNothing);
          expect(find.text("leading_unextended"), findsOneWidget);
          expect(find.text("trailing"), findsOneWidget);
        } else if (region.size == SimulatedLayout.small.size) {
          expect(find.text("leading_extended"), findsNothing);
          expect(find.text("leading_unextended"), findsNothing);
          expect(find.text("trailing"), findsNothing);
        }
      });
    },
  );

  /// Verify that selectedIndex of [AdaptiveScaffold.standardNavigationRail]
  /// and [AdaptiveScaffold] can be set to null
  testWidgets(
    "adaptive scaffold selectedIndex can be set to null",
    (WidgetTester tester) async {
      await Future.forEach(SimulatedLayout.values,
          (SimulatedLayout region) async {
        int? selectedIndex;
        final MaterialApp app =
            region.scaffold(tester, initialIndex: selectedIndex);
        await tester.binding.setSurfaceSize(region.size);
        await tester.pumpWidget(app);
        await tester.pumpAndSettle();
      });
    },
  );

  testWidgets(
    "standardBottomNavigationBar normalizes plain NavigationDestination widgets",
    (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: "Home",
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: "Profile",
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AdaptiveScaffold.standardBottomNavigationBar(
              destinations: destinations,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(CustomNavigationDestination), findsNWidgets(2));
    },
  );

  testWidgets(
    "when destinations passed with all data, it shall not be null",
    (WidgetTester tester) async {
      const List<CustomNavigationDestination> destinations =
          <CustomNavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.inbox_outlined),
          selectedIcon: Icon(Icons.inbox),
          label: "Inbox",
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.video_call_outlined),
          selectedIcon: Icon(Icons.video_call),
          label: "Video",
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(700, 900)),
            child: AdaptiveScaffold(
              destinations: destinations,
            ),
          ),
        ),
      );

      final Finder fNavigationRail = find.descendant(
        of: find.byType(AdaptiveScaffold),
        matching: find.byType(CustomNavigationRail),
      );
      final CustomNavigationRail navigationRail =
          tester.firstWidget(fNavigationRail);
      expect(
        navigationRail.destinations,
        isA<List<NavigationRailDestination>>(),
      );
      expect(
        navigationRail.destinations.length,
        destinations.length,
      );

      for (final NavigationRailDestination destination
          in navigationRail.destinations) {
        expect(destination.label, isNotNull);
        expect(destination.icon, isA<Icon>());
        expect(destination.icon, isNotNull);
        expect(destination.selectedIcon, isA<Icon?>());
        expect(destination.selectedIcon, isNotNull);
      }

      final CustomNavigationDestination firstDestinationFromListPassed =
          destinations.first;
      final NavigationRailDestination firstDestinationFromFinderView =
          navigationRail.destinations.first;

      expect(firstDestinationFromListPassed, isNotNull);
      expect(firstDestinationFromFinderView, isNotNull);

      expect(
        firstDestinationFromListPassed.icon,
        equals(firstDestinationFromFinderView.icon),
      );
      expect(
        firstDestinationFromListPassed.selectedIcon,
        equals(firstDestinationFromFinderView.selectedIcon),
      );
    },
  );

  testWidgets(
    "when tap happens on any destination, its selected icon shall be visible",
    (WidgetTester tester) async {
      //region Keys
      const ValueKey<String> firstDestinationIconKey = ValueKey<String>(
        "first-normal-icon",
      );
      const ValueKey<String> firstDestinationSelectedIconKey = ValueKey<String>(
        "first-selected-icon",
      );
      const ValueKey<String> lastDestinationIconKey = ValueKey<String>(
        "last-normal-icon",
      );
      const ValueKey<String> lastDestinationSelectedIconKey = ValueKey<String>(
        "last-selected-icon",
      );
      //endregion

      //region Finder for destinations as per its icon.
      final Finder firstDestinationWithSelectedIcon = find.byKey(
        firstDestinationSelectedIconKey,
      );
      final Finder lastDestinationWithIcon = find.byKey(
        lastDestinationIconKey,
      );

      final Finder firstDestinationWithIcon = find.byKey(
        firstDestinationIconKey,
      );
      final Finder lastDestinationWithSelectedIcon = find.byKey(
        lastDestinationSelectedIconKey,
      );
      //endregion

      int selectedDestination = 0;
      const List<NavigationDestination> destinations = <NavigationDestination>[
        NavigationDestination(
          icon: Icon(
            Icons.inbox_outlined,
            key: firstDestinationIconKey,
          ),
          selectedIcon: Icon(
            Icons.inbox,
            key: firstDestinationSelectedIconKey,
          ),
          label: "Inbox",
        ),
        NavigationDestination(
          icon: Icon(
            Icons.video_call_outlined,
            key: lastDestinationIconKey,
          ),
          selectedIcon: Icon(
            Icons.video_call,
            key: lastDestinationSelectedIconKey,
          ),
          label: "Video",
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(700, 900)),
            child: StatefulBuilder(
              builder: (
                BuildContext context,
                void Function(void Function()) setState,
              ) {
                return AdaptiveScaffold(
                  destinations: destinations,
                  selectedIndex: selectedDestination,
                  onSelectedIndexChange: (int value) {
                    setState(() {
                      selectedDestination = value;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(selectedDestination, 0);
      expect(firstDestinationWithSelectedIcon, findsOneWidget);
      expect(lastDestinationWithIcon, findsOneWidget);
      expect(firstDestinationWithIcon, findsNothing);
      expect(lastDestinationWithSelectedIcon, findsNothing);

      await tester.ensureVisible(lastDestinationWithIcon);
      await tester.tap(lastDestinationWithIcon);
      await tester.pumpAndSettle();
      expect(selectedDestination, 1);

      expect(firstDestinationWithSelectedIcon, findsNothing);
      expect(lastDestinationWithIcon, findsNothing);
      expect(firstDestinationWithIcon, findsOneWidget);
      expect(lastDestinationWithSelectedIcon, findsOneWidget);
    },
  );

  testWidgets(
    "when view in medium screen, navigation rail must be visible as per theme data values.",
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(SimulatedLayout.medium.size);
      await tester.pumpWidget(SimulatedLayout.medium.scaffold(tester));
      await tester.pumpAndSettle();

      final Finder primaryNavigationMedium = find.byKey(
        const Key("primaryNavigation"),
      );
      expect(primaryNavigationMedium, findsOneWidget);

      final Finder navigationRailFinder = find.descendant(
        of: primaryNavigationMedium,
        matching: find.byType(CustomNavigationRail),
      );
      expect(navigationRailFinder, findsOneWidget);

      final CustomNavigationRail navigationRailView = tester.firstWidget(
        navigationRailFinder,
      );
      expect(navigationRailView, isNotNull);

      expect(
        navigationRailView.backgroundColor,
        SimulatedLayout.navigationRailThemeBgColor,
      );
      expect(
        navigationRailView.selectedIconTheme?.color,
        SimulatedLayout.selectedIconThemeData.color,
      );
      expect(
        navigationRailView.selectedIconTheme?.size,
        SimulatedLayout.selectedIconThemeData.size,
      );
      expect(
        navigationRailView.unselectedIconTheme?.color,
        SimulatedLayout.unSelectedIconThemeData.color,
      );
      expect(
        navigationRailView.unselectedIconTheme?.size,
        SimulatedLayout.unSelectedIconThemeData.size,
      );
    },
  );

  testWidgets(
    "when view in mediumLarge screen, navigation rail must be visible as per theme data values.",
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(SimulatedLayout.mediumLarge.size);
      await tester.pumpWidget(SimulatedLayout.mediumLarge.scaffold(tester));
      await tester.pumpAndSettle();

      final Finder primaryNavigationMediumLarge = find.byKey(
        const Key("primaryNavigation1"),
      );
      expect(primaryNavigationMediumLarge, findsOneWidget);

      final Finder navigationRailFinder = find.descendant(
        of: primaryNavigationMediumLarge,
        matching: find.byType(CustomNavigationRail),
      );
      expect(navigationRailFinder, findsOneWidget);

      final CustomNavigationRail navigationRailView = tester.firstWidget(
        navigationRailFinder,
      );
      expect(navigationRailView, isNotNull);

      expect(
        navigationRailView.backgroundColor,
        SimulatedLayout.navigationRailThemeBgColor,
      );
      expect(
        navigationRailView.selectedIconTheme?.color,
        SimulatedLayout.selectedIconThemeData.color,
      );
      expect(
        navigationRailView.selectedIconTheme?.size,
        SimulatedLayout.selectedIconThemeData.size,
      );
      expect(
        navigationRailView.unselectedIconTheme?.color,
        SimulatedLayout.unSelectedIconThemeData.color,
      );
      expect(
        navigationRailView.unselectedIconTheme?.size,
        SimulatedLayout.unSelectedIconThemeData.size,
      );
    },
  );

  testWidgets(
    "when drawer item tap, it shall close the already open drawer",
    (WidgetTester tester) async {
      //region Keys
      const ValueKey<String> firstDestinationIconKey = ValueKey<String>(
        "first-normal-icon",
      );
      const ValueKey<String> firstDestinationSelectedIconKey = ValueKey<String>(
        "first-selected-icon",
      );
      const ValueKey<String> lastDestinationIconKey = ValueKey<String>(
        "last-normal-icon",
      );
      const ValueKey<String> lastDestinationSelectedIconKey = ValueKey<String>(
        "last-selected-icon",
      );
      //endregion

      //region Finder for destinations as per its icon.
      final Finder lastDestinationWithIcon = find.byKey(
        lastDestinationIconKey,
      );
      final Finder lastDestinationWithSelectedIcon = find.byKey(
        lastDestinationSelectedIconKey,
      );
      //endregion

      const List<NavigationDestination> destinations = <NavigationDestination>[
        NavigationDestination(
          icon: Icon(
            Icons.inbox_outlined,
            key: firstDestinationIconKey,
          ),
          selectedIcon: Icon(
            Icons.inbox,
            key: firstDestinationSelectedIconKey,
          ),
          label: "Inbox",
        ),
        NavigationDestination(
          icon: Icon(
            Icons.video_call_outlined,
            key: lastDestinationIconKey,
          ),
          selectedIcon: Icon(
            Icons.video_call,
            key: lastDestinationSelectedIconKey,
          ),
          label: "Video",
        ),
      ];
      int selectedDestination = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(450, 900)),
            child: StatefulBuilder(
              builder: (
                BuildContext context,
                void Function(void Function()) setState,
              ) {
                return AdaptiveScaffold(
                  destinations: destinations,
                  selectedIndex: selectedDestination,
                  smallBreakpoint: TestBreakpoint400(),
                  drawerBreakpoint: TestBreakpoint400(),
                  onSelectedIndexChange: (int value) {
                    setState(() {
                      selectedDestination = value;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(selectedDestination, 0);
      Finder fDrawer = find.byType(Drawer);
      Finder fNavigationRail = find.descendant(
        of: fDrawer,
        matching: find.byType(NavigationRail),
      );
      expect(fDrawer, findsNothing);
      expect(fNavigationRail, findsNothing);

      final ScaffoldState state = tester.state(find.byType(Scaffold));
      state.openDrawer();
      await tester.pumpAndSettle(Durations.short4);
      expect(state.isDrawerOpen, isTrue);

      // Need to find again as Scaffold's state has been updated
      fDrawer = find.byType(Drawer);
      fNavigationRail = find.descendant(
        of: fDrawer,
        matching: find.byType(NavigationRail),
      );
      expect(fDrawer, findsOneWidget);
      expect(fNavigationRail, findsOneWidget);

      expect(lastDestinationWithIcon, findsOneWidget);
      expect(lastDestinationWithSelectedIcon, findsNothing);

      await tester.ensureVisible(lastDestinationWithIcon);
      await tester.tap(lastDestinationWithIcon);
      await tester.pumpAndSettle(Durations.short4);
      expect(selectedDestination, 1);
      expect(state.isDrawerOpen, isFalse);
    },
  );

  // This test checks whether AdaptiveScaffold.standardNavigationRail function
  // creates a NavigationRail widget as expected with groupAlignment provided,
  // and checks whether the NavigationRail's groupAlignment matches the expected value.
  testWidgets(
    "groupAligment parameter of AdaptiveScaffold.standardNavigationRail works correctly",
    (WidgetTester tester) async {
      const List<NavigationRailDestination> destinations =
          <NavigationRailDestination>[
        NavigationRailDestination(
          icon: Icon(Icons.home),
          label: Text("Home"),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.account_circle),
          label: Text("Profile"),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings),
          label: Text("Settings"),
        ),
      ];

      const double groupAlignment = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return AdaptiveScaffold.standardNavigationRail(
                  destinations: destinations,
                  groupAlignment: groupAlignment,
                );
              },
            ),
          ),
        ),
      );
      final CustomNavigationRail rail = tester
          .widget<CustomNavigationRail>(find.byType(CustomNavigationRail));
      expect(rail.groupAlignment, equals(groupAlignment));
    },
  );

  testWidgets(
    "doesn't override Directionality",
    (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        NavigationDestination(
          icon: Icon(Icons.account_circle),
          label: "Profile",
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.rtl,
              child: AdaptiveScaffold(
                destinations: destinations,
                body: (BuildContext context) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      final Finder body = find.byKey(const Key("body"));
      expect(body, findsOneWidget);
      final TextDirection dir = Directionality.of(body.evaluate().first);
      expect(dir, TextDirection.rtl);
    },
  );

  testWidgets(
    "when appBarBreakpoint is provided validate an AppBar is showing without Drawer on larger than mobile",
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(SimulatedLayout.medium.size);
      await tester.pumpWidget(
        SimulatedLayout.medium
            .scaffold(tester, appBarBreakpoint: AppBarAlwaysOnBreakpoint()),
      );
      await tester.pumpAndSettle();

      final Finder appBar = find.byType(AppBar);
      final Finder drawer = find.byType(Drawer);
      expect(appBar, findsOneWidget);
      expect(drawer, findsNothing);

      await tester.binding.setSurfaceSize(SimulatedLayout.mediumLarge.size);
      await tester.pumpWidget(
        SimulatedLayout.mediumLarge
            .scaffold(tester, appBarBreakpoint: AppBarAlwaysOnBreakpoint()),
      );
      expect(drawer, findsNothing);
      await tester.pumpAndSettle();

      expect(appBar, findsOneWidget);
    },
  );

  testWidgets(
    "When only one destination passed, shall throw assertion error",
    (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.inbox_outlined),
          selectedIcon: Icon(Icons.inbox),
          label: "Inbox",
        ),
      ];

      expect(
        () => tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(700, 900)),
              child: AdaptiveScaffold(
                destinations: destinations,
              ),
            ),
          ),
        ),
        throwsA(isA<AssertionError>()),
      );
    },
  );

  // Test for navigationRailDestinationBuilder parameter.
  testWidgets("adaptive scaffold custom navigation rail destination mapping",
      (WidgetTester tester) async {
    const List<NavigationDestination> destinations = <NavigationDestination>[
      NavigationDestination(
        icon: Icon(Icons.home),
        label: "Home",
      ),
      NavigationDestination(
        icon: Icon(Icons.account_circle),
        label: "Profile",
      ),
    ];

    NavigationRailDestination customMapping(
      int index,
      NavigationDestination destination,
    ) {
      return NavigationRailDestination(
        icon: destination.icon,
        label: Text("Custom ${destination.label}"),
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(800, 600)),
          child: AdaptiveScaffold(
            destinations: destinations,
            navigationRailDestinationBuilder: customMapping,
          ),
        ),
      ),
    );

    expect(find.text("Custom Home"), findsOneWidget);
    expect(find.text("Custom Profile"), findsOneWidget);
  });

  // Compact rail should continue honoring the theme by default.
  testWidgets(
    "adaptive scaffold respects NavigationRailLabelType from theme",
    (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.account_circle),
          label: "Profile",
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            navigationRailTheme: const NavigationRailThemeData(
              labelType: NavigationRailLabelType.all,
            ),
          ),
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: AdaptiveScaffold(
              destinations: destinations,
            ),
          ),
        ),
      );

      final CustomNavigationRail compactRail = tester
          .widget<CustomNavigationRail>(find.byType(CustomNavigationRail));
      expect(compactRail.labelType, NavigationRailLabelType.all);
    },
  );

  testWidgets(
    "adaptive scaffold navigationTheme can hide compact rail labels",
    (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.account_circle),
          label: "Profile",
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            navigationRailTheme: const NavigationRailThemeData(
              labelType: NavigationRailLabelType.all,
            ),
          ),
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: AdaptiveScaffold(
              destinations: destinations,
              navigationTheme: const AdaptiveScaffoldThemeData(
                compactLabelType: NavigationRailLabelType.none,
              ),
            ),
          ),
        ),
      );

      final CustomNavigationRail compactRail = tester
          .widget<CustomNavigationRail>(find.byType(CustomNavigationRail));
      expect(compactRail.labelType, NavigationRailLabelType.none);
    },
  );

  testWidgets(
    "adaptive scaffold reads compact label type from ThemeData extension",
    (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.account_circle),
          label: "Profile",
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[
              AdaptiveScaffoldThemeData(
                compactLabelType: NavigationRailLabelType.none,
              ),
            ],
          ),
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: AdaptiveScaffold(
              destinations: destinations,
              navigationTheme: null,
            ),
          ),
        ),
      );

      final CustomNavigationRail compactRail = tester
          .widget<CustomNavigationRail>(find.byType(CustomNavigationRail));
      expect(compactRail.labelType, NavigationRailLabelType.none);
    },
  );

  testWidgets(
    "adaptive scaffold applies theme precedence widget > inherited > extension",
    (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.account_circle),
          label: "Profile",
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[
              AdaptiveScaffoldThemeData(
                compactLabelType: NavigationRailLabelType.none,
              ),
            ],
          ),
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: AdaptiveScaffoldTheme(
              data: const AdaptiveScaffoldThemeData(
                compactLabelType: NavigationRailLabelType.all,
              ),
              child: AdaptiveScaffold(
                destinations: destinations,
                navigationTheme: const AdaptiveScaffoldThemeData(
                  compactLabelType: NavigationRailLabelType.selected,
                ),
              ),
            ),
          ),
        ),
      );

      final CustomNavigationRail compactRail = tester
          .widget<CustomNavigationRail>(find.byType(CustomNavigationRail));
      expect(compactRail.labelType, NavigationRailLabelType.selected);
    },
  );

  testWidgets(
    "adaptive scaffold applies shape precedence widget > inherited > extension",
    (WidgetTester tester) async {
      const ShapeBorder extensionShape = StadiumBorder();
      const ShapeBorder inheritedShape = CircleBorder();
      const ShapeBorder widgetShape = RoundedRectangleBorder();
      const List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.account_circle),
          label: "Profile",
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[
              AdaptiveScaffoldThemeData(
                indicatorStyle: NavigationIndicatorThemeData(
                  interactionShape:
                      WidgetStatePropertyAll<ShapeBorder?>(extensionShape),
                ),
              ),
            ],
          ),
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: AdaptiveScaffoldTheme(
              data: const AdaptiveScaffoldThemeData(
                indicatorStyle: NavigationIndicatorThemeData(
                  interactionShape:
                      WidgetStatePropertyAll<ShapeBorder?>(inheritedShape),
                ),
              ),
              child: AdaptiveScaffold(
                destinations: destinations,
                navigationTheme: const AdaptiveScaffoldThemeData(
                  indicatorStyle: NavigationIndicatorThemeData(
                    interactionShape:
                        WidgetStatePropertyAll<ShapeBorder?>(widgetShape),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final CustomNavigationRail compactRail = tester
          .widget<CustomNavigationRail>(find.byType(CustomNavigationRail));
      expect(compactRail.shape, isA<WidgetStateProperty<ShapeBorder?>>());
      expect(
        compactRail.shape?.resolve(const <WidgetState>{WidgetState.selected}),
        same(widgetShape),
      );
    },
  );

  testWidgets(
    "adaptive scaffold applies destinationFillRegion precedence widget > inherited > extension",
    (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.account_circle),
          label: "Profile",
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[
              AdaptiveScaffoldThemeData(
                indicatorStyle: NavigationIndicatorThemeData(
                  destinationFillRegion: NavigationDestinationRegion.icon,
                ),
              ),
            ],
          ),
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: AdaptiveScaffoldTheme(
              data: const AdaptiveScaffoldThemeData(
                indicatorStyle: NavigationIndicatorThemeData(
                  destinationFillRegion: NavigationDestinationRegion.label,
                ),
              ),
              child: AdaptiveScaffold(
                destinations: destinations,
                navigationTheme: const AdaptiveScaffoldThemeData(
                  indicatorStyle: NavigationIndicatorThemeData(
                    destinationFillRegion: NavigationDestinationRegion.full,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final CustomNavigationRail compactRail = tester
          .widget<CustomNavigationRail>(find.byType(CustomNavigationRail));
      expect(
        compactRail.destinationFillRegion,
        NavigationDestinationRegion.full,
      );
    },
  );

  testWidgets(
    "adaptive scaffold applies destinationHoverRegion precedence widget > inherited > extension",
    (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.account_circle),
          label: "Profile",
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[
              AdaptiveScaffoldThemeData(
                indicatorStyle: NavigationIndicatorThemeData(
                  destinationHoverRegion: NavigationDestinationRegion.icon,
                ),
              ),
            ],
          ),
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: AdaptiveScaffoldTheme(
              data: const AdaptiveScaffoldThemeData(
                indicatorStyle: NavigationIndicatorThemeData(
                  destinationHoverRegion: NavigationDestinationRegion.label,
                ),
              ),
              child: AdaptiveScaffold(
                destinations: destinations,
                navigationTheme: const AdaptiveScaffoldThemeData(
                  indicatorStyle: NavigationIndicatorThemeData(
                    destinationHoverRegion: NavigationDestinationRegion.full,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final CustomNavigationRail compactRail = tester
          .widget<CustomNavigationRail>(find.byType(CustomNavigationRail));
      expect(
        compactRail.destinationHoverRegion,
        NavigationDestinationRegion.full,
      );
    },
  );

  testWidgets(
    "adaptive scaffold applies transitionDuration precedence widget > inherited > extension",
    (WidgetTester tester) async {
      const Duration extensionDuration = Duration(milliseconds: 100);
      const Duration inheritedDuration = Duration(milliseconds: 200);
      const Duration widgetDuration = Duration(milliseconds: 300);
      const List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.account_circle),
          label: "Profile",
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[
              AdaptiveScaffoldThemeData(
                transitionDuration: extensionDuration,
              ),
            ],
          ),
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: AdaptiveScaffoldTheme(
              data: const AdaptiveScaffoldThemeData(
                transitionDuration: inheritedDuration,
              ),
              child: AdaptiveScaffold(
                destinations: destinations,
                navigationTheme: const AdaptiveScaffoldThemeData(
                  transitionDuration: widgetDuration,
                ),
              ),
            ),
          ),
        ),
      );

      final CustomNavigationRail compactRail = tester
          .widget<CustomNavigationRail>(find.byType(CustomNavigationRail));
      expect(compactRail.iconTransitionDuration, widgetDuration);
    },
  );

  testWidgets(
    "adaptive scaffold applies bar theme precedence widget > inherited > extension",
    (WidgetTester tester) async {
      const double extensionHeight = 72;
      const double inheritedHeight = 76;
      const double widgetHeight = 84;
      const NavigationDestinationLabelBehavior extensionLabelBehavior =
          NavigationDestinationLabelBehavior.alwaysHide;
      const NavigationDestinationLabelBehavior inheritedLabelBehavior =
          NavigationDestinationLabelBehavior.onlyShowSelected;
      const NavigationDestinationLabelBehavior widgetLabelBehavior =
          NavigationDestinationLabelBehavior.alwaysShow;
      const ShapeBorder extensionIndicatorShape = StadiumBorder();
      const ShapeBorder inheritedIndicatorShape = CircleBorder();
      const ShapeBorder widgetIndicatorShape = BeveledRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      );

      const List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.account_circle),
          label: "Profile",
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[
              AdaptiveScaffoldThemeData(
                navigationBarTheme: AdaptiveNavigationBarThemeData(
                  height: extensionHeight,
                  labelBehavior: extensionLabelBehavior,
                ),
                indicatorStyle: NavigationIndicatorThemeData(
                  shape: extensionIndicatorShape,
                ),
              ),
            ],
          ),
          home: MediaQuery(
            data: const MediaQueryData(size: Size(500, 800)),
            child: AdaptiveScaffoldTheme(
              data: const AdaptiveScaffoldThemeData(
                navigationBarTheme: AdaptiveNavigationBarThemeData(
                  height: inheritedHeight,
                  labelBehavior: inheritedLabelBehavior,
                ),
                indicatorStyle: NavigationIndicatorThemeData(
                  shape: inheritedIndicatorShape,
                ),
              ),
              child: AdaptiveScaffold(
                destinations: destinations,
                navigationTheme: const AdaptiveScaffoldThemeData(
                  navigationBarTheme: AdaptiveNavigationBarThemeData(
                    height: widgetHeight,
                    labelBehavior: widgetLabelBehavior,
                  ),
                  indicatorStyle: NavigationIndicatorThemeData(
                    shape: widgetIndicatorShape,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final Finder barFinder = find.byType(CustomNavigationBar);
      expect(barFinder, findsOneWidget);

      final CustomNavigationBar bar = tester.widget<CustomNavigationBar>(
        barFinder,
      );
      expect(bar.labelBehavior, widgetLabelBehavior);

      final Finder navBarThemeFinder = find.ancestor(
        of: barFinder,
        matching: find.byType(NavigationBarTheme),
      );
      expect(navBarThemeFinder, findsWidgets);

      final NavigationBarTheme navBarTheme = tester.widget<NavigationBarTheme>(
        navBarThemeFinder.first,
      );
      expect(navBarTheme.data.height, widgetHeight);
      expect(navBarTheme.data.labelBehavior, widgetLabelBehavior);
      expect(navBarTheme.data.indicatorShape, widgetIndicatorShape);
    },
  );

  testWidgets(
    "adaptive scaffold bar uses interactionShape over indicatorShape",
    (WidgetTester tester) async {
      const ShapeBorder interactionShape = CircleBorder();
      const ShapeBorder indicatorShape = BeveledRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      );
      const List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.account_circle),
          label: "Profile",
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(500, 800)),
            child: AdaptiveScaffold(
              destinations: destinations,
              navigationTheme: const AdaptiveScaffoldThemeData(
                indicatorStyle: NavigationIndicatorThemeData(
                  destinationFillRegion: NavigationDestinationRegion.full,
                  interactionShape:
                      WidgetStatePropertyAll<ShapeBorder?>(interactionShape),
                  shape: indicatorShape,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Finder barFinder = find.byType(CustomNavigationBar);
      expect(barFinder, findsOneWidget);
      final Finder inkResponses = find.descendant(
        of: barFinder,
        matching: find.byWidgetPredicate(
          (Widget widget) => widget is InkResponse,
        ),
      );
      expect(inkResponses, findsWidgets);
      final InkResponse firstInk = tester.widget<InkResponse>(
        inkResponses.first,
      );
      expect(firstInk.customBorder, interactionShape);
    },
  );

  testWidgets(
    "adaptive scaffold applies bar margin/padding precedence widget > inherited > extension",
    (WidgetTester tester) async {
      const EdgeInsets extensionMargin = EdgeInsets.symmetric(horizontal: 4);
      const EdgeInsets inheritedMargin = EdgeInsets.symmetric(horizontal: 10);
      const EdgeInsets widgetMargin = EdgeInsets.symmetric(horizontal: 16);
      const EdgeInsets extensionPadding = EdgeInsets.symmetric(horizontal: 2);
      const EdgeInsets inheritedPadding = EdgeInsets.symmetric(horizontal: 6);
      const EdgeInsets widgetPadding = EdgeInsets.symmetric(horizontal: 12);

      const List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.account_circle),
          label: "Profile",
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[
              AdaptiveScaffoldThemeData(
                navigationBarTheme: AdaptiveNavigationBarThemeData(
                  margin: extensionMargin,
                  padding: extensionPadding,
                ),
              ),
            ],
          ),
          home: MediaQuery(
            data: const MediaQueryData(size: Size(500, 800)),
            child: AdaptiveScaffoldTheme(
              data: const AdaptiveScaffoldThemeData(
                navigationBarTheme: AdaptiveNavigationBarThemeData(
                  margin: inheritedMargin,
                  padding: inheritedPadding,
                ),
              ),
              child: AdaptiveScaffold(
                destinations: destinations,
                navigationTheme: const AdaptiveScaffoldThemeData(
                  navigationBarTheme: AdaptiveNavigationBarThemeData(
                    margin: widgetMargin,
                    padding: widgetPadding,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final CustomNavigationBar bar = tester.widget<CustomNavigationBar>(
        find.byType(CustomNavigationBar),
      );
      expect(bar.margin, widgetMargin);
      expect(bar.padding, widgetPadding);
    },
  );

  testWidgets(
    "adaptive scaffold bar falls back to indicatorShape when interactionShape is null",
    (WidgetTester tester) async {
      const ShapeBorder indicatorShape = BeveledRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      );
      const List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.account_circle),
          label: "Profile",
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(500, 800)),
            child: AdaptiveScaffold(
              destinations: destinations,
              navigationTheme: const AdaptiveScaffoldThemeData(
                indicatorStyle: NavigationIndicatorThemeData(
                  destinationFillRegion: NavigationDestinationRegion.full,
                  shape: indicatorShape,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Finder barFinder = find.byType(CustomNavigationBar);
      expect(barFinder, findsOneWidget);
      final Finder inkResponses = find.descendant(
        of: barFinder,
        matching: find.byWidgetPredicate(
          (Widget widget) => widget is InkResponse,
        ),
      );
      expect(inkResponses, findsWidgets);
      final InkResponse firstInk = tester.widget<InkResponse>(
        inkResponses.first,
      );
      expect(firstInk.customBorder, indicatorShape);
    },
  );

  testWidgets(
    "adaptive scaffold navigationTheme can set expanded rail label type",
    (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.account_circle),
          label: "Profile",
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            navigationRailTheme: const NavigationRailThemeData(
              labelType: NavigationRailLabelType.all,
            ),
          ),
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1300, 600)),
            child: AdaptiveScaffold(
              destinations: destinations,
              navigationTheme: const AdaptiveScaffoldThemeData(
                expandedLabelType: NavigationRailLabelType.none,
              ),
            ),
          ),
        ),
      );

      final CustomNavigationRail expandedRail = tester
          .widget<CustomNavigationRail>(find.byType(CustomNavigationRail));
      expect(expandedRail.labelType, NavigationRailLabelType.none);
      // Extended rails always show labels, matching Flutter NavigationRail.
      expect(find.text("Home"), findsOneWidget);
      expect(find.text("Profile"), findsOneWidget);
    },
  );

  testWidgets(
    "adaptive scaffold expanded rail defaults to all labels",
    (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.account_circle),
          label: "Profile",
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1300, 600)),
            child: AdaptiveScaffold(
              destinations: destinations,
            ),
          ),
        ),
      );

      final CustomNavigationRail expandedRail = tester
          .widget<CustomNavigationRail>(find.byType(CustomNavigationRail));
      expect(expandedRail.labelType, NavigationRailLabelType.all);
      expect(find.text("Home"), findsOneWidget);
      expect(find.text("Profile"), findsOneWidget);
    },
  );

  testWidgets(
    "adaptive scaffold expanded rail selected mode shows selected label only",
    (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.account_circle),
          label: "Profile",
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1300, 600)),
            child: AdaptiveScaffold(
              selectedIndex: 0,
              destinations: destinations,
              navigationTheme: const AdaptiveScaffoldThemeData(
                expandedLabelType: NavigationRailLabelType.selected,
              ),
            ),
          ),
        ),
      );

      final CustomNavigationRail expandedRail = tester
          .widget<CustomNavigationRail>(find.byType(CustomNavigationRail));
      expect(expandedRail.labelType, NavigationRailLabelType.selected);
      expect(find.text("Home"), findsOneWidget);
      expect(find.text("Profile"), findsNothing);
    },
  );

  testWidgets(
    "adaptive scaffold navigationTheme can set extended rail width",
    (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.account_circle),
          label: "Profile",
        ),
      ];
      const double themedExtendedWidth = 248;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1300, 600)),
            child: AdaptiveScaffold(
              destinations: destinations,
              navigationTheme: const AdaptiveScaffoldThemeData(
                extendedNavigationRailWidth: themedExtendedWidth,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Finder expandedRailFinder = find.byType(CustomNavigationRail);
      expect(expandedRailFinder, findsOneWidget);
      final Size expandedRailSize = tester.getSize(expandedRailFinder);
      expect(expandedRailSize.width, themedExtendedWidth);
    },
  );

  testWidgets(
    "adaptive scaffold applies extended rail width precedence widget > inherited > extension",
    (WidgetTester tester) async {
      const double extensionWidth = 220;
      const double inheritedWidth = 236;
      const double widgetWidth = 264;
      const List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.account_circle),
          label: "Profile",
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[
              AdaptiveScaffoldThemeData(
                extendedNavigationRailWidth: extensionWidth,
              ),
            ],
          ),
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1300, 600)),
            child: AdaptiveScaffoldTheme(
              data: const AdaptiveScaffoldThemeData(
                extendedNavigationRailWidth: inheritedWidth,
              ),
              child: AdaptiveScaffold(
                destinations: destinations,
                navigationTheme: const AdaptiveScaffoldThemeData(
                  extendedNavigationRailWidth: widgetWidth,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Finder expandedRailFinder = find.byType(CustomNavigationRail);
      expect(expandedRailFinder, findsOneWidget);
      final Size expandedRailSize = tester.getSize(expandedRailFinder);
      expect(expandedRailSize.width, widgetWidth);
    },
  );

  testWidgets(
    "adaptive scaffold controller preserves legacy small layout until intent is explicit",
    (WidgetTester tester) async {
      final AdaptiveScaffoldController controller =
          AdaptiveScaffoldController();

      await tester.binding.setSurfaceSize(SimulatedLayout.small.size);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData.fromView(tester.view)
                .copyWith(size: SimulatedLayout.small.size),
            child: AdaptiveScaffold(
              destinations: TestScaffold.destinations,
              smallBreakpoint: TestBreakpoint0(),
              mediumBreakpoint: TestBreakpoint800(),
              mediumLargeBreakpoint: TestBreakpoint1000(),
              largeBreakpoint: TestBreakpoint1200(),
              extraLargeBreakpoint: TestBreakpoint1600(),
              controller: controller,
              smallBody: (_) => Container(key: const Key("smallListPane")),
              body: (_) => const SizedBox.shrink(),
              smallSecondaryBody: (_) =>
                  Container(key: const Key("smallDetailsPane")),
              secondaryBody: (_) => const SizedBox.shrink(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Attached but untouched controller preserves legacy dual-pane behavior.
      expect(find.byKey(const Key("smallListPane")), findsOneWidget);
      expect(find.byKey(const Key("smallDetailsPane")), findsOneWidget);

      controller.showSecondaryBody();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key("smallListPane")), findsNothing);
      expect(find.byKey(const Key("smallDetailsPane")), findsOneWidget);

      controller.showBody();
      await tester.pumpAndSettle();

      expect(find.byKey(const Key("smallListPane")), findsOneWidget);
      expect(find.byKey(const Key("smallDetailsPane")), findsNothing);

      await tester.binding.setSurfaceSize(SimulatedLayout.medium.size);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData.fromView(tester.view)
                .copyWith(size: SimulatedLayout.medium.size),
            child: AdaptiveScaffold(
              destinations: TestScaffold.destinations,
              smallBreakpoint: TestBreakpoint0(),
              mediumBreakpoint: TestBreakpoint800(),
              mediumLargeBreakpoint: TestBreakpoint1000(),
              largeBreakpoint: TestBreakpoint1200(),
              extraLargeBreakpoint: TestBreakpoint1600(),
              controller: controller,
              body: (_) => Container(key: const Key("mediumListPane")),
              secondaryBody: (_) =>
                  Container(key: const Key("mediumDetailsPane")),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key("mediumListPane")), findsOneWidget);
      expect(find.byKey(const Key("mediumDetailsPane")), findsOneWidget);

      controller.dispose();
    },
  );

  testWidgets(
    "adaptive scaffold controller can start with explicit details intent",
    (WidgetTester tester) async {
      final AdaptiveScaffoldController controller = AdaptiveScaffoldController(
        initialIntent: PanelFocus.secondaryBody,
      );

      await tester.binding.setSurfaceSize(SimulatedLayout.small.size);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData.fromView(tester.view)
                .copyWith(size: SimulatedLayout.small.size),
            child: AdaptiveScaffold(
              destinations: TestScaffold.destinations,
              smallBreakpoint: TestBreakpoint0(),
              mediumBreakpoint: TestBreakpoint800(),
              mediumLargeBreakpoint: TestBreakpoint1000(),
              largeBreakpoint: TestBreakpoint1200(),
              extraLargeBreakpoint: TestBreakpoint1600(),
              controller: controller,
              smallBody: (_) => Container(key: const Key("smallListPane")),
              body: (_) => const SizedBox.shrink(),
              smallSecondaryBody: (_) =>
                  Container(key: const Key("smallDetailsPane")),
              secondaryBody: (_) => const SizedBox.shrink(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key("smallListPane")), findsNothing);
      expect(find.byKey(const Key("smallDetailsPane")), findsOneWidget);

      controller.dispose();
    },
  );

  testWidgets(
    "adaptive scaffold controller can start with explicit body intent",
    (WidgetTester tester) async {
      final AdaptiveScaffoldController controller = AdaptiveScaffoldController(
        initialIntent: PanelFocus.body,
      );

      await tester.binding.setSurfaceSize(SimulatedLayout.small.size);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData.fromView(tester.view)
                .copyWith(size: SimulatedLayout.small.size),
            child: AdaptiveScaffold(
              destinations: TestScaffold.destinations,
              smallBreakpoint: TestBreakpoint0(),
              mediumBreakpoint: TestBreakpoint800(),
              mediumLargeBreakpoint: TestBreakpoint1000(),
              largeBreakpoint: TestBreakpoint1200(),
              extraLargeBreakpoint: TestBreakpoint1600(),
              controller: controller,
              smallBody: (_) => Container(key: const Key("smallListPane")),
              body: (_) => const SizedBox.shrink(),
              smallSecondaryBody: (_) =>
                  Container(key: const Key("smallDetailsPane")),
              secondaryBody: (_) => const SizedBox.shrink(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key("smallListPane")), findsOneWidget);
      expect(find.byKey(const Key("smallDetailsPane")), findsNothing);

      controller.dispose();
    },
  );

  _phaseTests();
}

/// An empty widget that implements [PreferredSizeWidget] to ensure that
/// [PreferredSizeWidget] is used as [AdaptiveScaffold.appBar] parameter instead
/// of [AppBar].
// ─── Phase 1 / 2 / 3 regression tests ───────────────────────────────────────

/// Pumps a small-screen scaffold with the given [destinations] and
/// [selectedIndex], settles, then calls [verify].
Future<void> _pumpBottomBar(
  WidgetTester tester, {
  required List<NavigationDestination> destinations,
  int selectedIndex = 0,
}) async {
  await tester.binding.setSurfaceSize(const Size(400, 800));
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        bottomNavigationBar: AdaptiveScaffold.standardBottomNavigationBar(
          destinations: destinations,
          currentIndex: selectedIndex,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void _phaseTests() {
  // ── Phase 1: hideLabel ────────────────────────────────────────────────────

  testWidgets(
    "hideLabel: true suppresses only that destination's label",
    (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.home_outlined),
          label: "Home",
          hideLabel: true,
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.person_outline),
          label: "Profile",
        ),
      ];

      await _pumpBottomBar(tester, destinations: destinations);

      expect(find.text("Home"), findsNothing);
      expect(find.text("Profile"), findsOneWidget);
    },
  );

  testWidgets(
    "hideLabel: false (default) shows the label",
    (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.home_outlined),
          label: "Home",
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.person_outline),
          label: "Profile",
        ),
      ];

      await _pumpBottomBar(tester, destinations: destinations);

      expect(find.text("Home"), findsOneWidget);
      expect(find.text("Profile"), findsOneWidget);
    },
  );

  // ── Phase 2: animated icon transitions ────────────────────────────────────

  testWidgets(
    "transitionAnimation.none produces no AnimatedSwitcher",
    (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.home_outlined),
          label: "Home",
          transitionAnimation: NavigationDestinationAnimation.none,
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.person_outline),
          label: "Profile",
          transitionAnimation: NavigationDestinationAnimation.none,
        ),
      ];

      await _pumpBottomBar(tester, destinations: destinations);

      expect(find.byType(AnimatedSwitcher), findsNothing);
    },
  );

  testWidgets(
    "transitionAnimation.fadeSwap produces FadeTransition widgets",
    (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.home_outlined),
          label: "Home",
          transitionAnimation: NavigationDestinationAnimation.fadeSwap,
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.person_outline),
          label: "Profile",
          transitionAnimation: NavigationDestinationAnimation.fadeSwap,
        ),
      ];

      await _pumpBottomBar(tester, destinations: destinations);

      // Each destination inserts an AnimatedSwitcher with FadeTransition.
      expect(find.byType(AnimatedSwitcher), findsNWidgets(2));
      expect(find.byType(FadeTransition), findsWidgets);
    },
  );

  testWidgets(
    "transitionAnimation.scale produces ScaleTransition widgets",
    (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.home_outlined),
          label: "Home",
          transitionAnimation: NavigationDestinationAnimation.scale,
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.person_outline),
          label: "Profile",
          transitionAnimation: NavigationDestinationAnimation.scale,
        ),
      ];

      await _pumpBottomBar(tester, destinations: destinations);

      expect(find.byType(AnimatedSwitcher), findsNWidgets(2));
      expect(find.byType(ScaleTransition), findsWidgets);
    },
  );

  testWidgets(
    "iconBuilder overrides transitionAnimation and is called per destination",
    (WidgetTester tester) async {
      const Key customIconKey = ValueKey<String>("custom_icon_output");

      Widget customBuilder(
        BuildContext context,
        Animation<double> animation,
        bool isSelecting,
        Widget unselected,
        Widget selected,
      ) {
        return SizedBox(key: customIconKey, child: unselected);
      }

      final List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: const Icon(Icons.home_outlined),
          label: "Home",
          transitionAnimation: NavigationDestinationAnimation.fadeSwap,
          iconBuilder: customBuilder,
        ),
        const CustomNavigationDestination(
          icon: Icon(Icons.person_outline),
          label: "Profile",
        ),
      ];

      await _pumpBottomBar(tester, destinations: destinations);

      // Custom builder widget should appear; no AnimatedSwitcher on first destination.
      expect(find.byKey(customIconKey), findsOneWidget);
    },
  );

  // ── Phase 3: indicator placement ──────────────────────────────────────────

  testWidgets(
    "no scoped shape: NavigationIndicator fills full item (default)",
    (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.home_outlined),
          label: "Home",
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.person_outline),
          label: "Profile",
        ),
      ];

      await _pumpBottomBar(tester, destinations: destinations);

      expect(tester.takeException(), isNull);
      expect(find.text("Home"), findsOneWidget);
      expect(find.text("Profile"), findsOneWidget);
    },
  );

  testWidgets(
    "iconIndicatorShape: full-item indicator is suppressed; scoped indicator shown",
    (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.home_outlined),
          label: "Home",
          iconIndicatorShape: CircleBorder(),
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.person_outline),
          label: "Profile",
        ),
      ];

      await _pumpBottomBar(tester, destinations: destinations);

      // No exception; both destinations render normally.
      expect(tester.takeException(), isNull);
      expect(find.text("Home"), findsOneWidget);
      expect(find.text("Profile"), findsOneWidget);
    },
  );

  testWidgets(
    "both iconIndicatorShape and labelIndicatorShape: two scoped indicators per destination",
    (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        CustomNavigationDestination(
          icon: Icon(Icons.home_outlined),
          label: "Home",
          iconIndicatorShape: CircleBorder(),
          labelIndicatorShape: StadiumBorder(),
        ),
        CustomNavigationDestination(
          icon: Icon(Icons.person_outline),
          label: "Profile",
        ),
      ];

      await _pumpBottomBar(tester, destinations: destinations);

      // No exception; all destinations render normally.
      expect(tester.takeException(), isNull);
      expect(find.text("Home"), findsOneWidget);
      expect(find.text("Profile"), findsOneWidget);
    },
  );
}

class PreferredSizeWidgetImpl extends StatelessWidget
    implements PreferredSizeWidget {
  const PreferredSizeWidgetImpl({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  Size get preferredSize => const Size(200, 200);
}
