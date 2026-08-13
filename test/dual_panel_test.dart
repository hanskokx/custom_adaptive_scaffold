import "package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart";
import "package:flutter_test/flutter_test.dart";
import "package:material_ui/material_ui.dart";

void main() {
  group("DualPanel", () {
    testWidgets("shows only body on narrow screen", (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: DualPanel(
              body: const Text("Primary"),
              secondaryBody: const Text("Secondary"),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Primary"), findsOneWidget);
      expect(find.text("Secondary"), findsNothing);
    });

    testWidgets("shows both body and secondaryBody on wide screen", (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 800)),
            child: DualPanel(
              body: const Text("Primary"),
              secondaryBody: const Text("Secondary"),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Primary"), findsOneWidget);
      expect(find.text("Secondary"), findsOneWidget);
    });

    testWidgets("does not show secondaryBody when null", (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 800)),
            child: DualPanel(
              body: const Text("Primary"),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Primary"), findsOneWidget);
      expect(find.byType(SlotLayout), findsWidgets);
    });

    testWidgets("applies maxWidth constraint to body", (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 800)),
            child: DualPanel(
              body: const SizedBox(width: 1200, height: 100),
              maxWidth: 600,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final ConstrainedBox constrained = tester.widget<ConstrainedBox>(
        find.ancestor(
          of: find.byType(SizedBox),
          matching: find.byType(ConstrainedBox),
        ),
      );
      expect(constrained.constraints.maxWidth, 600);
    });

    testWidgets("uses custom breakpoint", (WidgetTester tester) async {
      // At 800px, mediumAndUp (600+) would normally show both panes.
      // With largeAndUp (1200+), only body should be visible at 800.
      await tester.binding.setSurfaceSize(const Size(800, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 800)),
            child: DualPanel(
              body: const Text("Primary"),
              secondaryBody: const Text("Secondary"),
              breakpoint: Breakpoints.largeAndUp,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Primary"), findsOneWidget);
      expect(find.text("Secondary"), findsNothing);
    });

    testWidgets("custom breakpoint shows secondary at threshold", (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: DualPanel(
              body: const Text("Primary"),
              secondaryBody: const Text("Secondary"),
              breakpoint: Breakpoints.largeAndUp,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Primary"), findsOneWidget);
      expect(find.text("Secondary"), findsOneWidget);
    });

    testWidgets("AdaptiveBody reports collapsed on narrow screen", (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      bool? collapsed;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: DualPanel(
              body: Builder(
                builder: (context) {
                  collapsed = AdaptiveBody.of(context)?.viewIsCollapsed;
                  return const Text("Primary");
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(collapsed, isTrue);
    });

    testWidgets("AdaptiveBody reports expanded on wide screen", (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      bool? collapsed;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 800)),
            child: DualPanel(
              body: Builder(
                builder: (context) {
                  collapsed = AdaptiveBody.of(context)?.viewIsCollapsed;
                  return const Text("Primary");
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(collapsed, isFalse);
    });
  });

  group("DualPanelNavigationConfig", () {
    test("constructor with all fields", () {
      const config = DualPanelNavigationConfig(
        destinations: [],
        leadingUnextendedNavRail: SizedBox(),
        leadingExtendedNavRail: SizedBox(),
        trailingNavRail: SizedBox(),
      );

      expect(config.destinations, isEmpty);
      expect(config.leadingUnextendedNavRail, isA<SizedBox>());
      expect(config.leadingExtendedNavRail, isA<SizedBox>());
      expect(config.trailingNavRail, isA<SizedBox>());
    });

    test("constructor with no fields", () {
      const config = DualPanelNavigationConfig();

      expect(config.destinations, isNull);
      expect(config.leadingUnextendedNavRail, isNull);
      expect(config.leadingExtendedNavRail, isNull);
      expect(config.trailingNavRail, isNull);
    });

    test("copyWith returns new instance with updated fields", () {
      const config = DualPanelNavigationConfig();
      final updated = config.copyWith(
        destinations: const [],
        leadingUnextendedNavRail: const SizedBox(),
      );

      expect(updated.destinations, isEmpty);
      expect(updated.leadingUnextendedNavRail, isA<SizedBox>());
      expect(updated.leadingExtendedNavRail, isNull);
      expect(updated.trailingNavRail, isNull);
    });

    test("copyWith with no args returns equivalent config", () {
      const config = DualPanelNavigationConfig();
      final copy = config.copyWith();

      expect(copy.destinations, config.destinations);
      expect(
        copy.leadingUnextendedNavRail,
        config.leadingUnextendedNavRail,
      );
      expect(copy.leadingExtendedNavRail, config.leadingExtendedNavRail);
      expect(copy.trailingNavRail, config.trailingNavRail);
    });

    test("toString includes all fields", () {
      const config = DualPanelNavigationConfig();
      final str = config.toString();

      expect(str, contains("DualPanelNavigationConfig"));
      expect(str, contains("destinations:"));
      expect(str, contains("leadingUnextendedNavRail:"));
      expect(str, contains("leadingExtendedNavRail:"));
      expect(str, contains("trailingNavRail:"));
    });
  });
}
