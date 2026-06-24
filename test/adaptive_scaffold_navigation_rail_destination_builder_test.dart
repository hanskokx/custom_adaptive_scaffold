import "package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart";
import "package:flutter/material.dart"
    hide
        NavigationBar,
        NavigationBarTheme,
        NavigationDestination,
        NavigationRailDestination,
        NavigationRail,
        NavigationRailThemeData;
import "package:flutter_test/flutter_test.dart";

void main() {
  group("navigationRailDestinationBuilder index accuracy", () {
    testWidgets(
      "builder receives positional index even with duplicate destinations",
      (WidgetTester tester) async {
        final List<int> capturedIndexes = [];
        const NavigationDestination dest = NavigationDestination(
          icon: Icon(Icons.star),
          label: "Star",
        );

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(800, 900)),
              child: AdaptiveScaffold(
                destinations: const [dest, dest, dest],
                selectedIndex: 0,
                navigationRailDestinationBuilder: (index, destination) {
                  capturedIndexes.add(index);
                  return AdaptiveScaffold.toRailDestination(destination);
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(capturedIndexes, containsAllInOrder([0, 1, 2]));
      },
    );

    testWidgets(
      "builder is called for large breakpoint destinations",
      (WidgetTester tester) async {
        int builderCallCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(1400, 900)),
              child: AdaptiveScaffold(
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home),
                    label: "Home",
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person),
                    label: "Profile",
                  ),
                ],
                selectedIndex: 0,
                navigationRailDestinationBuilder: (index, destination) {
                  builderCallCount++;
                  return AdaptiveScaffold.toRailDestination(destination);
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          builderCallCount,
          greaterThan(0),
          reason: "navigationRailDestinationBuilder must be called at large "
              "breakpoints, not bypassed",
        );
      },
    );
  });
}
