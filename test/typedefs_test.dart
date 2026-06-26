// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import "package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart";
import "package:flutter/material.dart"
    hide
        NavigationDestination,
        NavigationRail,
        NavigationBar,
        NavigationRailDestination,
        NavigationIndicator,
        NavigationBarTheme,
        NavigationBarThemeData,
        NavigationRailTheme,
        NavigationRailThemeData,
        NavigationDrawerDestination,
        NavigationDrawerTheme,
        NavigationDrawerThemeData;
import "package:flutter_test/flutter_test.dart";

void main() {
  group("Type aliases", () {
    test("CustomAdaptiveScaffold aliases AdaptiveScaffold", () {
      const CustomAdaptiveScaffold scaffold = CustomAdaptiveScaffold(
        destinations: <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.search), label: "Search"),
        ],
      );

      expect(scaffold, isA<AdaptiveScaffold>());
    });

    test("CustomNavigationDestination aliases NavigationDestination", () {
      const CustomNavigationDestination destination =
          CustomNavigationDestination(
        icon: Icon(Icons.home),
        label: "Home",
      );

      expect(destination, isA<NavigationDestination>());
      expect(destination.toBarDestination(), isA<NavigationBarDestination>());
      expect(destination.toRailDestination(), isA<NavigationRailDestination>());
    });

    test("CustomNavigationBarDestination aliases NavigationDestination", () {
      const CustomNavigationBarDestination destination =
          CustomNavigationBarDestination(
        icon: Icon(Icons.home),
        label: "Home",
      );

      expect(destination, isA<NavigationDestination>());
      expect(destination.toBarDestination(), isA<NavigationBarDestination>());
    });

    test("CustomNavigationRailDestination aliases NavigationRailDestination",
        () {
      const CustomNavigationRailDestination destination =
          CustomNavigationRailDestination(
        icon: Icon(Icons.home),
        label: Text("Home"),
      );

      expect(destination, isA<NavigationRailDestination>());
      expect(destination.labelWidget, isA<Text>());
    });

    test("CustomNavigationBar aliases NavigationBar", () {
      final CustomNavigationBar bar = CustomNavigationBar(
        destinations: const <Widget>[
          NavigationBarDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationBarDestination(icon: Icon(Icons.search), label: "Search"),
        ],
      );

      expect(bar, isA<NavigationBar>());
    });

    test("CustomNavigationRail aliases NavigationRail", () {
      final CustomNavigationRail rail = CustomNavigationRail(
        selectedIndex: 0,
        destinations: const <NavigationRailDestination>[
          NavigationRailDestination(
            icon: Icon(Icons.home),
            label: Text("Home"),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.search),
            label: Text("Search"),
          ),
        ],
      );

      expect(rail, isA<NavigationRail>());
    });

    test("CustomNavigationIndicator aliases NavigationIndicator", () {
      const CustomNavigationIndicator indicator = CustomNavigationIndicator(
        animation: AlwaysStoppedAnimation<double>(1),
      );

      expect(indicator, isA<NavigationIndicator>());
    });

    test("CustomNavigationBarThemeData aliases NavigationBarThemeData", () {
      const CustomNavigationBarThemeData data = CustomNavigationBarThemeData(
        height: 80,
      );

      expect(data, isA<NavigationBarThemeData>());
    });

    test("CustomNavigationRailThemeData aliases NavigationRailThemeData", () {
      const CustomNavigationRailThemeData data = CustomNavigationRailThemeData(
        minWidth: 80,
      );

      expect(data, isA<NavigationRailThemeData>());
    });

    testWidgets("CustomNavigationBarTheme aliases NavigationBarTheme",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CustomNavigationBarTheme(
            data: CustomNavigationBarThemeData(height: 90),
            child: SizedBox(),
          ),
        ),
      );

      expect(find.byType(NavigationBarTheme), findsOneWidget);
    });

    testWidgets("CustomNavigationRailTheme aliases NavigationRailTheme",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomNavigationRailTheme(
              data: CustomNavigationRailThemeData(minWidth: 81),
              child: SizedBox(),
            ),
          ),
        ),
      );

      expect(find.byType(NavigationRailTheme), findsOneWidget);
    });

    test("NavigationRailDestinationBuilder typedef matches function signature",
        () {
      NavigationRailDestination builder(
        int index,
        NavigationDestination destination,
      ) {
        return NavigationRailDestination(
          icon: destination.icon,
          label: Text("$index:${destination.label}"),
        );
      }

      final NavigationRailDestination result = builder(
        2,
        const NavigationDestination(icon: Icon(Icons.home), label: "Home"),
      );

      expect(result, isA<NavigationRailDestination>());
      expect((result.labelWidget as Text).data, "2:Home");
    });
  });
}
