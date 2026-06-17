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
  group("AdaptiveScaffoldDestination", () {
    test("is assignable to List<NavigationDestination>", () {
      final List<NavigationDestination> destinations = [
        AdaptiveScaffoldDestination(title: "Home", icon: Icons.home),
        AdaptiveScaffoldDestination(
          title: "Profile",
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
        ),
        const NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: "Settings",
        ),
      ];
      expect(destinations.length, 3);
      expect(destinations[0], isA<AdaptiveScaffoldDestination>());
      expect(destinations[2], isA<NavigationDestination>());
    });

    test("toRailDestination uses title as label", () {
      final dest = AdaptiveScaffoldDestination(
        title: "Inbox",
        icon: Icons.inbox_outlined,
      );
      final rail = AdaptiveScaffold.toRailDestination(dest);
      final labelText = (rail.labelWidget as Text).data;
      expect(labelText, "Inbox");
    });

    test("toBarDestination uses title as label", () {
      final dest = AdaptiveScaffoldDestination(
        title: "Inbox",
        icon: Icons.inbox_outlined,
      );
      expect(dest.label, "Inbox");
    });

    testWidgets("renders in AdaptiveScaffold without error",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 900)),
            child: AdaptiveScaffold(
              destinations: [
                AdaptiveScaffoldDestination(title: "Home", icon: Icons.home),
                AdaptiveScaffoldDestination(
                  title: "Profile",
                  icon: Icons.person,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
