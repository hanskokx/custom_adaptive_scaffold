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
import "package:flutter/material.dart" as m
    show
        NavigationBarTheme,
        NavigationBarThemeData,
        NavigationRailTheme,
        NavigationRailThemeData;
import "package:flutter_test/flutter_test.dart";

void main() {
  group("NavigationBarThemeData package fields", () {
    test("lerp interpolates package-specific fields", () {
      const NavigationBarThemeData a = NavigationBarThemeData(
        destinationIndicatorShape: StadiumBorder(),
        destinationOverlayColor: WidgetStatePropertyAll<Color>(Colors.red),
        margin: EdgeInsets.all(4),
        padding: EdgeInsets.all(8),
        tooltipOffset: Offset(1, 2),
        tooltipTrigger: TooltipTriggerMode.longPress,
        tooltipTriggerWhenLabelVisible: TooltipTriggerMode.tap,
        tooltipTriggerWhenLabelHidden: TooltipTriggerMode.manual,
        badgeThemeData: BadgeThemeData(backgroundColor: Colors.green),
      );
      const NavigationBarThemeData b = NavigationBarThemeData(
        destinationIndicatorShape: RoundedRectangleBorder(),
        destinationOverlayColor: WidgetStatePropertyAll<Color>(Colors.blue),
        margin: EdgeInsets.all(12),
        padding: EdgeInsets.all(16),
        tooltipOffset: Offset(5, 6),
        tooltipTrigger: TooltipTriggerMode.tap,
        tooltipTriggerWhenLabelVisible: TooltipTriggerMode.manual,
        tooltipTriggerWhenLabelHidden: TooltipTriggerMode.longPress,
        badgeThemeData: BadgeThemeData(backgroundColor: Colors.yellow),
      );

      final NavigationBarThemeData lerpLow =
          NavigationBarThemeData.lerp(a, b, 0.25)!;
      final NavigationBarThemeData lerpHigh =
          NavigationBarThemeData.lerp(a, b, 0.75)!;

      expect(lerpLow.destinationIndicatorShape, isA<ShapeBorder>());
      expect(
        lerpLow.destinationOverlayColor?.resolve(<WidgetState>{}),
        isNotNull,
      );
      expect(lerpLow.margin, const EdgeInsets.all(6));
      expect(lerpLow.padding, const EdgeInsets.all(10));
      expect(lerpLow.tooltipOffset, const Offset(2, 3));
      expect(lerpLow.tooltipTrigger, TooltipTriggerMode.longPress);
      expect(
        lerpLow.tooltipTriggerWhenLabelVisible,
        TooltipTriggerMode.tap,
      );
      expect(
        lerpLow.tooltipTriggerWhenLabelHidden,
        TooltipTriggerMode.manual,
      );
      expect(lerpLow.badgeThemeData?.backgroundColor, isNotNull);

      expect(lerpHigh.tooltipTrigger, TooltipTriggerMode.tap);
      expect(
        lerpHigh.tooltipTriggerWhenLabelVisible,
        TooltipTriggerMode.manual,
      );
      expect(
        lerpHigh.tooltipTriggerWhenLabelHidden,
        TooltipTriggerMode.longPress,
      );
    });

    test("fromMaterial fills package-only fields with null", () {
      final NavigationBarThemeData data = NavigationBarThemeData.fromMaterial(
        const m.NavigationBarThemeData(
          height: 70,
          backgroundColor: Colors.red,
          indicatorColor: Colors.blue,
          labelPadding: EdgeInsets.all(3),
        ),
      );

      expect(data.height, 70);
      expect(data.backgroundColor, Colors.red);
      expect(data.indicatorColor, Colors.blue);
      expect(data.labelPadding, const EdgeInsets.all(3));
      expect(data.destinationOverlayColor, isNull);
      expect(data.destinationIndicatorShape, isNull);
      expect(data.margin, isNull);
      expect(data.padding, isNull);
      expect(data.tooltipOffset, isNull);
      expect(data.tooltipTrigger, isNull);
      expect(data.tooltipTriggerWhenLabelVisible, isNull);
      expect(data.tooltipTriggerWhenLabelHidden, isNull);
      expect(data.badgeThemeData, isNull);
    });
  });

  group("NavigationBarTheme package bridge", () {
    testWidgets("maybeOf picks up in-scope Flutter NavigationBarTheme",
        (WidgetTester tester) async {
      NavigationBarThemeData? captured;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: m.NavigationBarTheme(
              data: const m.NavigationBarThemeData(height: 123),
              child: Builder(
                builder: (BuildContext context) {
                  captured = NavigationBarTheme.maybeOf(context);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      expect(captured, isNotNull);
      expect(captured!.height, 123);
    });

    testWidgets("of merges explicit package values over defaults",
        (WidgetTester tester) async {
      late NavigationBarThemeData resolved;

      await tester.pumpWidget(
        MaterialApp(
          home: NavigationBarTheme(
            data: const NavigationBarThemeData(
              destinationIndicatorShape: RoundedRectangleBorder(),
              destinationOverlayColor:
                  WidgetStatePropertyAll<Color>(Colors.purple),
              tooltipOffset: Offset(3, 4),
              tooltipTriggerWhenLabelVisible: TooltipTriggerMode.tap,
              badgeThemeData: BadgeThemeData(backgroundColor: Colors.orange),
            ),
            child: Builder(
              builder: (BuildContext context) {
                resolved = NavigationBarTheme.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(resolved.destinationIndicatorShape, isA<RoundedRectangleBorder>());
      expect(
        resolved.destinationOverlayColor?.resolve(<WidgetState>{}),
        Colors.purple,
      );
      expect(resolved.tooltipOffset, const Offset(3, 4));
      expect(
        resolved.tooltipTriggerWhenLabelVisible,
        TooltipTriggerMode.tap,
      );
      expect(resolved.badgeThemeData?.backgroundColor, Colors.orange);
    });

    testWidgets("wrap and updateShouldNotify use data equality",
        (WidgetTester tester) async {
      const NavigationBarTheme theme = NavigationBarTheme(
        data: NavigationBarThemeData(height: 80),
        child: SizedBox(),
      );
      const NavigationBarTheme sameTheme = NavigationBarTheme(
        data: NavigationBarThemeData(height: 80),
        child: SizedBox(),
      );
      const NavigationBarTheme differentTheme = NavigationBarTheme(
        data: NavigationBarThemeData(height: 81),
        child: SizedBox(),
      );

      await tester.pumpWidget(const MaterialApp(home: Placeholder()));

      final Widget wrapped = theme.wrap(
        tester.element(find.byType(Placeholder)),
        const SizedBox(),
      );

      expect(wrapped, isA<NavigationBarTheme>());
      expect(theme.updateShouldNotify(sameTheme), isFalse);
      expect(theme.updateShouldNotify(differentTheme), isTrue);
    });
  });

  group("NavigationRailThemeData package fields", () {
    test("lerp interpolates package-specific fields", () {
      const NavigationRailThemeData a = NavigationRailThemeData(
        destinationIndicatorShape: StadiumBorder(),
        destinationOverlayColor: WidgetStatePropertyAll<Color>(Colors.red),
        showLabelsWhenCollapsed: false,
        minWidth: 80,
        minExtendedWidth: 200,
        margin: EdgeInsets.all(4),
        padding: EdgeInsets.all(8),
        tooltipOffset: Offset(1, 2),
        tooltipTrigger: TooltipTriggerMode.longPress,
        tooltipTriggerWhenLabelVisible: TooltipTriggerMode.tap,
        tooltipTriggerWhenLabelHidden: TooltipTriggerMode.manual,
        badgeThemeData: BadgeThemeData(backgroundColor: Colors.green),
      );
      const NavigationRailThemeData b = NavigationRailThemeData(
        destinationIndicatorShape: RoundedRectangleBorder(),
        destinationOverlayColor: WidgetStatePropertyAll<Color>(Colors.blue),
        showLabelsWhenCollapsed: true,
        minWidth: 100,
        minExtendedWidth: 240,
        margin: EdgeInsets.all(12),
        padding: EdgeInsets.all(16),
        tooltipOffset: Offset(5, 6),
        tooltipTrigger: TooltipTriggerMode.tap,
        tooltipTriggerWhenLabelVisible: TooltipTriggerMode.manual,
        tooltipTriggerWhenLabelHidden: TooltipTriggerMode.longPress,
        badgeThemeData: BadgeThemeData(backgroundColor: Colors.yellow),
      );

      final NavigationRailThemeData lerpLow =
          NavigationRailThemeData.lerp(a, b, 0.25)!;
      final NavigationRailThemeData lerpHigh =
          NavigationRailThemeData.lerp(a, b, 0.75)!;

      expect(lerpLow.destinationIndicatorShape, isA<ShapeBorder>());
      expect(
        lerpLow.destinationOverlayColor?.resolve(<WidgetState>{}),
        isNotNull,
      );
      expect(lerpLow.showLabelsWhenCollapsed, isFalse);
      expect(lerpLow.minWidth, 85);
      expect(lerpLow.minExtendedWidth, 210);
      expect(lerpLow.margin, const EdgeInsets.all(6));
      expect(lerpLow.padding, const EdgeInsets.all(10));
      expect(lerpLow.tooltipOffset, const Offset(2, 3));
      expect(lerpLow.tooltipTrigger, TooltipTriggerMode.longPress);
      expect(
        lerpLow.tooltipTriggerWhenLabelVisible,
        TooltipTriggerMode.tap,
      );
      expect(
        lerpLow.tooltipTriggerWhenLabelHidden,
        TooltipTriggerMode.manual,
      );
      expect(lerpLow.badgeThemeData?.backgroundColor, isNotNull);

      expect(lerpHigh.showLabelsWhenCollapsed, isTrue);
      expect(lerpHigh.tooltipTrigger, TooltipTriggerMode.tap);
      expect(
        lerpHigh.tooltipTriggerWhenLabelVisible,
        TooltipTriggerMode.manual,
      );
      expect(
        lerpHigh.tooltipTriggerWhenLabelHidden,
        TooltipTriggerMode.longPress,
      );
    });

    test("fromMaterial fills package-only fields with null", () {
      final NavigationRailThemeData data = NavigationRailThemeData.fromMaterial(
        const m.NavigationRailThemeData(
          backgroundColor: Colors.red,
          elevation: 3,
          indicatorColor: Colors.blue,
          minWidth: 72,
          minExtendedWidth: 192,
        ),
      );

      expect(data.backgroundColor, Colors.red);
      expect(data.elevation, 3);
      expect(data.indicatorColor, Colors.blue);
      expect(data.minWidth, 72);
      expect(data.minExtendedWidth, 192);
      expect(data.destinationOverlayColor, isNull);
      expect(data.destinationIndicatorShape, isNull);
      expect(data.margin, isNull);
      expect(data.padding, isNull);
      expect(data.tooltipOffset, isNull);
      expect(data.tooltipTrigger, isNull);
      expect(data.tooltipTriggerWhenLabelVisible, isNull);
      expect(data.tooltipTriggerWhenLabelHidden, isNull);
      expect(data.iconTheme, isNull);
      expect(data.badgeThemeData, isNull);
    });
  });

  group("NavigationRailTheme package bridge", () {
    testWidgets(
        "maybeOf returns null when Flutter theme has no explicit values",
        (WidgetTester tester) async {
      NavigationRailThemeData? captured;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              captured = NavigationRailTheme.maybeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(captured, isNull);
    });

    testWidgets("maybeOf picks up in-scope Flutter NavigationRailTheme",
        (WidgetTester tester) async {
      NavigationRailThemeData? captured;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: m.NavigationRailTheme(
              data: const m.NavigationRailThemeData(minWidth: 91),
              child: Builder(
                builder: (BuildContext context) {
                  captured = NavigationRailTheme.maybeOf(context);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      expect(captured, isNotNull);
      expect(captured!.minWidth, 91);
    });

    testWidgets("of merges explicit package values over defaults",
        (WidgetTester tester) async {
      late NavigationRailThemeData resolved;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigationRailTheme(
              data: const NavigationRailThemeData(
                destinationIndicatorShape: RoundedRectangleBorder(),
                destinationOverlayColor:
                    WidgetStatePropertyAll<Color>(Colors.purple),
                showLabelsWhenCollapsed: true,
                tooltipOffset: Offset(3, 4),
                tooltipTriggerWhenLabelHidden: TooltipTriggerMode.longPress,
                badgeThemeData: BadgeThemeData(backgroundColor: Colors.orange),
              ),
              child: Builder(
                builder: (BuildContext context) {
                  resolved = NavigationRailTheme.of(context);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      expect(
        resolved.destinationIndicatorShape,
        isA<RoundedRectangleBorder>(),
      );
      expect(
        resolved.destinationOverlayColor?.resolve(<WidgetState>{}),
        Colors.purple,
      );
      expect(resolved.showLabelsWhenCollapsed, isTrue);
      expect(resolved.tooltipOffset, const Offset(3, 4));
      expect(
        resolved.tooltipTriggerWhenLabelHidden,
        TooltipTriggerMode.longPress,
      );
      expect(resolved.badgeThemeData?.backgroundColor, Colors.orange);
    });

    testWidgets("wrap and updateShouldNotify use data equality",
        (WidgetTester tester) async {
      const NavigationRailTheme theme = NavigationRailTheme(
        data: NavigationRailThemeData(minWidth: 80),
        child: SizedBox(),
      );
      const NavigationRailTheme sameTheme = NavigationRailTheme(
        data: NavigationRailThemeData(minWidth: 80),
        child: SizedBox(),
      );
      const NavigationRailTheme differentTheme = NavigationRailTheme(
        data: NavigationRailThemeData(minWidth: 81),
        child: SizedBox(),
      );

      await tester.pumpWidget(const MaterialApp(home: Placeholder()));
      final Widget wrapped = theme.wrap(
        tester.element(find.byType(Placeholder)),
        const SizedBox(),
      );

      expect(wrapped, isA<NavigationRailTheme>());
      expect(theme.updateShouldNotify(sameTheme), isFalse);
      expect(theme.updateShouldNotify(differentTheme), isTrue);
    });
  });

  group("Theme defaults", () {
    testWidgets("navigation bar M2 defaults keep destinationOverlayColor null",
        (WidgetTester tester) async {
      late NavigationBarThemeData defaults;

      await tester.pumpWidget(
        MaterialApp(
          // ignore: deprecated_member_use
          theme: ThemeData.light().copyWith(useMaterial3: false),
          home: Builder(
            builder: (BuildContext context) {
              defaults = NavigationBarTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(defaults.destinationOverlayColor, isNull);
      expect(
        defaults.overlayColor
            ?.resolve(const <WidgetState>{WidgetState.hovered}),
        isNotNull,
      );
    });

    testWidgets(
        "navigation rail M2 defaults resolve destination overlay colors",
        (WidgetTester tester) async {
      late NavigationRailThemeData defaults;

      await tester.pumpWidget(
        MaterialApp(
          // ignore: deprecated_member_use
          theme: ThemeData.light().copyWith(useMaterial3: false),
          home: Builder(
            builder: (BuildContext context) {
              defaults = NavigationRailTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(
        defaults.destinationOverlayColor?.resolve(
          const <WidgetState>{WidgetState.pressed},
        ),
        isNotNull,
      );
      expect(
        defaults.destinationOverlayColor?.resolve(
          const <WidgetState>{WidgetState.hovered},
        ),
        isNotNull,
      );
      expect(
        defaults.destinationOverlayColor?.resolve(const <WidgetState>{}),
        isNull,
      );
    });

    testWidgets(
        "navigation rail M3 defaults resolve destination overlay colors",
        (WidgetTester tester) async {
      late NavigationRailThemeData defaults;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Builder(
            builder: (BuildContext context) {
              defaults = NavigationRailTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(
        defaults.destinationOverlayColor?.resolve(
          const <WidgetState>{WidgetState.focused},
        ),
        isNotNull,
      );
      expect(
        defaults.destinationOverlayColor?.resolve(
          const <WidgetState>{WidgetState.hovered},
        ),
        isNotNull,
      );
      expect(defaults.indicatorShape, const StadiumBorder());
    });
  });
}
