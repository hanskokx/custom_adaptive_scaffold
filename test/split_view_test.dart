import "package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart";
import "package:flutter_test/flutter_test.dart";
import "package:material_ui/material_ui.dart";

void main() {
  group("SplitView", () {
    testWidgets("isActive returns false when no SplitView ancestor", (
      WidgetTester tester,
    ) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              result = SplitView.isActive(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(result, isFalse);
    });

    testWidgets("isActive returns true when notifier is true", (
      WidgetTester tester,
    ) async {
      bool? result;
      final ValueNotifier<bool> notifier = ValueNotifier<bool>(true);

      await tester.pumpWidget(
        MaterialApp(
          home: SplitView(
            notifier: notifier,
            child: Builder(
              builder: (context) {
                result = SplitView.isActive(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(result, isTrue);
      notifier.dispose();
    });

    testWidgets("isActive returns false when notifier is false", (
      WidgetTester tester,
    ) async {
      bool? result;
      final ValueNotifier<bool> notifier = ValueNotifier<bool>(false);

      await tester.pumpWidget(
        MaterialApp(
          home: SplitView(
            notifier: notifier,
            child: Builder(
              builder: (context) {
                result = SplitView.isActive(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(result, isFalse);
      notifier.dispose();
    });
  });

  group("SplitViewDetector", () {
    testWidgets(
      "calls onChanged with true when AdaptiveBody is not collapsed",
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        bool? reportedState;
        final ValueNotifier<bool> notifier = ValueNotifier<bool>(false);

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(800, 800)),
              child: SplitView(
                notifier: notifier,
                child: AdaptiveBody(
                  viewIsCollapsed: false,
                  child: SplitViewDetector(
                    onChanged: (v) => reportedState = v,
                    child: const SizedBox(),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(reportedState, isTrue);
        notifier.dispose();
      },
    );

    testWidgets("calls onChanged with false when AdaptiveBody is collapsed", (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      bool? reportedState;
      final ValueNotifier<bool> notifier = ValueNotifier<bool>(true);

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: SplitView(
              notifier: notifier,
              child: AdaptiveBody(
                viewIsCollapsed: true,
                child: SplitViewDetector(
                  onChanged: (v) => reportedState = v,
                  child: const SizedBox(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(reportedState, isFalse);
      notifier.dispose();
    });

    testWidgets("does not crash when unmounted before postFrameCallback", (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final ValueNotifier<bool> notifier = ValueNotifier<bool>(false);

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 800)),
            child: SplitView(
              notifier: notifier,
              child: AdaptiveBody(
                viewIsCollapsed: false,
                child: SplitViewDetector(
                  onChanged: (_) {},
                  child: const SizedBox(),
                ),
              ),
            ),
          ),
        ),
      );

      // Pump a frame to trigger the postFrameCallback, then immediately
      // dispose. The callback checks `mounted` and should not crash.
      await tester.pump();
      notifier.dispose();
    });
  });
}
