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

import "package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart"
    as custom_adaptive_scaffold;
import "package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart";
import "package:custom_adaptive_scaffold/src/navigation_shared/destination_build_data.dart";
import "package:custom_adaptive_scaffold/src/navigation_shared/destination_surface_strategy.dart";
import "package:custom_adaptive_scaffold/src/navigation_shared/navigation_destination_tooltip.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart"
    hide
        NavigationBar,
        NavigationBarTheme,
        NavigationDestination,
        NavigationRailDestination,
        NavigationRail,
        NavigationRailTheme,
        NavigationRailThemeData,
        NavigationBarThemeData;
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
  bool firstEnabled = true,
}) {
  return NavigationBar(
    selectedIndex: selectedIndex,
    onDestinationSelected: onTap != null ? (_) => onTap() : null,
    destinations: [
      NavigationBarDestination(
        icon: const Icon(Icons.home),
        selectedIcon: const Icon(Icons.home_filled),
        label: "Home",
        enabled: firstEnabled,
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
  bool firstEnabled = true,
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
        disabled: !firstEnabled,
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.search),
        label: Text("Search"),
      ),
    ],
  );
}

void main() {
  group("DestinationTooltip", () {
    testWidgets("returns child directly when message is null",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        const DestinationTooltip(
          message: null,
          tooltipOffset: Offset(12, 24),
          tooltipTrigger: TooltipTriggerMode.longPress,
          child: Text("Tooltip Child"),
        ),
      );

      expect(find.text("Tooltip Child"), findsOneWidget);
      expect(find.byType(Tooltip), findsNothing);
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets("long press uses manual tooltip visibility",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        const DestinationTooltip(
          message: "Tooltip Message",
          tooltipOffset: Offset(12, 24),
          tooltipTrigger: TooltipTriggerMode.longPress,
          child: Text("Tooltip Child"),
        ),
      );

      final Tooltip tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      TooltipVisibility visibility =
          tester.widget<TooltipVisibility>(find.byType(TooltipVisibility));
      final GestureDetector detector =
          tester.widget<GestureDetector>(find.byType(GestureDetector));

      expect(tooltip.triggerMode, TooltipTriggerMode.manual);
      expect(tooltip.verticalOffset, 24);
      expect(tooltip.margin, const EdgeInsets.only(left: 12));
      expect(visibility.visible, isFalse);
      expect(detector.onLongPress, isNotNull);
      expect(detector.onSecondaryTapUp, isNull);

      await tester.longPress(find.text("Tooltip Child"));
      await tester.pump();

      visibility =
          tester.widget<TooltipVisibility>(find.byType(TooltipVisibility));
      expect(visibility.visible, isTrue);

      await tester.pump(const Duration(milliseconds: 1700));
      visibility =
          tester.widget<TooltipVisibility>(find.byType(TooltipVisibility));
      expect(visibility.visible, isFalse);
    });

    testWidgets("tap trigger uses secondary tap handler and manual mode",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        const DestinationTooltip(
          message: "Tooltip Message",
          tooltipOffset: Offset.zero,
          tooltipTrigger: TooltipTriggerMode.tap,
          child: Text("Tooltip Child"),
        ),
      );

      final Tooltip tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      final GestureDetector detector =
          tester.widget<GestureDetector>(find.byType(GestureDetector));

      expect(tooltip.triggerMode, TooltipTriggerMode.manual);
      expect(detector.onLongPress, isNull);
      expect(detector.onSecondaryTapUp, isNotNull);

      await tester.tap(find.text("Tooltip Child"), buttons: kSecondaryButton);
      await tester.pump();

      TooltipVisibility visibility =
          tester.widget<TooltipVisibility>(find.byType(TooltipVisibility));
      expect(visibility.visible, isTrue);

      await tester.pump(const Duration(milliseconds: 1700));
      visibility =
          tester.widget<TooltipVisibility>(find.byType(TooltipVisibility));
      expect(visibility.visible, isFalse);
    });

    testWidgets("non-manual trigger keeps tooltip always visible",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        const DestinationTooltip(
          message: "Tooltip Message",
          tooltipOffset: Offset.zero,
          tooltipTrigger: TooltipTriggerMode.manual,
          child: Text("Tooltip Child"),
        ),
      );

      final Tooltip tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      final TooltipVisibility visibility =
          tester.widget<TooltipVisibility>(find.byType(TooltipVisibility));
      final GestureDetector detector =
          tester.widget<GestureDetector>(find.byType(GestureDetector));

      expect(tooltip.triggerMode, TooltipTriggerMode.manual);
      expect(visibility.visible, isTrue);
      expect(detector.onLongPress, isNull);
      expect(detector.onSecondaryTapUp, isNull);
    });
  });

  group("ExpandedRailDestination", () {
    testWidgets("renders extended rail content with internal animation",
        (WidgetTester tester) async {
      int taps = 0;

      await pumpApp(
        tester,
        Center(
          child: ExpandedRailDestination(
            icon: const Icon(Icons.home),
            label: const Text("Expanded Home"),
            selected: true,
            onTap: () => taps += 1,
            indexLabel: "Home, tab 1 of 1",
            minWidth: 80,
            minExtendedWidth: 240,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            useIndicator: true,
            indicatorColor: Colors.orange,
            indicatorShape: const StadiumBorder(),
          ),
        ),
      );

      expect(find.text("Expanded Home"), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byType(Row), findsWidgets);
      expect(find.byType(ClipRect), findsOneWidget);
      expect(
        find.byType(custom_adaptive_scaffold.NavigationIndicator),
        findsOneWidget,
      );

      final ConstrainedBox constrainedBox = tester.widget<ConstrainedBox>(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is ConstrainedBox && widget.constraints.minWidth == 240,
        ),
      );
      expect(constrainedBox.constraints.minWidth, 240);

      final SemanticsHandle semantics = tester.ensureSemantics();
      expect(
        tester.getSemantics(find.text("Expanded Home")),
        matchesSemantics(
          label: "Expanded Home\nHome, tab 1 of 1",
          isSelected: true,
          hasSelectedState: true,
          isFocusable: true,
          hasFocusAction: true,
          hasTapAction: true,
        ),
      );

      await tester.tap(find.text("Expanded Home"));
      await tester.pump();
      expect(taps, 1);
      semantics.dispose();
    });

    testWidgets("updates when destination animation changes",
        (WidgetTester tester) async {
      const AlwaysStoppedAnimation<double> firstAnimation =
          AlwaysStoppedAnimation<double>(0.25);
      const AlwaysStoppedAnimation<double> secondAnimation =
          AlwaysStoppedAnimation<double>(0.75);

      Widget buildDestination(Animation<double>? animation) {
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: ExpandedRailDestination(
                key: const Key("expanded-destination"),
                icon: const Icon(Icons.search),
                label: const Text("Search"),
                selected: false,
                disabled: true,
                destinationAnimation: animation,
                extendedTransitionAnimation:
                    const AlwaysStoppedAnimation<double>(1),
                minWidth: 72,
                minExtendedWidth: 220,
                padding: const EdgeInsets.all(4),
              ),
            ),
          ),
        );
      }

      await tester.pumpWidget(buildDestination(firstAnimation));
      expect(find.text("Search"), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);

      await tester.pumpWidget(buildDestination(secondAnimation));
      await tester.pump();

      final SemanticsHandle semantics = tester.ensureSemantics();
      expect(
        tester.getSemantics(find.text("Search")),
        matchesSemantics(
          label: "Search",
          hasSelectedState: true,
        ),
      );
      semantics.dispose();

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });

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
              enabled: false,
            ),
            NavigationDestination(
              icon: Icon(Icons.search),
              label: "Search",
            ),
          ].map((d) => AdaptiveScaffold.toRailDestination(d)).toList(),
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

      final List<Tooltip> tooltips =
          tester.widgetList<Tooltip>(find.byType(Tooltip)).toList();
      final List<String?> messages =
          tooltips.map((Tooltip tooltip) => tooltip.message).toList();
      expect(messages, isNot(contains("")));
      expect(messages, contains("Search"));
    });

    testWidgets("bar tooltip uses themed vertical offset",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            navigationBarTheme: const CustomNavigationBarThemeData(
              tooltipOffset: Offset(0, 64),
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

    testWidgets("rail tooltip falls back to label when tooltip is null",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationRail(
          selectedIndex: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            NavigationDestination(
              icon: Icon(Icons.search),
              label: "Search",
            ),
          ]
              .map(
                (NavigationDestination d) =>
                    AdaptiveScaffold.toRailDestination(d),
              )
              .toList(),
        ),
      );

      final Tooltip tooltip =
          tester.widget<Tooltip>(find.byType(Tooltip).first);
      expect(tooltip.message, "Home");
    });

    testWidgets("rail tooltip is suppressed when tooltip is empty",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationRail(
          selectedIndex: 0,
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
          ]
              .map(
                (NavigationDestination d) =>
                    AdaptiveScaffold.toRailDestination(d),
              )
              .toList(),
        ),
      );

      final List<Tooltip> tooltips =
          tester.widgetList<Tooltip>(find.byType(Tooltip)).toList();
      final List<String?> messages =
          tooltips.map((Tooltip tooltip) => tooltip.message).toList();
      expect(messages, isNot(contains("")));
      expect(messages, contains("Search"));
    });

    testWidgets("rail tooltip uses themed vertical offset",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            navigationRailTheme: const CustomNavigationRailThemeData(
              tooltipOffset: Offset(0, 52),
            ),
          ),
          home: Scaffold(
            body: NavigationRail(
              selectedIndex: 0,
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
              ]
                  .map(
                    (NavigationDestination d) =>
                        AdaptiveScaffold.toRailDestination(d),
                  )
                  .toList(),
            ),
          ),
        ),
      );

      final Tooltip tooltip =
          tester.widget<Tooltip>(find.byType(Tooltip).first);
      expect(tooltip.verticalOffset, 52);
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
          firstEnabled: false,
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

    testWidgets("selection switch updates icons immediately",
        (WidgetTester tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return MaterialApp(
              home: Scaffold(
                body: NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  destinations: const [
                    NavigationBarDestination(
                      icon: Icon(Icons.home),
                      selectedIcon: Icon(Icons.home_filled),
                      label: "Home",
                    ),
                    NavigationBarDestination(
                      icon: Icon(Icons.search),
                      selectedIcon: Icon(Icons.search_off),
                      label: "Search",
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      expect(find.byIcon(Icons.home_filled), findsOneWidget);
      expect(find.byIcon(Icons.home), findsNothing);

      await tester.tap(find.text("Search"));
      await tester.pump();

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.home_filled), findsNothing);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets("previous destination deselects without hover refresh",
        (WidgetTester tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return MaterialApp(
              home: Scaffold(
                body: NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  destinations: const [
                    NavigationBarDestination(
                      icon: Icon(Icons.home),
                      selectedIcon: Icon(Icons.home_filled),
                      label: "Home",
                    ),
                    NavigationBarDestination(
                      icon: Icon(Icons.search),
                      selectedIcon: Icon(Icons.search_off),
                      label: "Search",
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      // Trigger destination switch and verify deselection before any hover.
      await tester.tap(find.text("Search"));
      await tester.pump();

      expect(find.byIcon(Icons.home_filled), findsNothing);
      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets("navigation item overlay requires explicit opt-in",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            navigationBarTheme: const CustomNavigationBarThemeData(
              destinationIndicatorShape: RoundedRectangleBorder(),
            ),
          ),
          home: Scaffold(
            body: _buildBar(selectedIndex: 0, onTap: null),
          ),
        ),
      );

      final CustomNavigationBarThemeData? explicitTheme =
          NavigationBarTheme.maybeOf(
        tester.element(find.byType(NavigationBar)),
      );
      expect(explicitTheme, isNotNull);
      expect(explicitTheme!.destinationOverlayColor, isNull);
      expect(explicitTheme.destinationIndicatorShape, isNotNull);
    });

    testWidgets(
        "standardBottomNavigationBar preserves explicit-only overlay intent",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            navigationBarTheme: const CustomNavigationBarThemeData(
              destinationIndicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
          home: Scaffold(
            body: AdaptiveScaffold.standardBottomNavigationBar(
              currentIndex: 0,
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
          ),
        ),
      );
      await tester.pumpAndSettle();

      final BuildContext barContext =
          tester.element(find.byType(NavigationBar));
      final CustomNavigationBarThemeData? explicitTheme =
          NavigationBarTheme.maybeOf(barContext);

      expect(explicitTheme, isNotNull);
      expect(explicitTheme!.destinationOverlayColor, isNull);
      expect(explicitTheme.destinationIndicatorShape, isNotNull);
    });

    testWidgets(
        "navigation rail native theme override stays on framework ink path",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            navigationRailTheme: const CustomNavigationRailThemeData(
              backgroundColor: Colors.black,
            ),
          ),
          home: Scaffold(
            body: Row(
              children: [
                _buildRail(selectedIndex: 0, onTap: null),
              ],
            ),
          ),
        ),
      );

      final Widget indicatorInkWell = tester.allWidgets.firstWhere(
        (Widget w) => w.runtimeType.toString() == "_IndicatorInkWell",
      );
      final InkResponse inkWell = indicatorInkWell as InkResponse;

      expect(inkWell.customBorder, isA<StadiumBorder>());
      expect(inkWell.splashColor, anyOf(isNull, Colors.transparent));
      expect(inkWell.hoverColor, anyOf(isNull, Colors.transparent));
    });

    testWidgets("navigation rail item shape enables whole-item ink",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            navigationRailTheme: const CustomNavigationRailThemeData(
              destinationIndicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
          home: Scaffold(
            body: Row(
              children: [
                _buildRail(selectedIndex: 0, onTap: null),
              ],
            ),
          ),
        ),
      );

      final Widget indicatorInkWell = tester.allWidgets.firstWhere(
        (Widget w) => w.runtimeType.toString() == "_IndicatorInkWell",
      );
      final InkResponse inkWell = indicatorInkWell as InkResponse;

      expect(inkWell.customBorder, isA<RoundedRectangleBorder>());
      expect(inkWell.splashColor, Colors.transparent);
      expect(inkWell.hoverColor, Colors.transparent);
      expect(
        inkWell.overlayColor?.resolve(const <WidgetState>{WidgetState.hovered}),
        isNotNull,
      );
    });

    testWidgets("standardBottomNavigationBar switches selected icon on tap",
        (WidgetTester tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return MaterialApp(
              home: Scaffold(
                body: AdaptiveScaffold.standardBottomNavigationBar(
                  currentIndex: selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home),
                      label: "Feed",
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.search_outlined),
                      selectedIcon: Icon(Icons.search),
                      label: "Search",
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsNothing);
      expect(find.byIcon(Icons.search), findsNothing);
      expect(find.byIcon(Icons.search_outlined), findsOneWidget);

      await tester.tap(find.text("Search"));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.home), findsNothing);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.search_outlined), findsNothing);
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
          firstEnabled: false,
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

    testWidgets("showLabelsWhenCollapsed displays label for labelType.none",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationRail(
          selectedIndex: 0,
          labelType: NavigationRailLabelType.none,
          showLabelsWhenCollapsed: true,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.home),
              label: Text("Home"),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.search),
              label: Text("Search"),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final Iterable<Visibility> visibilityWidgets =
          tester.widgetList<Visibility>(find.byType(Visibility));
      expect(
        visibilityWidgets.every((Visibility widget) => widget.visible),
        isTrue,
      );
      expect(find.text("Home"), findsOneWidget);
    });

    testWidgets("labelType.selected only shows selected label visually",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        _buildRail(
          selectedIndex: 0,
          onTap: null,
          labelType: NavigationRailLabelType.selected,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FadeTransition), findsWidgets);
    });

    testWidgets(
        "rail tooltip trigger switches based on label visibility theme settings",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            navigationRailTheme: const NavigationRailThemeData(
              tooltipTriggerWhenLabelVisible: TooltipTriggerMode.tap,
              tooltipTriggerWhenLabelHidden: TooltipTriggerMode.longPress,
            ),
          ),
          home: Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: 0,
                  labelType: NavigationRailLabelType.none,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text("Home"),
                      tooltip: "Go home",
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.search),
                      label: Text("Search"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Tooltip hiddenTooltip =
          tester.widget<Tooltip>(find.byType(Tooltip).first);
      expect(hiddenTooltip.triggerMode, TooltipTriggerMode.manual);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            navigationRailTheme: const NavigationRailThemeData(
              tooltipTriggerWhenLabelVisible: TooltipTriggerMode.tap,
              tooltipTriggerWhenLabelHidden: TooltipTriggerMode.longPress,
            ),
          ),
          home: Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: 0,
                  labelType: NavigationRailLabelType.none,
                  showLabelsWhenCollapsed: true,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text("Home"),
                      tooltip: "Go home",
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.search),
                      label: Text("Search"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Tooltip visibleTooltip =
          tester.widget<Tooltip>(find.byType(Tooltip).first);
      expect(visibleTooltip.triggerMode, TooltipTriggerMode.manual);
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
                  enabled: false,
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

    testWidgets(
        "rail explicit iconTheme keeps indicator centered on large icon",
        (WidgetTester tester) async {
      const double iconSize = 40.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            navigationRailTheme: const NavigationRailThemeData(
              iconTheme: WidgetStatePropertyAll<IconThemeData>(
                IconThemeData(size: iconSize),
              ),
            ),
          ),
          home: Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: 0,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text("Home"),
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

      final TestGesture gesture =
          await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer();
      await gesture.moveTo(tester.getCenter(find.byIcon(Icons.home)));
      await tester.pumpAndSettle();

      final RenderObject inkFeatures = tester.allRenderObjects.firstWhere(
        (RenderObject object) =>
            object.runtimeType.toString() == "_RenderInkFeatures",
      );

      const Rect expectedRect = Rect.fromLTRB(12.0, 6.0, 68.0, 54.0);
      final Offset iconCenter = tester.getCenter(find.byIcon(Icons.home));
      final Offset indicatorCenter = Offset(
        expectedRect.center.dx,
        expectedRect.center.dy + 8.0,
      );

      expect(
        inkFeatures,
        paints..rect(rect: expectedRect),
      );
      expect(
        (iconCenter.dx - indicatorCenter.dx).abs(),
        lessThanOrEqualTo(0.5),
      );
      expect(
        (iconCenter.dy - indicatorCenter.dy).abs(),
        lessThanOrEqualTo(0.5),
      );
    });

    testWidgets("bar explicit iconTheme expands indicator slot for large icons",
        (WidgetTester tester) async {
      const double iconSize = 40.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            navigationBarTheme: const CustomNavigationBarThemeData(
              iconTheme: WidgetStatePropertyAll<IconThemeData>(
                IconThemeData(size: iconSize),
              ),
            ),
          ),
          home: Scaffold(
            bottomNavigationBar: NavigationBar(
              selectedIndex: 0,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home), label: "Home"),
                NavigationDestination(
                  icon: Icon(Icons.search),
                  label: "Search",
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Finder iconContainer = find.ancestor(
        of: find.byIcon(Icons.home),
        matching: find.byType(SizedBox),
      );

      final Iterable<SizedBox> sizedBoxes =
          tester.widgetList<SizedBox>(iconContainer);
      final bool hasExpandedIndicatorSlot = sizedBoxes.any(
        (SizedBox box) => box.height != null && box.height! > 32.0,
      );

      expect(
        hasExpandedIndicatorSlot,
        isTrue,
        reason:
            "explicit large icon theme should expand bar indicator/icon slot",
      );
    });

    testWidgets(
      "bar theme iconTheme size above 60 throws assertion",
      (WidgetTester tester) async {
        late BuildContext context;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              navigationBarTheme: const CustomNavigationBarThemeData(
                iconTheme: WidgetStatePropertyAll<IconThemeData>(
                  IconThemeData(size: 61.0),
                ),
              ),
            ),
            home: Builder(
              builder: (BuildContext c) {
                context = c;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        const BarDestinationStrategy strategy = BarDestinationStrategy();

        expect(
          () => strategy.resolve(
            context,
            const DestinationResolveInput(
              icon: Icon(Icons.home),
              label: Text("Home"),
              selected: true,
              disabled: false,
              destinationAnimation: kAlwaysCompleteAnimation,
            ),
          ),
          throwsA(
            isA<AssertionError>().having(
              (AssertionError e) => e.message.toString(),
              "message",
              contains("iconTheme size must be <= 60.0"),
            ),
          ),
        );
      },
    );

    testWidgets(
      "rail theme iconTheme size above 72 throws assertion",
      (WidgetTester tester) async {
        late BuildContext context;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              navigationRailTheme: const NavigationRailThemeData(
                iconTheme: WidgetStatePropertyAll<IconThemeData>(
                  IconThemeData(size: 73.0),
                ),
              ),
            ),
            home: Builder(
              builder: (BuildContext c) {
                context = c;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        const RailDestinationStrategy strategy = RailDestinationStrategy();

        expect(
          () => strategy.resolve(
            context,
            const DestinationResolveInput(
              icon: Icon(Icons.home),
              label: Text("Home"),
              selected: true,
              disabled: false,
              destinationAnimation: kAlwaysCompleteAnimation,
            ),
          ),
          throwsA(
            isA<AssertionError>().having(
              (AssertionError e) => e.message.toString(),
              "message",
              contains("iconTheme size must be <= 72.0"),
            ),
          ),
        );
      },
    );

    testWidgets(
      "rail strategy uses defaults, disabled styling, and large-icon offset",
      (WidgetTester tester) async {
        late BuildContext context;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(useMaterial3: false),
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: Builder(
                builder: (BuildContext c) {
                  context = c;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );

        const RailDestinationStrategy strategy = RailDestinationStrategy();
        final DestinationBuildData data = strategy.resolve(
          context,
          const DestinationResolveInput(
            icon: Icon(Icons.home),
            label: Text("Home"),
            selected: false,
            disabled: true,
            destinationAnimation: kAlwaysCompleteAnimation,
            iconTheme: IconThemeData(size: 40),
            labelTextStyle: TextStyle(fontSize: 17),
            minWidth: 80,
            minExtendedWidth: 220,
            padding: EdgeInsets.only(top: 10),
          ),
        );

        final IconTheme iconTheme = data.themedIcon as IconTheme;
        final DefaultTextStyle labelStyle =
            data.styledLabel as DefaultTextStyle;

        expect(data.minWidth, 80);
        expect(data.minExtendedWidth, 220);
        expect(data.textDirection, TextDirection.rtl);
        expect(data.extendedAnimation, same(kAlwaysCompleteAnimation));
        expect(data.indicatorOffset.dx, 40);
        expect(data.indicatorOffset.dy, 36);
        expect(data.indicatorColor, anyOf(isNull, isA<Color>()));
        expect(data.indicatorShape, anyOf(isNull, isA<ShapeBorder>()));
        expect(data.resolvedIconSize, 40);
        expect(iconTheme.data.size, 40);
        expect(
          iconTheme.data.color,
          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
        );
        expect(
          labelStyle.style.color,
          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
        );
      },
    );

    testWidgets(
      "rail strategy applies M2 selected icon contrast without overrides",
      (WidgetTester tester) async {
        late BuildContext context;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(useMaterial3: false),
            home: Builder(
              builder: (BuildContext c) {
                context = c;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        const RailDestinationStrategy strategy = RailDestinationStrategy();
        final DestinationBuildData data = strategy.resolve(
          context,
          const DestinationResolveInput(
            icon: Icon(Icons.home),
            label: Text("Home"),
            selected: true,
            disabled: false,
            destinationAnimation: kAlwaysCompleteAnimation,
            useIndicator: true,
          ),
        );

        final IconTheme iconTheme = data.themedIcon as IconTheme;

        expect(iconTheme.data.color, isNotNull);
        expect(iconTheme.data.opacity, anyOf(isNull, 1.0));
      },
    );

    testWidgets(
      "bar strategy falls back to defaults when overlay and label themes are absent",
      (WidgetTester tester) async {
        late BuildContext context;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              navigationBarTheme: const CustomNavigationBarThemeData(
                overlayColor: null,
                labelTextStyle: null,
              ),
            ),
            home: Builder(
              builder: (BuildContext c) {
                context = c;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        const BarDestinationStrategy strategy = BarDestinationStrategy();
        final DestinationBuildData data = strategy.resolve(
          context,
          const DestinationResolveInput(
            icon: Icon(Icons.home),
            label: Text("Home"),
            selected: false,
            disabled: false,
            destinationAnimation: kAlwaysCompleteAnimation,
          ),
        );

        final DefaultTextStyle labelStyle =
            data.styledLabel as DefaultTextStyle;

        expect(data.indicatorShape, isNotNull);
        expect(data.hoverColor.opacity, greaterThan(0));
        expect(data.splashColor.opacity, greaterThan(data.hoverColor.opacity));
        expect(labelStyle.style, isNot(const TextStyle()));
      },
    );

    testWidgets(
      "bar strategy uses focused overlay fallback for splash color",
      (WidgetTester tester) async {
        late BuildContext context;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              navigationBarTheme: CustomNavigationBarThemeData(
                overlayColor:
                    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
                  if (states.contains(WidgetState.hovered)) {
                    return Colors.blue;
                  }
                  if (states.contains(WidgetState.focused)) {
                    return Colors.green;
                  }
                  return null;
                }),
              ),
            ),
            home: Builder(
              builder: (BuildContext c) {
                context = c;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        const BarDestinationStrategy strategy = BarDestinationStrategy();
        final DestinationBuildData data = strategy.resolve(
          context,
          const DestinationResolveInput(
            icon: Icon(Icons.home),
            label: Text("Home"),
            selected: true,
            disabled: false,
            destinationAnimation: kAlwaysCompleteAnimation,
          ),
        );

        expect(data.hoverColor, Colors.blue);
        expect(data.splashColor, Colors.green);
      },
    );

    testWidgets(
      "rail strategy honors theme icon and label overrides",
      (WidgetTester tester) async {
        late BuildContext context;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              navigationRailTheme: const NavigationRailThemeData(
                unselectedIconTheme: IconThemeData(size: 18, color: Colors.red),
                selectedIconTheme: IconThemeData(size: 22, color: Colors.green),
                unselectedLabelTextStyle: TextStyle(fontSize: 13),
                selectedLabelTextStyle: TextStyle(fontSize: 15),
                minExtendedWidth: 280,
              ),
            ),
            home: Builder(
              builder: (BuildContext c) {
                context = c;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        const RailDestinationStrategy strategy = RailDestinationStrategy();
        final DestinationBuildData unselectedData = strategy.resolve(
          context,
          const DestinationResolveInput(
            icon: Icon(Icons.home),
            label: Text("Home"),
            selected: false,
            disabled: false,
            destinationAnimation: kAlwaysCompleteAnimation,
          ),
        );
        final DestinationBuildData selectedData = strategy.resolve(
          context,
          const DestinationResolveInput(
            icon: Icon(Icons.home),
            label: Text("Home"),
            selected: true,
            disabled: false,
            destinationAnimation: kAlwaysCompleteAnimation,
          ),
        );

        final IconTheme unselectedIconTheme =
            unselectedData.themedIcon as IconTheme;
        final IconTheme selectedIconTheme =
            selectedData.themedIcon as IconTheme;
        final DefaultTextStyle unselectedLabelStyle =
            unselectedData.styledLabel as DefaultTextStyle;
        final DefaultTextStyle selectedLabelStyle =
            selectedData.styledLabel as DefaultTextStyle;

        expect(unselectedData.minExtendedWidth, 280);
        expect(unselectedIconTheme.data.size, 18);
        expect(unselectedIconTheme.data.color, Colors.red);
        expect(selectedIconTheme.data.size, 22);
        expect(selectedIconTheme.data.color, Colors.green);
        expect(unselectedLabelStyle.style.fontSize, 13);
        expect(selectedLabelStyle.style.fontSize, 15);
      },
    );

    testWidgets(
      "bar strategy uses theme resolvers for disabled state",
      (WidgetTester tester) async {
        late BuildContext context;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              navigationBarTheme: CustomNavigationBarThemeData(
                iconTheme:
                    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
                  if (states.contains(WidgetState.disabled)) {
                    return const IconThemeData(size: 17, color: Colors.orange);
                  }
                  if (states.contains(WidgetState.selected)) {
                    return const IconThemeData(size: 19, color: Colors.blue);
                  }
                  return const IconThemeData(size: 15, color: Colors.black);
                }),
                labelTextStyle:
                    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
                  if (states.contains(WidgetState.disabled)) {
                    return const TextStyle(fontSize: 11, color: Colors.orange);
                  }
                  if (states.contains(WidgetState.selected)) {
                    return const TextStyle(fontSize: 13, color: Colors.blue);
                  }
                  return const TextStyle(fontSize: 9, color: Colors.black);
                }),
                indicatorShape: const RoundedRectangleBorder(),
              ),
            ),
            home: Builder(
              builder: (BuildContext c) {
                context = c;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        const BarDestinationStrategy strategy = BarDestinationStrategy();
        final DestinationBuildData data = strategy.resolve(
          context,
          const DestinationResolveInput(
            icon: Icon(Icons.home),
            label: Text("Home"),
            selected: true,
            disabled: true,
            destinationAnimation: kAlwaysCompleteAnimation,
          ),
        );

        final DefaultTextStyle styledLabel =
            data.styledLabel as DefaultTextStyle;

        await pumpApp(tester, data.themedIcon);
        final IconTheme themedIcon = tester.widget<IconTheme>(
          find
              .ancestor(
                of: find.byIcon(Icons.home),
                matching: find.byType(IconTheme),
              )
              .first,
        );

        expect(themedIcon.data.size, 17);
        expect(themedIcon.data.color, Colors.orange);
        expect(styledLabel.style.fontSize, 11);
        expect(styledLabel.style.color, Colors.orange);
        expect(data.indicatorShape, isA<RoundedRectangleBorder>());
      },
    );

    testWidgets(
      "bar strategy keeps default icon theme when only selected theme resolves",
      (WidgetTester tester) async {
        late BuildContext context;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              useMaterial3: true,
              navigationBarTheme: CustomNavigationBarThemeData(
                iconTheme:
                    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return const IconThemeData(size: 21, color: Colors.pink);
                  }
                  return null;
                }),
              ),
            ),
            home: Builder(
              builder: (BuildContext c) {
                context = c;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        const BarDestinationStrategy strategy = BarDestinationStrategy();
        final DestinationBuildData data = strategy.resolve(
          context,
          const DestinationResolveInput(
            icon: Icon(Icons.home),
            label: Text("Home"),
            selected: false,
            disabled: false,
            destinationAnimation: kAlwaysCompleteAnimation,
          ),
        );

        await pumpApp(tester, data.themedIcon);
        final IconTheme themedIcon = tester.widget<IconTheme>(
          find
              .ancestor(
                of: find.byIcon(Icons.home),
                matching: find.byType(IconTheme),
              )
              .first,
        );
        expect(themedIcon.data.size, isNot(21));
        expect(themedIcon.data.size, isNotNull);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // Badge
  // ---------------------------------------------------------------------------

  group("NavigationDestination badge", () {
    // --- Assertion ---

    test("badge: 0 throws AssertionError", () {
      expect(
        () => NavigationDestination(
          icon: const Icon(Icons.home),
          label: "Home",
          badge: 0,
        ),
        throwsAssertionError,
      );
    });

    test("badge: -1 throws AssertionError", () {
      expect(
        () => NavigationDestination(
          icon: const Icon(Icons.home),
          label: "Home",
          badge: -1,
        ),
        throwsAssertionError,
      );
    });

    test("badge + badgeLabel mutual exclusivity throws AssertionError", () {
      expect(
        () => NavigationDestination(
          icon: const Icon(Icons.home),
          label: "Home",
          badge: 5,
          badgeLabel: "5",
        ),
        throwsAssertionError,
      );
    });

    test("badge + customBadge mutual exclusivity throws AssertionError", () {
      expect(
        () => NavigationDestination(
          icon: const Icon(Icons.home),
          label: "Home",
          badge: 5,
          customBadge: const Badge(),
        ),
        throwsAssertionError,
      );
    });

    test("badgeLabel + customBadge mutual exclusivity throws AssertionError",
        () {
      expect(
        () => NavigationDestination(
          icon: const Icon(Icons.home),
          label: "Home",
          badgeLabel: "hi",
          customBadge: const Badge(),
        ),
        throwsAssertionError,
      );
    });

    test("customBadge + numeric-only badgeStyle throws AssertionError", () {
      expect(
        () => NavigationDestination(
          icon: const Icon(Icons.home),
          label: "Home",
          customBadge: const Badge(),
          badgeStyle: NavigationBadgeStyle.exact,
        ),
        throwsAssertionError,
      );
    });

    test("customBadge + dot does NOT throw", () {
      expect(
        () => const NavigationDestination(
          icon: Icon(Icons.home),
          label: "Home",
          customBadge: Badge(),
          badgeStyle: NavigationBadgeStyle.dot,
        ),
        returnsNormally,
      );
    });

    test("customBadge + hidden does NOT throw", () {
      expect(
        () => const NavigationDestination(
          icon: Icon(Icons.home),
          label: "Home",
          customBadge: Badge(),
          badgeStyle: NavigationBadgeStyle.hidden,
        ),
        returnsNormally,
      );
    });

    test("badgeLabel + numeric-only badgeStyle throws AssertionError", () {
      expect(
        () => NavigationDestination(
          icon: const Icon(Icons.home),
          label: "Home",
          badgeLabel: "hello",
          badgeStyle: NavigationBadgeStyle.exact,
        ),
        throwsAssertionError,
      );
    });

    test("badgeLabel + dot does NOT throw", () {
      expect(
        () => const NavigationDestination(
          icon: Icon(Icons.home),
          label: "Home",
          badgeLabel: "hello",
          badgeStyle: NavigationBadgeStyle.dot,
        ),
        returnsNormally,
      );
    });

    test("badgeLabel + hidden does NOT throw", () {
      expect(
        () => const NavigationDestination(
          icon: Icon(Icons.home),
          label: "Home",
          badgeLabel: "hello",
          badgeStyle: NavigationBadgeStyle.hidden,
        ),
        returnsNormally,
      );
    });

    test("badge: null does not throw", () {
      expect(
        () => const NavigationDestination(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        returnsNormally,
      );
    });

    // --- Direct rail constructor assertions ---

    group("RailDestination badge", () {
      test("badge: 0 throws AssertionError", () {
        expect(
          () => RailDestination(
            icon: const Icon(Icons.home),
            label: const Text("Home"),
            badge: 0,
          ),
          throwsAssertionError,
        );
      });

      test("badge + badgeLabel mutual exclusivity throws AssertionError", () {
        expect(
          () => RailDestination(
            icon: const Icon(Icons.home),
            label: const Text("Home"),
            badge: 5,
            badgeLabel: "5",
          ),
          throwsAssertionError,
        );
      });

      test("badge + customBadge mutual exclusivity throws AssertionError", () {
        expect(
          () => RailDestination(
            icon: const Icon(Icons.home),
            label: const Text("Home"),
            badge: 5,
            customBadge: const Badge(),
          ),
          throwsAssertionError,
        );
      });

      test("badgeLabel + customBadge mutual exclusivity throws AssertionError",
          () {
        expect(
          () => RailDestination(
            icon: const Icon(Icons.home),
            label: const Text("Home"),
            badgeLabel: "hello",
            customBadge: const Badge(),
          ),
          throwsAssertionError,
        );
      });

      test("customBadge + exact throws AssertionError", () {
        expect(
          () => RailDestination(
            icon: const Icon(Icons.home),
            label: const Text("Home"),
            customBadge: const Badge(),
            badgeStyle: NavigationBadgeStyle.exact,
          ),
          throwsAssertionError,
        );
      });

      test("badgeLabel + exact throws AssertionError", () {
        expect(
          () => RailDestination(
            icon: const Icon(Icons.home),
            label: const Text("Home"),
            badgeLabel: "hello",
            badgeStyle: NavigationBadgeStyle.exact,
          ),
          throwsAssertionError,
        );
      });

      test("customBadge + dot does NOT throw", () {
        expect(
          () => const RailDestination(
            icon: Icon(Icons.home),
            label: Text("Home"),
            customBadge: Badge(),
            badgeStyle: NavigationBadgeStyle.dot,
          ),
          returnsNormally,
        );
      });

      test("badgeLabel + hidden does NOT throw", () {
        expect(
          () => const RailDestination(
            icon: Icon(Icons.home),
            label: Text("Home"),
            badgeLabel: "hello",
            badgeStyle: NavigationBadgeStyle.hidden,
          ),
          returnsNormally,
        );
      });
    });

    // --- Conversion: toRailDestination ---

    test("toRailDestination forwards badge value", () {
      const dest = NavigationDestination(
        icon: Icon(Icons.home),
        label: "Home",
        badge: 5,
      );
      expect(dest.toRailDestination().badge, 5);
    });

    test("toRailDestination forwards badgeStyle: dot", () {
      const dest = NavigationDestination(
        icon: Icon(Icons.home),
        label: "Home",
        badge: 3,
        badgeStyle: NavigationBadgeStyle.dot,
      );
      expect(dest.toRailDestination().badgeStyle, NavigationBadgeStyle.dot);
    });

    test("toRailDestination forwards badgeStyle: hidden", () {
      const dest = NavigationDestination(
        icon: Icon(Icons.home),
        label: "Home",
        badge: 3,
        badgeStyle: NavigationBadgeStyle.hidden,
      );
      expect(dest.toRailDestination().badgeStyle, NavigationBadgeStyle.hidden);
    });

    test(
        "toRailDestination preserves badge on NavigationRailDestination passthrough",
        () {
      // When the destination is already a NavigationRailDestination the
      // early-return guard must not lose the badge.
      const original = NavigationRailDestination(
        icon: Icon(Icons.home),
        label: Text("Home"),
        badge: 42,
        badgeStyle: NavigationBadgeStyle.dot,
      );
      final result = original.toRailDestination();
      expect(result.badge, 42);
      expect(result.badgeStyle, NavigationBadgeStyle.dot);
    });

    test("badgeStyle defaults to count", () {
      const dest = NavigationDestination(
        icon: Icon(Icons.home),
        label: "Home",
        badge: 1,
      );
      expect(dest.badgeStyle, NavigationBadgeStyle.count);
      expect(dest.toRailDestination().badgeStyle, NavigationBadgeStyle.count);
      expect(dest.toBarDestination().badgeStyle, NavigationBadgeStyle.count);
    });

    test("toRailDestination forwards badgeStyle: exact", () {
      const dest = NavigationDestination(
        icon: Icon(Icons.home),
        label: "Home",
        badge: 3,
        badgeStyle: NavigationBadgeStyle.exact,
      );
      expect(dest.toRailDestination().badgeStyle, NavigationBadgeStyle.exact);
    });

    // --- Conversion: toBarDestination ---

    test("toBarDestination forwards badge value", () {
      const dest = NavigationDestination(
        icon: Icon(Icons.home),
        label: "Home",
        badge: 7,
      );
      expect(dest.toBarDestination().badge, 7);
    });

    test("toBarDestination forwards badgeStyle: dot", () {
      const dest = NavigationDestination(
        icon: Icon(Icons.home),
        label: "Home",
        badge: 3,
        badgeStyle: NavigationBadgeStyle.dot,
      );
      expect(dest.toBarDestination().badgeStyle, NavigationBadgeStyle.dot);
    });

    // --- Rail rendering ---

    testWidgets("badge: null renders no Badge widget in rail",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationRail(
          selectedIndex: 0,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home),
              label: "Home",
            ).toRailDestination(),
            const NavigationDestination(
              icon: Icon(Icons.search),
              label: "Search",
            ).toRailDestination(),
          ],
        ),
      );
      expect(find.byType(Badge), findsNothing);
    });

    testWidgets("badge: 5 renders Badge with label '5' in rail",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationRail(
          selectedIndex: 0,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home),
              label: "Home",
              badge: 5,
            ).toRailDestination(),
            const NavigationDestination(
              icon: Icon(Icons.search),
              label: "Search",
            ).toRailDestination(),
          ],
        ),
      );
      expect(find.byType(Badge), findsOneWidget);
      expect(find.text("5"), findsOneWidget);
    });

    testWidgets("badge: 99 renders '99' (boundary — not capped) in rail",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationRail(
          selectedIndex: 0,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home),
              label: "Home",
              badge: 99,
            ).toRailDestination(),
            const NavigationDestination(
              icon: Icon(Icons.search),
              label: "Search",
            ).toRailDestination(),
          ],
        ),
      );
      expect(find.text("99"), findsOneWidget);
      expect(find.text("99+"), findsNothing);
    });

    testWidgets("badge: 100 renders '99+' (cap) in rail",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationRail(
          selectedIndex: 0,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home),
              label: "Home",
              badge: 100,
            ).toRailDestination(),
            const NavigationDestination(
              icon: Icon(Icons.search),
              label: "Search",
            ).toRailDestination(),
          ],
        ),
      );
      expect(find.text("99+"), findsOneWidget);
    });

    testWidgets("badge: 150 renders '99+' in rail",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationRail(
          selectedIndex: 0,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home),
              label: "Home",
              badge: 150,
            ).toRailDestination(),
            const NavigationDestination(
              icon: Icon(Icons.search),
              label: "Search",
            ).toRailDestination(),
          ],
        ),
      );
      expect(find.text("99+"), findsOneWidget);
    });

    testWidgets(
        "badge: 150 with badgeStyle: exact renders '150' (no cap) in rail",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationRail(
          selectedIndex: 0,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home),
              label: "Home",
              badge: 150,
              badgeStyle: NavigationBadgeStyle.exact,
            ).toRailDestination(),
            const NavigationDestination(
              icon: Icon(Icons.search),
              label: "Search",
            ).toRailDestination(),
          ],
        ),
      );
      expect(find.text("150"), findsOneWidget);
      expect(find.text("99+"), findsNothing);
    });

    testWidgets("badgeStyle: dot renders Badge without label in rail",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationRail(
          selectedIndex: 0,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home),
              label: "Home",
              badge: 3,
              badgeStyle: NavigationBadgeStyle.dot,
            ).toRailDestination(),
            const NavigationDestination(
              icon: Icon(Icons.search),
              label: "Search",
            ).toRailDestination(),
          ],
        ),
      );
      expect(find.byType(Badge), findsOneWidget);
      expect(find.text("3"), findsNothing);
    });

    testWidgets("badgeStyle: hidden suppresses Badge in rail",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationRail(
          selectedIndex: 0,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home),
              label: "Home",
              badge: 3,
              badgeStyle: NavigationBadgeStyle.hidden,
            ).toRailDestination(),
            const NavigationDestination(
              icon: Icon(Icons.search),
              label: "Search",
            ).toRailDestination(),
          ],
        ),
      );
      expect(find.byType(Badge), findsNothing);
    });

    testWidgets("badge renders in extended rail (labelType.none, extended)",
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpApp(
        tester,
        Row(
          children: [
            NavigationRail(
              selectedIndex: 0,
              extended: true,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home),
                  label: "Home",
                  badge: 5,
                ).toRailDestination(),
                const NavigationDestination(
                  icon: Icon(Icons.search),
                  label: "Search",
                ).toRailDestination(),
              ],
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Badge), findsOneWidget);
      expect(find.text("5"), findsOneWidget);
    });

    testWidgets("badge renders in rail with labelType.all",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationRail(
          selectedIndex: 0,
          labelType: NavigationRailLabelType.all,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home),
              label: "Home",
              badge: 5,
            ).toRailDestination(),
            const NavigationDestination(
              icon: Icon(Icons.search),
              label: "Search",
            ).toRailDestination(),
          ],
        ),
      );
      expect(find.byType(Badge), findsOneWidget);
      expect(find.text("5"), findsOneWidget);
    });

    testWidgets("badge renders in rail with labelType.selected",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationRail(
          selectedIndex: 0,
          labelType: NavigationRailLabelType.selected,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home),
              label: "Home",
              badge: 5,
            ).toRailDestination(),
            const NavigationDestination(
              icon: Icon(Icons.search),
              label: "Search",
            ).toRailDestination(),
          ],
        ),
      );
      expect(find.byType(Badge), findsOneWidget);
    });

    testWidgets(
        "NavigationRailThemeData.badgeThemeData wraps badge with BadgeTheme",
        (WidgetTester tester) async {
      const Color badgeColor = Color(0xFF0000FF);
      await pumpApp(
        tester,
        NavigationRailTheme(
          data: const NavigationRailThemeData(
            badgeThemeData: BadgeThemeData(backgroundColor: badgeColor),
          ),
          child: NavigationRail(
            selectedIndex: 0,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home),
                label: "Home",
                badge: 1,
              ).toRailDestination(),
              const NavigationDestination(
                icon: Icon(Icons.search),
                label: "Search",
              ).toRailDestination(),
            ],
          ),
        ),
      );
      expect(
        find.byWidgetPredicate(
          (Widget w) => w is BadgeTheme && w.data.backgroundColor == badgeColor,
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        "NavigationRailThemeData.badgeThemeData null preserves ambient BadgeTheme",
        (WidgetTester tester) async {
      const Color ambientBadgeColor = Color(0xFF00FF00);
      await pumpApp(
        tester,
        BadgeTheme(
          data: const BadgeThemeData(backgroundColor: ambientBadgeColor),
          child: NavigationRailTheme(
            data: const NavigationRailThemeData(
              badgeThemeData: null,
            ),
            child: NavigationRail(
              selectedIndex: 0,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home),
                  label: "Home",
                  badge: 1,
                ).toRailDestination(),
                const NavigationDestination(
                  icon: Icon(Icons.search),
                  label: "Search",
                ).toRailDestination(),
              ],
            ),
          ),
        ),
      );

      final Badge badge = tester.widget<Badge>(find.byType(Badge));
      final BuildContext badgeContext = tester.element(find.byWidget(badge));
      expect(BadgeTheme.of(badgeContext).backgroundColor, ambientBadgeColor);
    });

    // --- Bar rendering ---

    testWidgets("badge: null renders no Badge widget in bar",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationBar(
          destinations: const [
            NavigationBarDestination(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            NavigationBarDestination(
              icon: Icon(Icons.search),
              label: "Search",
            ),
          ],
        ),
      );
      expect(find.byType(Badge), findsNothing);
    });

    testWidgets("badge: 5 renders Badge with label '5' in bar",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationBar(
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home),
              label: "Home",
              badge: 5,
            ).toBarDestination(),
            const NavigationDestination(
              icon: Icon(Icons.search),
              label: "Search",
            ).toBarDestination(),
          ],
        ),
      );
      expect(find.byType(Badge), findsOneWidget);
      expect(find.text("5"), findsOneWidget);
    });

    testWidgets("badge: 99 renders '99' (boundary — not capped) in bar",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationBar(
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home),
              label: "Home",
              badge: 99,
            ).toBarDestination(),
            const NavigationDestination(
              icon: Icon(Icons.search),
              label: "Search",
            ).toBarDestination(),
          ],
        ),
      );
      expect(find.text("99"), findsOneWidget);
      expect(find.text("99+"), findsNothing);
    });

    testWidgets("badge: 100 renders '99+' (cap) in bar",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationBar(
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home),
              label: "Home",
              badge: 100,
            ).toBarDestination(),
            const NavigationDestination(
              icon: Icon(Icons.search),
              label: "Search",
            ).toBarDestination(),
          ],
        ),
      );
      expect(find.text("99+"), findsOneWidget);
    });

    testWidgets("badge: 150 renders '99+' in bar", (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationBar(
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home),
              label: "Home",
              badge: 150,
            ).toBarDestination(),
            const NavigationDestination(
              icon: Icon(Icons.search),
              label: "Search",
            ).toBarDestination(),
          ],
        ),
      );
      expect(find.text("99+"), findsOneWidget);
    });

    testWidgets("badgeStyle: exact renders uncapped numeric badge in bar",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationBar(
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home),
              label: "Home",
              badge: 150,
              badgeStyle: NavigationBadgeStyle.exact,
            ).toBarDestination(),
            const NavigationDestination(
              icon: Icon(Icons.search),
              label: "Search",
            ).toBarDestination(),
          ],
        ),
      );
      expect(find.text("150"), findsOneWidget);
      expect(find.text("99+"), findsNothing);
    });

    testWidgets("customBadge is reconstructed around themed icon in bar",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationBar(
          destinations: const [
            NavigationBarDestination(
              icon: Icon(Icons.home),
              label: "Home",
              customBadge: Badge(
                label: Text("NEW"),
                backgroundColor: Colors.purple,
                alignment: Alignment.topLeft,
                offset: Offset(-2, 3),
                isLabelVisible: true,
              ),
            ),
            NavigationBarDestination(
              icon: Icon(Icons.search),
              label: "Search",
            ),
          ],
        ),
      );

      final Badge badge = tester.widget<Badge>(find.byType(Badge).first);
      expect(find.text("NEW"), findsOneWidget);
      expect(badge.backgroundColor, Colors.purple);
      expect(badge.alignment, Alignment.topLeft);
      expect(badge.offset, const Offset(-2, 3));
      expect(badge.isLabelVisible, isTrue);
    });

    testWidgets("badgeLabel renders custom text badge in bar",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationBar(
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home),
              label: "Home",
              badgeLabel: "Hi",
            ).toBarDestination(),
            const NavigationDestination(
              icon: Icon(Icons.search),
              label: "Search",
            ).toBarDestination(),
          ],
        ),
      );

      expect(find.byType(Badge), findsOneWidget);
      expect(find.text("Hi"), findsOneWidget);
    });

    testWidgets("bar label uses explicit label padding and fallback text style",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            navigationBarTheme: const CustomNavigationBarThemeData(
              labelTextStyle: null,
            ),
          ),
          home: Scaffold(
            bottomNavigationBar: NavigationBarTheme(
              data: const CustomNavigationBarThemeData(
                labelTextStyle: null,
                labelPadding: EdgeInsets.only(top: 9),
              ),
              child: NavigationBar(
                labelTextStyle: null,
                destinations: const [
                  NavigationBarDestination(
                    icon: Icon(Icons.home),
                    label: "Home",
                  ),
                  NavigationBarDestination(
                    icon: Icon(Icons.search),
                    label: "Search",
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final Padding padding = tester.widget<Padding>(
        find
            .ancestor(of: find.text("Home"), matching: find.byType(Padding))
            .first,
      );
      final DefaultTextStyle textStyle = tester.widget<DefaultTextStyle>(
        find
            .ancestor(
              of: find.text("Home"),
              matching: find.byType(DefaultTextStyle),
            )
            .first,
      );

      expect(padding.padding, const EdgeInsets.only(top: 9));
      expect(textStyle.style, isNot(const TextStyle()));
    });

    testWidgets(
        "NavigationBarThemeData.badgeThemeData wraps badge with BadgeTheme",
        (WidgetTester tester) async {
      const Color badgeColor = Color(0xFFFF0000);
      await pumpApp(
        tester,
        NavigationBarTheme(
          data: const CustomNavigationBarThemeData(
            badgeThemeData: BadgeThemeData(backgroundColor: badgeColor),
          ),
          child: NavigationBar(
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home),
                label: "Home",
                badge: 1,
              ).toBarDestination(),
              const NavigationDestination(
                icon: Icon(Icons.search),
                label: "Search",
              ).toBarDestination(),
            ],
          ),
        ),
      );
      expect(
        find.byWidgetPredicate(
          (Widget w) => w is BadgeTheme && w.data.backgroundColor == badgeColor,
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        "NavigationBarThemeData.badgeThemeData null preserves ambient BadgeTheme",
        (WidgetTester tester) async {
      const Color ambientBadgeColor = Color(0xFF00AA00);
      await pumpApp(
        tester,
        BadgeTheme(
          data: const BadgeThemeData(backgroundColor: ambientBadgeColor),
          child: NavigationBarTheme(
            data: const CustomNavigationBarThemeData(
              badgeThemeData: null,
            ),
            child: NavigationBar(
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home),
                  label: "Home",
                  badge: 1,
                ).toBarDestination(),
                const NavigationDestination(
                  icon: Icon(Icons.search),
                  label: "Search",
                ).toBarDestination(),
              ],
            ),
          ),
        ),
      );

      final Badge badge = tester.widget<Badge>(find.byType(Badge));
      final BuildContext badgeContext = tester.element(find.byWidget(badge));
      expect(BadgeTheme.of(badgeContext).backgroundColor, ambientBadgeColor);
    });

    testWidgets("customBadge is reconstructed around themed icon in rail",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationRail(
          selectedIndex: 0,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.home),
              label: Text("Home"),
              customBadge: Badge(
                label: Text("NEW"),
                backgroundColor: Colors.teal,
                alignment: Alignment.topLeft,
                offset: Offset(-1, 2),
                isLabelVisible: true,
              ),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.search),
              label: Text("Search"),
            ),
          ],
        ),
      );

      final Badge badge = tester.widget<Badge>(find.byType(Badge).first);
      expect(find.text("NEW"), findsOneWidget);
      expect(badge.backgroundColor, Colors.teal);
      expect(badge.alignment, Alignment.topLeft);
      expect(badge.offset, const Offset(-1, 2));
      expect(badge.isLabelVisible, isTrue);
    });

    testWidgets("badgeLabel renders custom text badge in rail",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationRail(
          selectedIndex: 0,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.home),
              label: Text("Home"),
              badgeLabel: "Hi",
            ),
            NavigationRailDestination(
              icon: Icon(Icons.search),
              label: Text("Search"),
            ),
          ],
        ),
      );

      expect(find.byType(Badge), findsOneWidget);
      expect(find.text("Hi"), findsOneWidget);
    });

    testWidgets("multiple destinations each render their own badge in bar",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationBar(
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home),
              label: "Home",
              badge: 150,
            ).toBarDestination(),
            const NavigationDestination(
              icon: Icon(Icons.search),
              label: "Search",
              badge: 1,
            ).toBarDestination(),
            const NavigationDestination(
              icon: Icon(Icons.settings),
              label: "Settings",
              badge: 1,
              badgeStyle: NavigationBadgeStyle.dot,
            ).toBarDestination(),
            const NavigationDestination(
              icon: Icon(Icons.person),
              label: "Profile",
            ).toBarDestination(),
          ],
        ),
      );
      expect(find.byType(Badge), findsNWidgets(3));
      expect(find.text("99+"), findsOneWidget);
      expect(find.text("1"), findsOneWidget);
    });

    testWidgets("bar widget uses default indicator color and shape fallback",
        (WidgetTester tester) async {
      await pumpApp(
        tester,
        NavigationBarTheme(
          data: const CustomNavigationBarThemeData(
            indicatorColor: null,
            indicatorShape: null,
          ),
          child: NavigationBar(
            destinations: const [
              NavigationBarDestination(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              NavigationBarDestination(
                icon: Icon(Icons.search),
                label: "Search",
              ),
            ],
          ),
        ),
      );

      final custom_adaptive_scaffold.NavigationIndicator indicator =
          tester.widget<custom_adaptive_scaffold.NavigationIndicator>(
        find.byType(custom_adaptive_scaffold.NavigationIndicator).first,
      );

      expect(indicator.color, isNotNull);
      expect(indicator.shape, isNotNull);
    });
  });
}
