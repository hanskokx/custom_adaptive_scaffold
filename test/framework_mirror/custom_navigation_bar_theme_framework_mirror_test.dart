// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is run as part of a reduced test set in CI on Mac and Windows
// machines.
@Tags(<String>["reduced-test-set"])
library;

import "package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart" hide NavigationIndicator;
import "package:flutter/rendering.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("copyWith, ==, hashCode basics", () {
    expect(
      const CustomNavigationBarThemeData(),
      const CustomNavigationBarThemeData().copyWith(),
    );
    expect(
      const CustomNavigationBarThemeData().hashCode,
      const CustomNavigationBarThemeData().copyWith().hashCode,
    );
  });

  test("CustomNavigationBarThemeData lerp special cases", () {
    expect(CustomNavigationBarThemeData.lerp(null, null, 0), null);
    const data = CustomNavigationBarThemeData();
    expect(
      identical(CustomNavigationBarThemeData.lerp(data, data, 0.5), data),
      true,
    );
  });

  testWidgets("Default debugFillProperties", (WidgetTester tester) async {
    final builder = DiagnosticPropertiesBuilder();
    const CustomNavigationBarThemeData().debugFillProperties(builder);

    final List<String> description = builder.properties
        .where((DiagnosticsNode node) => !node.isFiltered(DiagnosticLevel.info))
        .map((DiagnosticsNode node) => node.toString())
        .toList();

    expect(description, <String>[]);
  });

  testWidgets("CustomNavigationBarThemeData implements debugFillProperties",
      (WidgetTester tester) async {
    final builder = DiagnosticPropertiesBuilder();
    const CustomNavigationBarThemeData(
      height: 200.0,
      backgroundColor: Color(0x00000099),
      elevation: 20.0,
      shadowColor: Color(0x00000098),
      surfaceTintColor: Color(0x00000097),
      indicatorColor: Color(0x00000096),
      indicatorShape: CircleBorder(),
      labelTextStyle:
          WidgetStatePropertyAll<TextStyle>(TextStyle(fontSize: 7.0)),
      iconTheme: WidgetStatePropertyAll<IconThemeData>(
        IconThemeData(color: Color(0x00000097)),
      ),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      overlayColor: WidgetStatePropertyAll<Color>(Color(0x00000095)),
      labelPadding: EdgeInsets.all(8),
    ).debugFillProperties(builder);

    final List<String> description = builder.properties
        .where((DiagnosticsNode node) => !node.isFiltered(DiagnosticLevel.info))
        .map((DiagnosticsNode node) => node.toString())
        .toList();

    expect(
      description,
      equalsIgnoringHashCodes(<String>[
        "height: 200.0",
        "backgroundColor: Color(alpha: 0.0000, red: 0.0000, green: 0.0000, blue: 0.6000, colorSpace: ColorSpace.sRGB)",
        "elevation: 20.0",
        "shadowColor: Color(alpha: 0.0000, red: 0.0000, green: 0.0000, blue: 0.5961, colorSpace: ColorSpace.sRGB)",
        "surfaceTintColor: Color(alpha: 0.0000, red: 0.0000, green: 0.0000, blue: 0.5922, colorSpace: ColorSpace.sRGB)",
        "indicatorColor: Color(alpha: 0.0000, red: 0.0000, green: 0.0000, blue: 0.5882, colorSpace: ColorSpace.sRGB)",
        "indicatorShape: CircleBorder(BorderSide(width: 0.0, style: none))",
        "labelTextStyle: WidgetStatePropertyAll(TextStyle(inherit: true, size: 7.0))",
        "iconTheme: WidgetStatePropertyAll(IconThemeData#fd5c3(color: Color(alpha: 0.0000, red: 0.0000, green: 0.0000, blue: 0.5922, colorSpace: ColorSpace.sRGB)))",
        "labelBehavior: NavigationDestinationLabelBehavior.alwaysHide",
        "overlayColor: WidgetStatePropertyAll(Color(alpha: 0.0000, red: 0.0000, green: 0.0000, blue: 0.5843, colorSpace: ColorSpace.sRGB))",
        "labelPadding: EdgeInsets.all(8.0)",
      ]),
    );
  });

  testWidgets(
    "[DIVERGENCE] CustomNavigationBarTheme wrapper does not override NavigationBar defaults",
    (WidgetTester tester) async {
      const backgroundColor = Color(0x00000001);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomNavigationBarTheme(
              data: CustomNavigationBarThemeData(
                height: 200,
                backgroundColor: backgroundColor,
                elevation: 42,
                indicatorColor: const Color(0x00000002),
                indicatorShape: const CircleBorder(),
                iconTheme:
                    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return const IconThemeData(size: 25);
                  }
                  return const IconThemeData(size: 23);
                }),
                labelTextStyle:
                    WidgetStateProperty.resolveWith((Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return const TextStyle(fontSize: 13);
                  }
                  return const TextStyle(fontSize: 11);
                }),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                labelPadding: const EdgeInsets.all(8),
              ),
              child: CustomNavigationBar(destinations: _destinations()),
            ),
          ),
        ),
      );

      final ThemeData defaultTheme = ThemeData();
      expect(_barHeight(tester), 80);
      expect(
        _barMaterial(tester).color,
        defaultTheme.colorScheme.surfaceContainer,
      );
      expect(_barMaterial(tester).elevation, 3);
      expect(
        _indicator(tester)?.color,
        defaultTheme.colorScheme.secondaryContainer,
      );
      expect(_indicator(tester)?.shape, const StadiumBorder());
      expect(_barMaterial(tester).color, isNot(backgroundColor));
    },
    tags: <String>["divergence"],
  );

  testWidgets(
    "NavigationBar values take priority over CustomNavigationBarThemeData values when both properties are specified",
    (WidgetTester tester) async {
      const height = 200.0;
      const backgroundColor = Color(0x00000001);
      const elevation = 42.0;
      const NavigationDestinationLabelBehavior labelBehavior =
          NavigationDestinationLabelBehavior.alwaysShow;
      const EdgeInsetsGeometry labelPadding =
          EdgeInsets.symmetric(horizontal: 16.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomNavigationBarTheme(
              data: const CustomNavigationBarThemeData(
                height: 100.0,
                elevation: 18.0,
                backgroundColor: Color(0x00000099),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                labelPadding: EdgeInsets.all(8),
              ),
              child: CustomNavigationBar(
                height: height,
                elevation: elevation,
                backgroundColor: backgroundColor,
                labelBehavior: labelBehavior,
                labelPadding: labelPadding,
                destinations: _destinations(),
              ),
            ),
          ),
        ),
      );

      expect(_barHeight(tester), height);
      expect(_barMaterial(tester).color, backgroundColor);
      expect(_barMaterial(tester).elevation, elevation);
      expect(_labelBehavior(tester), labelBehavior);
      expect(_getLabelPadding(tester, "Abc"), labelPadding);
      expect(_getLabelPadding(tester, "Def"), labelPadding);
    },
  );

  testWidgets(
    "[DIVERGENCE] Custom label style renders ink ripple state",
    (WidgetTester tester) async {
      Widget buildWidget({NavigationDestinationLabelBehavior? labelBehavior}) {
        return MaterialApp(
          theme: ThemeData(
            navigationBarTheme: const CustomNavigationBarThemeData(
              labelTextStyle: WidgetStatePropertyAll<TextStyle>(
                TextStyle(fontSize: 25, color: Color(0xff0000ff)),
              ),
            ),
          ),
          home: Scaffold(
            bottomNavigationBar: Center(
              child: CustomNavigationBar(
                labelBehavior: labelBehavior,
                destinations: const <Widget>[
                  CustomNavigationDestination(icon: SizedBox(), label: "AC"),
                  CustomNavigationDestination(icon: SizedBox(), label: "Alarm"),
                ],
                onDestinationSelected: (int i) {},
              ),
            ),
          ),
        );
      }

      await tester.pumpWidget(buildWidget());

      final TestGesture gesture =
          await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer();
      await gesture.moveTo(tester.getCenter(find.byType(CustomNavigationBar)));
      await tester.pumpAndSettle();

      final RenderObject inkFeatures = tester.allRenderObjects.firstWhere(
        (RenderObject object) =>
            object.runtimeType.toString() == "_RenderInkFeatures",
      );
      expect(
        inkFeatures,
        paints
          ..clipPath()
          ..rect(color: const Color(0x0a000000)),
      );
    },
    tags: <String>["divergence"],
  );

  testWidgets(
    "[DIVERGENCE] NavigationBar respects NavigationBarTheme.overlayColor in active/pressed/hovered states",
    (WidgetTester tester) async {
      tester.binding.focusManager.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      const hoverColor = Color(0xff0000ff);
      const focusColor = Color(0xff00ffff);
      const pressedColor = Color(0xffff00ff);
      final WidgetStateProperty<Color?> overlayColor =
          WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.hovered)) {
          return hoverColor;
        }
        if (states.contains(WidgetState.focused)) {
          return focusColor;
        }
        if (states.contains(WidgetState.pressed)) {
          return pressedColor;
        }
        return Colors.transparent;
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            navigationBarTheme:
                CustomNavigationBarThemeData(overlayColor: overlayColor),
          ),
          home: Scaffold(
            bottomNavigationBar: RepaintBoundary(
              child: CustomNavigationBar(
                destinations: const <Widget>[
                  CustomNavigationDestination(
                    icon: Icon(Icons.ac_unit),
                    label: "AC",
                  ),
                  CustomNavigationDestination(
                    icon: Icon(Icons.access_alarm),
                    label: "Alarm",
                  ),
                ],
                onDestinationSelected: (int i) {},
              ),
            ),
          ),
        ),
      );

      final TestGesture gesture =
          await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer();
      await gesture
          .moveTo(tester.getCenter(find.byType(NavigationIndicator).last));
      await tester.pumpAndSettle();

      final RenderObject inkFeatures = tester.allRenderObjects.firstWhere(
        (RenderObject object) =>
            object.runtimeType.toString() == "_RenderInkFeatures",
      );

      // Test hovered state.
      expect(
        inkFeatures,
        paints
          ..clipPath()
          ..rect(color: hoverColor),
      );

      await gesture
          .down(tester.getCenter(find.byType(NavigationIndicator).last));
      await tester.pumpAndSettle();

      // Test pressed state.
      expect(
        inkFeatures,
        paints
          ..clipPath()
          ..rect(),
      );

      await gesture.up();
      await tester.pumpAndSettle();

      // Press tab to focus the navigation bar.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // Test focused state.
      expect(
        inkFeatures,
        paints
          ..clipPath()
          ..rect(),
      );
    },
    tags: <String>["divergence"],
  );
}

List<NavigationDestination> _destinations() {
  return const <NavigationDestination>[
    CustomNavigationDestination(
      icon: Icon(Icons.favorite_border),
      selectedIcon: Icon(Icons.favorite),
      label: "Abc",
    ),
    CustomNavigationDestination(
      icon: Icon(Icons.star_border),
      selectedIcon: Icon(Icons.star),
      label: "Def",
    ),
  ];
}

double _barHeight(WidgetTester tester) {
  return tester.getRect(find.byType(CustomNavigationBar)).height;
}

Material _barMaterial(WidgetTester tester) {
  return tester.firstWidget<Material>(
    find.descendant(
      of: find.byType(CustomNavigationBar),
      matching: find.byType(Material),
    ),
  );
}

ShapeDecoration? _indicator(WidgetTester tester) {
  return tester
      .firstWidget<Ink>(
        find.descendant(
          of: find.byType(FadeTransition),
          matching: find.byType(Ink),
        ),
      )
      .decoration as ShapeDecoration?;
}

NavigationDestinationLabelBehavior _labelBehavior(WidgetTester tester) {
  if (_opacityAboveLabel("Abc").evaluate().isNotEmpty &&
      _opacityAboveLabel("Def").evaluate().isNotEmpty) {
    return _labelOpacity(tester, "Abc") == 1
        ? NavigationDestinationLabelBehavior.onlyShowSelected
        : NavigationDestinationLabelBehavior.alwaysHide;
  } else {
    return NavigationDestinationLabelBehavior.alwaysShow;
  }
}

Finder _opacityAboveLabel(String text) {
  return find.ancestor(of: find.text(text), matching: find.byType(Opacity));
}

// Only valid when labelBehavior != alwaysShow.
double _labelOpacity(WidgetTester tester, String text) {
  final Opacity opacityWidget = tester.widget<Opacity>(
    find.ancestor(of: find.text(text), matching: find.byType(Opacity)),
  );
  return opacityWidget.opacity;
}

EdgeInsetsGeometry _getLabelPadding(WidgetTester tester, String text) {
  return tester
      .widget<Padding>(
        find
            .ancestor(of: find.text(text), matching: find.byType(Padding))
            .first,
      )
      .padding;
}
