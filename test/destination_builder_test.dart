// Characterization tests for the shared destination builder pipeline.
//
// These tests lock behavior that must be preserved across any future
// refactors of the rail/bar destination internals:
//   - Selected icon is resolved from animation status.
//   - Disabled destinations don't fire tap callbacks.
//   - Selected semantics flag is set correctly.
//   - Rail label-type layouts show/hide labels as expected.
//   - BarDestinationStrategy and RailDestinationStrategy produce
//     structurally parity outputs (both resolve a themed icon + styled label).

import "package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart";
import "package:flutter/material.dart"
    hide
        NavigationBar,
        NavigationDestination,
        NavigationRailDestination,
        NavigationRail,
        NavigationRailThemeData;
import "package:flutter_test/flutter_test.dart";

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Pumps a minimal [MaterialApp] wrapping the provided [widget].
Future<void> pumpApp(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: widget),
    ),
  );
}

// ---------------------------------------------------------------------------
// NavigationBar destination — selected / unselected / disabled
// ---------------------------------------------------------------------------

Widget _buildBar({
  required int selectedIndex,
  required VoidCallback? onTap,
  bool firstDisabled = false,
}) {
  return NavigationBar(
    selectedIndex: selectedIndex,
    onDestinationSelected: onTap != null ? (_) => onTap() : null,
    destinations: [
      NavigationBarDestination(
        icon: const Icon(Icons.home),
        selectedIcon: const Icon(Icons.home_filled),
        label: "Home",
        disabled: firstDisabled,
      ),
      const NavigationBarDestination(
        icon: Icon(Icons.search),
        selectedIcon: Icon(Icons.search),
        label: "Search",
      ),
    ],
  );
}

Widget _buildRail({
  required int selectedIndex,
  required VoidCallback? onTap,
  NavigationRailLabelType labelType = NavigationRailLabelType.none,
  bool firstDisabled = false,
}) {
  return NavigationRail(
    selectedIndex: selectedIndex,
    onDestinationSelected: onTap != null ? (_) => onTap() : null,
    labelType: labelType,
    destinations: [
      NavigationRailDestination(
        icon: const Icon(Icons.home),
        selectedIcon: const Icon(Icons.home_filled),
        label: const Text("Home"),
        disabled: firstDisabled,
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.search),
        label: Text("Search"),
      ),
    ],
  );
}

void main() {
  group("NavigationDestination conversion", () {
    testWidgets("toBarDestination forwards tooltip",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationBar(
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: "Home",
              tooltip: "Go Home",
            ),
            NavigationDestination(
              icon: Icon(Icons.search),
              label: "Search",
            ),
          ],
        ),
      );

      final Tooltip tooltip =
          tester.widget<Tooltip>(find.byType(Tooltip).first);
      expect(tooltip.message, "Go Home");
    });

    testWidgets("toRailDestination forwards disabled",
        (WidgetTester tester) async {
      int tapped = 0;
      await pumpApp(
        tester,
        NavigationRail(
          selectedIndex: 1,
          onDestinationSelected: (_) => tapped++,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: "Home",
              disabled: true,
            ),
            NavigationDestination(
              icon: Icon(Icons.search),
              label: "Search",
            ),
          ].map((d) => d.toRailDestination()).toList(),
        ),
      );

      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(tapped, 0);
    });

    testWidgets("bar tooltip falls back to label when tooltip is null",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationBar(
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            NavigationDestination(
              icon: Icon(Icons.search),
              label: "Search",
            ),
          ],
        ),
      );

      final Tooltip tooltip =
          tester.widget<Tooltip>(find.byType(Tooltip).first);
      expect(tooltip.message, "Home");
    });

    testWidgets("bar tooltip is suppressed when tooltip is empty",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationBar(
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: "Home",
              tooltip: "",
            ),
            NavigationDestination(
              icon: Icon(Icons.search),
              label: "Search",
            ),
          ],
        ),
      );

      final Iterable<Tooltip> tooltips =
          tester.widgetList<Tooltip>(find.byType(Tooltip));
      expect(tooltips.length, 1);
      expect(tooltips.first.message, "Search");
    });

    testWidgets("bar tooltip uses themed vertical offset",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            navigationBarTheme: const CustomNavigationBarThemeData(
              tooltipVerticalOffset: 64,
            ),
          ),
          home: Scaffold(
            body: NavigationBar(
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home),
                  label: "Home",
                  tooltip: "Go Home",
                ),
                NavigationDestination(
                  icon: Icon(Icons.search),
                  label: "Search",
                ),
              ],
            ),
          ),
        ),
      );

      final Tooltip tooltip =
          tester.widget<Tooltip>(find.byType(Tooltip).first);
      expect(tooltip.verticalOffset, 64);
    });
  });

  group("NavigationBar parity options", () {
    testWidgets("maintainBottomViewPadding is wired to SafeArea",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationBar(
          maintainBottomViewPadding: true,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: "Home"),
            NavigationDestination(icon: Icon(Icons.search), label: "Search"),
          ],
        ),
      );

      final SafeArea safeArea =
          tester.widget<SafeArea>(find.byType(SafeArea).first);
      expect(safeArea.maintainBottomViewPadding, isTrue);
    });
  });

  group("NavigationBarDestination", () {
    testWidgets("tap fires onDestinationSelected when enabled",
        (WidgetTester tester) async {
      int tapped = 0;
      await pumpApp(
        tester,
        _buildBar(selectedIndex: 1, onTap: () => tapped++),
      );
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(tapped, 1);
    });

    testWidgets("tap does NOT fire callback when destination is disabled",
        (WidgetTester tester) async {
      int tapped = 0;
      await pumpApp(
        tester,
        _buildBar(
          selectedIndex: 1,
          onTap: () => tapped++,
          firstDisabled: true,
        ),
      );
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(tapped, 0);
    });

    testWidgets("selected destination shows selectedIcon",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        _buildBar(selectedIndex: 0, onTap: null),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.home_filled), findsOneWidget);
      expect(find.byIcon(Icons.home), findsNothing);
    });

    testWidgets("unselected destination shows regular icon",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        _buildBar(selectedIndex: 1, onTap: null),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.home_filled), findsNothing);
    });
  });

  group("NavigationRail destination", () {
    testWidgets("tap fires onDestinationSelected when enabled",
        (WidgetTester tester) async {
      int tapped = 0;
      await pumpApp(
        tester,
        _buildRail(selectedIndex: 1, onTap: () => tapped++),
      );
      // The host pre-selects icon; index 0 (home) is not selected, so the
      // plain home icon is shown.
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(tapped, 1);
    });

    testWidgets("tap does NOT fire callback when destination is disabled",
        (WidgetTester tester) async {
      int tapped = 0;
      await pumpApp(
        tester,
        _buildRail(
          selectedIndex: 1,
          onTap: () => tapped++,
          firstDisabled: true,
        ),
      );
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(tapped, 0);
    });

    testWidgets("selected destination has selected semantics",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        _buildRail(selectedIndex: 0, onTap: null),
      );
      await tester.pumpAndSettle();

      // The selected destination wraps its content in a Semantics node with
      // selected: true.  Verify at least one Semantics node in the tree has
      // the selected flag.
      final Iterable<Semantics> semanticsWidgets = tester.widgetList<Semantics>(
        find.byType(Semantics),
      );
      final bool anySelected = semanticsWidgets.any(
        (s) => s.properties.selected == true,
      );
      expect(anySelected, isTrue);
    });

    testWidgets("label is hidden visually for labelType.none (collapsed rail)",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        _buildRail(
          selectedIndex: 0,
          onTap: null,
          labelType: NavigationRailLabelType.none,
        ),
      );
      await tester.pumpAndSettle();

      // In collapsed none mode the label should be maintained for semantics
      // but not visible.
      final Finder homeLabelFinder = find.text("Home");
      expect(homeLabelFinder, findsWidgets);

      // The wrapping Visibility.maintain should have visible: false.
      final Iterable<Visibility> visibilityWidgets =
          tester.widgetList<Visibility>(
        find.ancestor(
          of: homeLabelFinder.first,
          matching: find.byType(Visibility),
        ),
      );
      expect(visibilityWidgets, isNotEmpty);
      expect(visibilityWidgets.first.visible, isFalse);
    });

    testWidgets("label IS visible for labelType.all",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        _buildRail(
          selectedIndex: 0,
          onTap: null,
          labelType: NavigationRailLabelType.all,
        ),
      );
      await tester.pumpAndSettle();

      final Finder searchLabel = find.text("Search");
      expect(searchLabel, findsOneWidget);

      // No Visibility.maintain(visible: false) wrapper around the label.
      final Iterable<Visibility> visibilityWidgets =
          tester.widgetList<Visibility>(
        find.ancestor(
          of: searchLabel,
          matching: find.byType(Visibility),
        ),
      );
      for (final v in visibilityWidgets) {
        expect(v.visible, isTrue);
      }
    });
  });

  // -------------------------------------------------------------------------
  // Parity: disabled suppresses tap in BOTH surfaces
  // -------------------------------------------------------------------------

  group("Destination parity", () {
    testWidgets("disabled state suppresses tap in both bar and rail",
        (WidgetTester tester) async {
      int barTaps = 0;
      int railTaps = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: NavigationBar(
              selectedIndex: 1,
              onDestinationSelected: (_) => barTaps++,
              destinations: const [
                NavigationBarDestination(
                  icon: Icon(Icons.home, key: Key("bar_home")),
                  label: "Home",
                  disabled: true,
                ),
                NavigationBarDestination(
                  icon: Icon(Icons.search),
                  label: "Search",
                ),
              ],
            ),
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: 1,
                  onDestinationSelected: (_) => railTaps++,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home, key: Key("rail_home")),
                      label: Text("Home"),
                      disabled: true,
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.search),
                      label: Text("Search"),
                    ),
                  ],
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("bar_home")));
      await tester.tap(find.byKey(const Key("rail_home")));
      await tester.pumpAndSettle();

      expect(barTaps, 0, reason: "bar disabled destination must not fire");
      expect(railTaps, 0, reason: "rail disabled destination must not fire");
    });
  });
}
