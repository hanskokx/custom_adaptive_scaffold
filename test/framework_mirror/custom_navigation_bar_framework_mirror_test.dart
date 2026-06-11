// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is run as part of a reduced test set in CI on Mac and Windows
// machines.
@Tags(<String>["reduced-test-set"])
library;

import "dart:math";

import "package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart";
import "package:flutter/foundation.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart" hide NavigationIndicator;
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  testWidgets("Navigation bar updates destinations when tapped",
      (WidgetTester tester) async {
    var mutatedIndex = -1;
    final Widget widget = _buildWidget(
      CustomNavigationBar(
        destinations: const <Widget>[
          CustomNavigationDestination(icon: Icon(Icons.ac_unit), label: "AC"),
          CustomNavigationDestination(
            icon: Icon(Icons.access_alarm),
            label: "Alarm",
          ),
        ],
        onDestinationSelected: (int i) {
          mutatedIndex = i;
        },
      ),
    );

    await tester.pumpWidget(widget);

    expect(find.text("AC"), findsOneWidget);
    expect(find.text("Alarm"), findsOneWidget);

    await tester.tap(find.text("Alarm"));
    expect(mutatedIndex, 1);

    await tester.tap(find.text("AC"));
    expect(mutatedIndex, 0);
  });

  testWidgets("NavigationBar can update background color",
      (WidgetTester tester) async {
    const Color color = Colors.yellow;

    await tester.pumpWidget(
      _buildWidget(
        CustomNavigationBar(
          backgroundColor: color,
          destinations: const <Widget>[
            CustomNavigationDestination(icon: Icon(Icons.ac_unit), label: "AC"),
            CustomNavigationDestination(
              icon: Icon(Icons.access_alarm),
              label: "Alarm",
            ),
          ],
          onDestinationSelected: (int i) {},
        ),
      ),
    );

    expect(_getMaterial(tester).color, equals(color));
  });

  testWidgets("NavigationBar can update elevation",
      (WidgetTester tester) async {
    const elevation = 42.0;

    await tester.pumpWidget(
      _buildWidget(
        CustomNavigationBar(
          elevation: elevation,
          destinations: const <Widget>[
            CustomNavigationDestination(icon: Icon(Icons.ac_unit), label: "AC"),
            CustomNavigationDestination(
              icon: Icon(Icons.access_alarm),
              label: "Alarm",
            ),
          ],
          onDestinationSelected: (int i) {},
        ),
      ),
    );

    expect(_getMaterial(tester).elevation, equals(elevation));
  });

  testWidgets("NavigationBar adds bottom padding to height",
      (WidgetTester tester) async {
    const bottomPadding = 40.0;

    await tester.pumpWidget(
      _buildWidget(
        CustomNavigationBar(
          destinations: const <Widget>[
            CustomNavigationDestination(icon: Icon(Icons.ac_unit), label: "AC"),
            CustomNavigationDestination(
              icon: Icon(Icons.access_alarm),
              label: "Alarm",
            ),
          ],
          onDestinationSelected: (int i) {},
        ),
      ),
    );

    final double defaultSize =
        tester.getSize(find.byType(CustomNavigationBar)).height;
    expect(defaultSize, 80);

    await tester.pumpWidget(
      _buildWidget(
        MediaQuery(
          data: const MediaQueryData(
            padding: EdgeInsets.only(bottom: bottomPadding),
          ),
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
    );

    final double expectedHeight = defaultSize + bottomPadding;
    expect(
      tester.getSize(find.byType(CustomNavigationBar)).height,
      expectedHeight,
    );
  });

  testWidgets(
      "NavigationBar respects the notch/system navigation bar in landscape mode",
      (
    WidgetTester tester,
  ) async {
    const safeAreaPadding = 40.0;
    Widget navigationBar() {
      return CustomNavigationBar(
        destinations: const <Widget>[
          CustomNavigationDestination(icon: Icon(Icons.ac_unit), label: "AC"),
          CustomNavigationDestination(
            key: Key("Center"),
            icon: Icon(Icons.center_focus_strong),
            label: "Center",
          ),
          CustomNavigationDestination(
            icon: Icon(Icons.access_alarm),
            label: "Alarm",
          ),
        ],
        onDestinationSelected: (int i) {},
      );
    }

    await tester.pumpWidget(_buildWidget(navigationBar()));
    final double defaultWidth =
        tester.getSize(find.byType(CustomNavigationBar)).width;
    final Finder defaultCenterItem = find.byKey(const Key("Center"));
    final Offset center = tester.getCenter(defaultCenterItem);
    expect(center.dx, defaultWidth / 2);

    await tester.pumpWidget(
      _buildWidget(
        MediaQuery(
          data: const MediaQueryData(
            padding: EdgeInsets.only(left: safeAreaPadding),
          ),
          child: navigationBar(),
        ),
      ),
    );

    // The position of center item of navigation bar should indicate whether
    // the safe area is sufficiently respected, when safe area is on the left side.
    // e.g. Android device with system navigation bar in landscape mode.
    final Finder leftPaddedCenterItem = find.byKey(const Key("Center"));
    final Offset leftPaddedCenter = tester.getCenter(leftPaddedCenterItem);
    expect(
      leftPaddedCenter.dx,
      closeTo((defaultWidth + safeAreaPadding) / 2.0, precisionErrorTolerance),
    );

    await tester.pumpWidget(
      _buildWidget(
        MediaQuery(
          data: const MediaQueryData(
            padding: EdgeInsets.only(right: safeAreaPadding),
          ),
          child: navigationBar(),
        ),
      ),
    );

    // The position of center item of navigation bar should indicate whether
    // the safe area is sufficiently respected, when safe area is on the right side.
    // e.g. Android device with system navigation bar in landscape mode.
    final Finder rightPaddedCenterItem = find.byKey(const Key("Center"));
    final Offset rightPaddedCenter = tester.getCenter(rightPaddedCenterItem);
    expect(
      rightPaddedCenter.dx,
      closeTo((defaultWidth - safeAreaPadding) / 2, precisionErrorTolerance),
    );

    await tester.pumpWidget(
      _buildWidget(
        MediaQuery(
          data: const MediaQueryData(
            padding: EdgeInsets.fromLTRB(
              safeAreaPadding,
              0,
              safeAreaPadding,
              safeAreaPadding,
            ),
          ),
          child: navigationBar(),
        ),
      ),
    );

    // The position of center item of navigation bar should indicate whether
    // the safe area is sufficiently respected, when safe areas are on both sides.
    // e.g. iOS device with both sides of round corner.
    final Finder paddedCenterItem = find.byKey(const Key("Center"));
    final Offset paddedCenter = tester.getCenter(paddedCenterItem);
    expect(paddedCenter.dx, closeTo(defaultWidth / 2, precisionErrorTolerance));
  });

  testWidgets(
    "[DIVERGENCE] Material2 - NavigationBar uses proper defaults when no parameters are given",
    (
      WidgetTester tester,
    ) async {
      // M2 settings that were hand coded.
      await tester.pumpWidget(
        _buildWidget(
          CustomNavigationBar(
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
          useMaterial3: false,
        ),
      );

      expect(_getMaterial(tester).color, const Color(0xffeaeaea));
      expect(_getMaterial(tester).surfaceTintColor, null);
      expect(_getMaterial(tester).elevation, 0);
      expect(tester.getSize(find.byType(CustomNavigationBar)).height, 80);
      final Color? indicatorColor = _getIndicatorDecoration(tester)?.color;
      const Color expectedIndicatorColor = Color(0x3d2196f3);
      expect(indicatorColor, isNotNull);
      expect(indicatorColor!.r, closeTo(expectedIndicatorColor.r, 0.0002));
      expect(indicatorColor.g, closeTo(expectedIndicatorColor.g, 0.0002));
      expect(indicatorColor.b, closeTo(expectedIndicatorColor.b, 0.0002));
      expect(indicatorColor.a, closeTo(expectedIndicatorColor.a, 0.001));
      expect(
        _getIndicatorDecoration(tester)?.shape,
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      );
    },
    tags: <String>["divergence"],
  );

  testWidgets(
      "Material3 - NavigationBar uses proper defaults when no parameters are given",
      (
    WidgetTester tester,
  ) async {
    // M3 settings from the token database.
    final theme = ThemeData();
    await tester.pumpWidget(
      _buildWidget(
        CustomNavigationBar(
          destinations: const <Widget>[
            CustomNavigationDestination(icon: Icon(Icons.ac_unit), label: "AC"),
            CustomNavigationDestination(
              icon: Icon(Icons.access_alarm),
              label: "Alarm",
            ),
          ],
          onDestinationSelected: (int i) {},
        ),
        useMaterial3: theme.useMaterial3,
      ),
    );

    expect(_getMaterial(tester).color, theme.colorScheme.surfaceContainer);
    expect(_getMaterial(tester).surfaceTintColor, Colors.transparent);
    expect(_getMaterial(tester).elevation, 3);
    expect(tester.getSize(find.byType(CustomNavigationBar)).height, 80);
    expect(
      _getIndicatorDecoration(tester)?.color,
      theme.colorScheme.secondaryContainer,
    );
    expect(_getIndicatorDecoration(tester)?.shape, const StadiumBorder());
  });

  testWidgets("Material2 - NavigationBar shows tooltips with text scaling", (
    WidgetTester tester,
  ) async {
    const label = "A";

    Widget buildApp({required TextScaler textScaler}) {
      return MediaQuery(
        data: MediaQueryData(textScaler: textScaler),
        child: Localizations(
          locale: const Locale("en", "US"),
          delegates: const <LocalizationsDelegate<dynamic>>[
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          child: MaterialApp(
            theme: ThemeData(useMaterial3: false),
            home: Navigator(
              onGenerateRoute: (RouteSettings settings) {
                return MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return Scaffold(
                      bottomNavigationBar: CustomNavigationBar(
                        destinations: const <NavigationDestination>[
                          CustomNavigationDestination(
                            label: label,
                            icon: Icon(Icons.ac_unit),
                            tooltip: label,
                          ),
                          CustomNavigationDestination(
                            label: "B",
                            icon: Icon(Icons.battery_alert),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp(textScaler: TextScaler.noScaling));
    expect(find.text(label), findsOneWidget);
    await tester.longPress(find.text(label));
    expect(find.text(label), findsNWidgets(2));

    // The default size of a tooltip with the text A.
    const defaultTooltipSize = Size(14.0, 14.0);
    expect(tester.getSize(find.text(label).last), defaultTooltipSize);
    // The duration is needed to ensure the tooltip disappears.
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.pumpWidget(buildApp(textScaler: const TextScaler.linear(4.0)));
    expect(find.text(label), findsOneWidget);
    await tester.longPress(find.text(label));
    expect(
      tester.getSize(find.text(label).last),
      Size(defaultTooltipSize.width * 4, defaultTooltipSize.height * 4),
    );
  });

  testWidgets("Material3 - NavigationBar shows tooltips with text scaling", (
    WidgetTester tester,
  ) async {
    const label = "A";

    Widget buildApp({required TextScaler textScaler}) {
      return MediaQuery(
        data: MediaQueryData(textScaler: textScaler),
        child: Localizations(
          locale: const Locale("en", "US"),
          delegates: const <LocalizationsDelegate<dynamic>>[
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          child: MaterialApp(
            home: Navigator(
              onGenerateRoute: (RouteSettings settings) {
                return MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return Scaffold(
                      bottomNavigationBar: CustomNavigationBar(
                        destinations: const <NavigationDestination>[
                          CustomNavigationDestination(
                            label: label,
                            icon: Icon(Icons.ac_unit),
                            tooltip: label,
                          ),
                          CustomNavigationDestination(
                            label: "B",
                            icon: Icon(Icons.battery_alert),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp(textScaler: TextScaler.noScaling));
    expect(find.text(label), findsOneWidget);
    await tester.longPress(find.text(label));
    expect(find.text(label), findsNWidgets(2));

    expect(tester.getSize(find.text(label).last), const Size(14.25, 20.0));
    // The duration is needed to ensure the tooltip disappears.
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.pumpWidget(buildApp(textScaler: const TextScaler.linear(4.0)));
    expect(find.text(label), findsOneWidget);
    await tester.longPress(find.text(label));

    expect(tester.getSize(find.text(label).last), const Size(56.25, 80.0));
  });

  testWidgets(
      "Material3 - NavigationBar label can scale and has maxScaleFactor", (
    WidgetTester tester,
  ) async {
    const label = "A";

    Widget buildApp({required TextScaler textScaler}) {
      return MediaQuery(
        data: MediaQueryData(textScaler: textScaler),
        child: Localizations(
          locale: const Locale("en", "US"),
          delegates: const <LocalizationsDelegate<dynamic>>[
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          child: MaterialApp(
            home: Navigator(
              onGenerateRoute: (RouteSettings settings) {
                return MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return Scaffold(
                      bottomNavigationBar: CustomNavigationBar(
                        destinations: const <NavigationDestination>[
                          CustomNavigationDestination(
                            label: label,
                            icon: Icon(Icons.ac_unit),
                          ),
                          CustomNavigationDestination(
                            label: "B",
                            icon: Icon(Icons.battery_alert),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp(textScaler: TextScaler.noScaling));
    expect(find.text(label), findsOneWidget);
    expect(
      _sizeAlmostEqual(
        tester.getSize(find.text(label)),
        const Size(12.5, 16.0),
      ),
      true,
    );

    await tester.pumpWidget(buildApp(textScaler: const TextScaler.linear(1.1)));
    await tester.pumpAndSettle();

    expect(
      _sizeAlmostEqual(
        tester.getSize(find.text(label)),
        const Size(13.7, 18.0),
      ),
      true,
    );

    await tester.pumpWidget(buildApp(textScaler: const TextScaler.linear(1.3)));

    expect(
      _sizeAlmostEqual(
        tester.getSize(find.text(label)),
        const Size(16.1, 21.0),
      ),
      true,
    );

    await tester.pumpWidget(buildApp(textScaler: const TextScaler.linear(4)));
    expect(
      _sizeAlmostEqual(
        tester.getSize(find.text(label)),
        const Size(16.1, 21.0),
      ),
      true,
    );
  });

  testWidgets(
    "[DIVERGENCE] Custom tooltips in NavigationBarDestination",
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomNavigationBar(
              destinations: const <NavigationDestination>[
                CustomNavigationDestination(
                  label: "A",
                  tooltip: "A tooltip",
                  icon: Icon(Icons.ac_unit),
                ),
                CustomNavigationDestination(
                  label: "B",
                  icon: Icon(Icons.battery_alert),
                ),
                CustomNavigationDestination(
                  label: "C",
                  icon: Icon(Icons.cake),
                  tooltip: "",
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text("A"), findsOneWidget);
      await tester.longPress(find.text("A"));
      expect(find.byTooltip("A tooltip"), findsOneWidget);

      expect(find.text("B"), findsOneWidget);
      await tester.longPress(find.text("B"));
      expect(find.byTooltip("B"), findsNothing);

      expect(find.text("C"), findsOneWidget);
      await tester.longPress(find.text("C"));
      expect(find.byTooltip("C"), findsNothing);
    },
    tags: <String>["divergence"],
  );

  testWidgets("Navigation bar semantics", (WidgetTester tester) async {
    Widget widget({int selectedIndex = 0}) {
      return _buildWidget(
        CustomNavigationBar(
          selectedIndex: selectedIndex,
          destinations: const <Widget>[
            CustomNavigationDestination(icon: Icon(Icons.ac_unit), label: "AC"),
            CustomNavigationDestination(
              icon: Icon(Icons.access_alarm),
              label: "Alarm",
            ),
            CustomNavigationDestination(icon: Icon(Icons.abc), label: "ABC"),
          ],
        ),
      );
    }

    await tester.pumpWidget(widget());

    expect(
      tester.getSemantics(find.text("AC")),
      matchesSemantics(
        label: 'AC${kIsWeb ? '' : '\nTab 1 of 3'}',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        isSelected: true,
        isButton: true,
        hasSelectedState: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.text("Alarm")),
      matchesSemantics(
        label: 'Alarm${kIsWeb ? '' : '\nTab 2 of 3'}',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        isButton: true,
        hasSelectedState: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.text("ABC")),
      matchesSemantics(
        label: 'ABC${kIsWeb ? '' : '\nTab 3 of 3'}',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        isButton: true,
        hasSelectedState: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );

    await tester.pumpWidget(widget(selectedIndex: 1));

    expect(
      tester.getSemantics(find.text("AC")),
      matchesSemantics(
        label: 'AC${kIsWeb ? '' : '\nTab 1 of 3'}',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        isButton: true,
        hasEnabledState: true,
        hasSelectedState: true,
        isEnabled: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.text("Alarm")),
      matchesSemantics(
        label: 'Alarm${kIsWeb ? '' : '\nTab 2 of 3'}',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        isSelected: true,
        isButton: true,
        hasEnabledState: true,
        hasSelectedState: true,
        isEnabled: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.text("ABC")),
      matchesSemantics(
        label: 'ABC${kIsWeb ? '' : '\nTab 3 of 3'}',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        isButton: true,
        hasEnabledState: true,
        hasSelectedState: true,
        isEnabled: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
  });
  testWidgets("Navigation bar disabled semantics", (WidgetTester tester) async {
    Widget widget({int selectedIndex = 0}) {
      return _buildWidget(
        CustomNavigationBar(
          selectedIndex: selectedIndex,
          destinations: const <Widget>[
            CustomNavigationDestination(
              icon: Icon(Icons.ac_unit),
              label: "AC",
              enabled: false,
            ),
            CustomNavigationDestination(
              icon: Icon(Icons.ac_unit),
              label: "Another",
            ),
          ],
        ),
      );
    }

    await tester.pumpWidget(widget());

    expect(
      tester.getSemantics(find.text("AC")),
      matchesSemantics(
        label: 'AC${kIsWeb ? '' : '\nTab 1 of 2'}',
        textDirection: TextDirection.ltr,
        isSelected: true,
        hasSelectedState: true,
        hasEnabledState: true,
        isButton: true,
      ),
    );
  });

  testWidgets("Navigation bar semantics with some labels hidden",
      (WidgetTester tester) async {
    Widget widget({int selectedIndex = 0}) {
      return _buildWidget(
        CustomNavigationBar(
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          selectedIndex: selectedIndex,
          destinations: const <Widget>[
            CustomNavigationDestination(icon: Icon(Icons.ac_unit), label: "AC"),
            CustomNavigationDestination(
              icon: Icon(Icons.access_alarm),
              label: "Alarm",
            ),
          ],
        ),
      );
    }

    await tester.pumpWidget(widget());

    expect(
      tester.getSemantics(find.text("AC")),
      matchesSemantics(
        label: 'AC${kIsWeb ? '' : '\nTab 1 of 2'}',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        isSelected: true,
        isButton: true,
        hasEnabledState: true,
        hasSelectedState: true,
        isEnabled: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.text("Alarm")),
      matchesSemantics(
        label: 'Alarm${kIsWeb ? '' : '\nTab 2 of 2'}',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        isButton: true,
        hasEnabledState: true,
        hasSelectedState: true,
        isEnabled: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );

    await tester.pumpWidget(widget(selectedIndex: 1));

    expect(
      tester.getSemantics(find.text("AC")),
      matchesSemantics(
        label: 'AC${kIsWeb ? '' : '\nTab 1 of 2'}',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        isButton: true,
        hasEnabledState: true,
        hasSelectedState: true,
        isEnabled: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.text("Alarm")),
      matchesSemantics(
        label: 'Alarm${kIsWeb ? '' : '\nTab 2 of 2'}',
        textDirection: TextDirection.ltr,
        isFocusable: true,
        hasEnabledState: true,
        hasSelectedState: true,
        isEnabled: true,
        isSelected: true,
        isButton: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
  });

  testWidgets("Navigation bar does not grow with text scale factor",
      (WidgetTester tester) async {
    const animationMilliseconds = 800;

    Widget widget({TextScaler textScaler = TextScaler.noScaling}) {
      return _buildWidget(
        MediaQuery(
          data: MediaQueryData(textScaler: textScaler),
          child: CustomNavigationBar(
            animationDuration:
                const Duration(milliseconds: animationMilliseconds),
            destinations: const <NavigationDestination>[
              CustomNavigationDestination(
                icon: Icon(Icons.ac_unit),
                label: "AC",
              ),
              CustomNavigationDestination(
                icon: Icon(Icons.access_alarm),
                label: "Alarm",
              ),
            ],
          ),
        ),
      );
    }

    await tester.pumpWidget(widget());
    final double initialHeight =
        tester.getSize(find.byType(CustomNavigationBar)).height;

    await tester.pumpWidget(widget(textScaler: const TextScaler.linear(2)));
    final double newHeight =
        tester.getSize(find.byType(CustomNavigationBar)).height;

    expect(newHeight, equals(initialHeight));
  });

  testWidgets(
    "[DIVERGENCE] Material3 - Navigation indicator renders ripple",
    (WidgetTester tester) async {
      // This is a regression test for https://github.com/flutter/flutter/issues/116751.
      var selectedIndex = 0;

      Widget buildWidget({NavigationDestinationLabelBehavior? labelBehavior}) {
        return MaterialApp(
          home: Scaffold(
            bottomNavigationBar: Center(
              child: CustomNavigationBar(
                selectedIndex: selectedIndex,
                labelBehavior: labelBehavior,
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
        );
      }

      await tester.pumpWidget(buildWidget());

      final TestGesture gesture =
          await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer();
      await gesture.moveTo(tester.getCenter(find.byIcon(Icons.access_alarm)));
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

      // Test ripple when NavigationBar is using `NavigationDestinationLabelBehavior.alwaysHide`.
      await tester.pumpWidget(
        buildWidget(
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        ),
      );
      await gesture.moveTo(tester.getCenter(find.byIcon(Icons.access_alarm)));
      await tester.pumpAndSettle();

      expect(
        inkFeatures,
        paints
          ..clipPath()
          ..rect(color: const Color(0x0a000000)),
      );

      // Test ripple when NavigationBar is using `NavigationDestinationLabelBehavior.onlyShowSelected`.
      await tester.pumpWidget(
        buildWidget(
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        ),
      );
      await gesture.moveTo(tester.getCenter(find.byIcon(Icons.access_alarm)));
      await tester.pumpAndSettle();

      expect(
        inkFeatures,
        paints
          ..clipPath()
          ..rect(color: const Color(0x0a000000)),
      );

      // Make sure ripple is shifted when selectedIndex changes.
      selectedIndex = 1;
      await tester.pumpWidget(
        buildWidget(
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        ),
      );
      await tester.pumpAndSettle();
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
    "[DIVERGENCE] Material3 - Navigation indicator ripple state test",
    (WidgetTester tester) async {
      // This is a regression test for https://github.com/flutter/flutter/issues/117420.

      Widget buildWidget({NavigationDestinationLabelBehavior? labelBehavior}) {
        return MaterialApp(
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

      // Test ripple when NavigationBar is using `NavigationDestinationLabelBehavior.alwaysHide`.
      await tester.pumpWidget(
        buildWidget(
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        ),
      );
      await gesture.moveTo(tester.getCenter(find.byType(CustomNavigationBar)));
      await tester.pumpAndSettle();
      expect(
        inkFeatures,
        paints
          ..clipPath()
          ..rect(color: const Color(0x0a000000)),
      );

      // Test ripple when NavigationBar is using `NavigationDestinationLabelBehavior.onlyShowSelected`.
      await tester.pumpWidget(
        buildWidget(
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        ),
      );
      await gesture.moveTo(tester.getCenter(find.byType(CustomNavigationBar)));
      await tester.pumpAndSettle();
      expect(
        inkFeatures,
        paints
          ..clipPath()
          ..rect(color: const Color(0x0a000000)),
      );
    },
    tags: <String>["divergence"],
  );

  // Regression test for https://github.com/flutter/flutter/issues/169249.
  testWidgets(
    "[DIVERGENCE] Material3 - Navigation indicator moves to selected item",
    (
      WidgetTester tester,
    ) async {
      final theme = ThemeData();
      var index = 0;

      Widget buildCustomNavigationBar({
        Color? indicatorColor,
        ShapeBorder? indicatorShape,
      }) {
        return MaterialApp(
          theme: theme,
          home: Scaffold(
            bottomNavigationBar: RepaintBoundary(
              child: CustomNavigationBar(
                indicatorColor: indicatorColor,
                indicatorShape: indicatorShape,
                selectedIndex: index,
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
        );
      }

      await tester.pumpWidget(buildCustomNavigationBar());
      final List<double> beforeScales = tester
          .widgetList<Transform>(
            find.descendant(
              of: find.byType(NavigationIndicator),
              matching: find.byType(Transform),
            ),
          )
          .map((Transform transform) => transform.transform.getColumn(0)[0])
          .toList();

      // Move the selection to the second destination.
      index = 1;
      await tester.pumpWidget(buildCustomNavigationBar());
      await tester.pumpAndSettle();

      final List<double> afterScales = tester
          .widgetList<Transform>(
            find.descendant(
              of: find.byType(NavigationIndicator),
              matching: find.byType(Transform),
            ),
          )
          .map((Transform transform) => transform.transform.getColumn(0)[0])
          .toList();
      expect(beforeScales.length, 2);
      expect(afterScales.length, 2);
      expect(beforeScales[0], greaterThan(beforeScales[1]));
      expect(afterScales[1], greaterThan(afterScales[0]));
    },
    tags: <String>["divergence"],
  );

  testWidgets("Navigation indicator scale transform",
      (WidgetTester tester) async {
    var selectedIndex = 0;

    Widget buildCustomNavigationBar() {
      return MaterialApp(
        home: Scaffold(
          bottomNavigationBar: Center(
            child: CustomNavigationBar(
              selectedIndex: selectedIndex,
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
      );
    }

    await tester.pumpWidget(buildCustomNavigationBar());
    await tester.pumpAndSettle();
    final Finder transformFinder = find
        .descendant(
          of: find.byType(NavigationIndicator),
          matching: find.byType(Transform),
        )
        .last;
    Matrix4 transform = tester.widget<Transform>(transformFinder).transform;
    expect(transform.getColumn(0)[0], 0.0);

    selectedIndex = 1;
    await tester.pumpWidget(buildCustomNavigationBar());
    await tester.pump(const Duration(milliseconds: 100));
    transform = tester.widget<Transform>(transformFinder).transform;
    expect(
      transform.getColumn(0)[0],
      closeTo(0.7805849514007568, precisionErrorTolerance),
    );

    await tester.pump(const Duration(milliseconds: 100));
    transform = tester.widget<Transform>(transformFinder).transform;
    expect(
      transform.getColumn(0)[0],
      closeTo(0.9473570239543915, precisionErrorTolerance),
    );

    await tester.pumpAndSettle();
    transform = tester.widget<Transform>(transformFinder).transform;
    expect(transform.getColumn(0)[0], 1.0);
  });

  testWidgets(
    "[DIVERGENCE] Material3 - Navigation destination updates indicator color and shape",
    (
      WidgetTester tester,
    ) async {
      final theme = ThemeData();
      const color = Color(0xff0000ff);
      const ShapeBorder shape = RoundedRectangleBorder();

      Widget buildCustomNavigationBar({
        Color? indicatorColor,
        ShapeBorder? indicatorShape,
      }) {
        return MaterialApp(
          theme: theme,
          home: Scaffold(
            bottomNavigationBar: RepaintBoundary(
              child: CustomNavigationBar(
                indicatorColor: indicatorColor,
                indicatorShape: indicatorShape,
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
        );
      }

      await tester.pumpWidget(buildCustomNavigationBar());

      // Test default indicator color and shape.
      expect(
        _getIndicatorDecoration(tester)?.color,
        theme.colorScheme.secondaryContainer,
      );
      expect(_getIndicatorDecoration(tester)?.shape, const StadiumBorder());

      final TestGesture gesture =
          await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer();
      await gesture
          .moveTo(tester.getCenter(find.byType(NavigationIndicator).last));
      await tester.pumpAndSettle();

      // Test default indicator color and shape with ripple.
      final RenderObject defaultInkFeatures =
          tester.allRenderObjects.firstWhere(
        (RenderObject object) =>
            object.runtimeType.toString() == "_RenderInkFeatures",
      );
      expect(
        defaultInkFeatures,
        paints
          ..clipPath()
          ..rect(),
      );

      await tester.pumpWidget(
        buildCustomNavigationBar(indicatorColor: color, indicatorShape: shape),
      );

      // Test custom indicator color and shape.
      expect(_getIndicatorDecoration(tester)?.color, color);
      expect(_getIndicatorDecoration(tester)?.shape, shape);

      // Test custom indicator color and shape with ripple.
      final RenderObject customInkFeatures = tester.allRenderObjects.firstWhere(
        (RenderObject object) =>
            object.runtimeType.toString() == "_RenderInkFeatures",
      );
      expect(
        customInkFeatures,
        paints
          ..clipPath()
          ..rect(),
      );
    },
    tags: <String>["divergence"],
  );

  testWidgets("Destinations respect their disabled state",
      (WidgetTester tester) async {
    var selectedIndex = 0;

    await tester.pumpWidget(
      _buildWidget(
        CustomNavigationBar(
          destinations: const <Widget>[
            CustomNavigationDestination(icon: Icon(Icons.ac_unit), label: "AC"),
            CustomNavigationDestination(
              icon: Icon(Icons.access_alarm),
              label: "Alarm",
            ),
            CustomNavigationDestination(
              icon: Icon(Icons.bookmark),
              label: "Bookmark",
              enabled: false,
            ),
          ],
          onDestinationSelected: (int i) => selectedIndex = i,
          selectedIndex: selectedIndex,
        ),
      ),
    );

    await tester.tap(find.text("AC"));
    expect(selectedIndex, 0);

    await tester.tap(find.text("Alarm"));
    expect(selectedIndex, 1);

    await tester.tap(find.text("Bookmark"));
    expect(selectedIndex, 1);
  });

  testWidgets(
    "[DIVERGENCE] NavigationBar respects overlayColor in active/pressed/hovered states",
    (
      WidgetTester tester,
    ) async {
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
          home: Scaffold(
            bottomNavigationBar: RepaintBoundary(
              child: CustomNavigationBar(
                overlayColor: overlayColor,
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

  testWidgets(
      "NavigationBar.labelPadding overrides NavigationDestination.label padding",
      (
    WidgetTester tester,
  ) async {
    const EdgeInsetsGeometry labelPadding = EdgeInsets.all(8);
    Widget buildCustomNavigationBar({EdgeInsetsGeometry? labelPadding}) {
      return MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomNavigationBar(
            labelPadding: labelPadding,
            destinations: const <Widget>[
              CustomNavigationDestination(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              CustomNavigationDestination(
                icon: Icon(Icons.settings),
                label: "Settings",
              ),
            ],
            onDestinationSelected: (int i) {},
          ),
        ),
      );
    }

    await tester.pumpWidget(buildCustomNavigationBar());
    expect(_getLabelPadding(tester, "Home"), const EdgeInsets.only(top: 4));
    expect(_getLabelPadding(tester, "Settings"), const EdgeInsets.only(top: 4));

    await tester
        .pumpWidget(buildCustomNavigationBar(labelPadding: labelPadding));
    expect(_getLabelPadding(tester, "Home"), labelPadding);
    expect(_getLabelPadding(tester, "Settings"), labelPadding);
  });

  group("Material 2", () {
    // These tests are only relevant for Material 2. Once Material 2
    // support is deprecated and the APIs are removed, these tests
    // can be deleted.

    testWidgets(
        "Material2 - Navigation destination updates indicator color and shape",
        (
      WidgetTester tester,
    ) async {
      final theme = ThemeData(useMaterial3: false);
      const color = Color(0xff0000ff);
      const ShapeBorder shape = RoundedRectangleBorder();

      Widget buildCustomNavigationBar({
        Color? indicatorColor,
        ShapeBorder? indicatorShape,
      }) {
        return MaterialApp(
          theme: theme,
          home: Scaffold(
            bottomNavigationBar: CustomNavigationBar(
              indicatorColor: indicatorColor,
              indicatorShape: indicatorShape,
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
        );
      }

      await tester.pumpWidget(buildCustomNavigationBar());

      // Test default indicator color and shape.
      expect(
        _getIndicatorDecoration(tester)?.color,
        theme.colorScheme.secondary.withValues(alpha: 0.24),
      );
      expect(
        _getIndicatorDecoration(tester)?.shape,
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      );

      await tester.pumpWidget(
        buildCustomNavigationBar(
          indicatorColor: color,
          indicatorShape: shape,
        ),
      );

      // Test custom indicator color and shape.
      expect(_getIndicatorDecoration(tester)?.color, color);
      expect(_getIndicatorDecoration(tester)?.shape, shape);
    });

    testWidgets(
      "[DIVERGENCE] Material2 - Navigation indicator renders ripple",
      (WidgetTester tester) async {
        // This is a regression test for https://github.com/flutter/flutter/issues/116751.
        var selectedIndex = 0;

        Widget buildWidget({
          NavigationDestinationLabelBehavior? labelBehavior,
        }) {
          return MaterialApp(
            theme: ThemeData(useMaterial3: false),
            home: Scaffold(
              bottomNavigationBar: Center(
                child: CustomNavigationBar(
                  selectedIndex: selectedIndex,
                  labelBehavior: labelBehavior,
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
          );
        }

        await tester.pumpWidget(buildWidget());

        final TestGesture gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer();
        await gesture.moveTo(tester.getCenter(find.byIcon(Icons.access_alarm)));
        await tester.pumpAndSettle();

        final RenderObject inkFeatures = tester.allRenderObjects.firstWhere(
          (RenderObject object) =>
              object.runtimeType.toString() == "_RenderInkFeatures",
        );
        // Test ripple when NavigationBar is using `NavigationDestinationLabelBehavior.alwaysShow` (default).
        expect(
          inkFeatures,
          paints
            ..clipPath()
            ..rect(color: const Color(0x0a000000)),
        );

        // Test ripple when NavigationBar is using `NavigationDestinationLabelBehavior.alwaysHide`.
        await tester.pumpWidget(
          buildWidget(
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          ),
        );
        await gesture.moveTo(tester.getCenter(find.byIcon(Icons.access_alarm)));
        await tester.pumpAndSettle();

        expect(
          inkFeatures,
          paints
            ..clipPath()
            ..rect(color: const Color(0x0a000000)),
        );

        // Test ripple when NavigationBar is using `NavigationDestinationLabelBehavior.onlyShowSelected`.
        await tester.pumpWidget(
          buildWidget(
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          ),
        );
        await gesture.moveTo(tester.getCenter(find.byIcon(Icons.access_alarm)));
        await tester.pumpAndSettle();

        expect(
          inkFeatures,
          paints
            ..clipPath()
            ..rect(color: const Color(0x0a000000)),
        );

        // Make sure ripple is shifted when selectedIndex changes.
        selectedIndex = 1;
        await tester.pumpWidget(
          buildWidget(
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          ),
        );
        await tester.pumpAndSettle();
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
      "[DIVERGENCE] Material2 - Navigation indicator ripple state test",
      (WidgetTester tester) async {
        // This is a regression test for https://github.com/flutter/flutter/issues/117420.

        Widget buildWidget({
          NavigationDestinationLabelBehavior? labelBehavior,
        }) {
          return MaterialApp(
            theme: ThemeData(useMaterial3: false),
            home: Scaffold(
              bottomNavigationBar: Center(
                child: CustomNavigationBar(
                  labelBehavior: labelBehavior,
                  destinations: const <Widget>[
                    CustomNavigationDestination(icon: SizedBox(), label: "AC"),
                    CustomNavigationDestination(
                      icon: SizedBox(),
                      label: "Alarm",
                    ),
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
        await gesture
            .moveTo(tester.getCenter(find.byType(CustomNavigationBar)));
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

        // Test ripple when NavigationBar is using `NavigationDestinationLabelBehavior.alwaysHide`.
        await tester.pumpWidget(
          buildWidget(
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          ),
        );
        await gesture
            .moveTo(tester.getCenter(find.byType(CustomNavigationBar)));
        await tester.pumpAndSettle();
        expect(
          inkFeatures,
          paints
            ..clipPath()
            ..rect(color: const Color(0x0a000000)),
        );

        // Test ripple when NavigationBar is using `NavigationDestinationLabelBehavior.onlyShowSelected`.
        await tester.pumpWidget(
          buildWidget(
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          ),
        );
        await gesture
            .moveTo(tester.getCenter(find.byType(CustomNavigationBar)));
        await tester.pumpAndSettle();
        expect(
          inkFeatures,
          paints
            ..clipPath()
            ..rect(color: const Color(0x0a000000)),
        );
      },
      tags: <String>["divergence"],
    );

    testWidgets("Destination icon does not rebuild when tapped",
        (WidgetTester tester) async {
      // This is a regression test for https://github.com/flutter/flutter/issues/122811.

      Widget buildCustomNavigationBar() {
        return MaterialApp(
          home: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                var selectedIndex = 0;
                return CustomNavigationBar(
                  selectedIndex: selectedIndex,
                  destinations: const <Widget>[
                    CustomNavigationDestination(
                      icon: IconWithRandomColor(icon: Icons.ac_unit),
                      label: "AC",
                    ),
                    CustomNavigationDestination(
                      icon: IconWithRandomColor(icon: Icons.access_alarm),
                      label: "Alarm",
                    ),
                  ],
                  onDestinationSelected: (int i) {
                    setState(() {
                      selectedIndex = i;
                    });
                  },
                );
              },
            ),
          ),
        );
      }

      await tester.pumpWidget(buildCustomNavigationBar());
      Icon icon = tester.widget<Icon>(find.byType(Icon).last);
      final Color initialColor = icon.color!;

      // Trigger a rebuild.
      await tester.tap(find.text("Alarm"));
      await tester.pumpAndSettle();

      // Icon color should be the same as before the rebuild.
      icon = tester.widget<Icon>(find.byType(Icon).last);
      expect(icon.color, initialColor);
    });
  });

  testWidgets(
      "NavigationBar.labelPadding overrides NavigationDestination.label padding",
      (
    WidgetTester tester,
  ) async {
    const selectedText = "Home";
    const unselectedText = "Settings";
    const EdgeInsetsGeometry labelPadding = EdgeInsets.all(8);
    Widget buildCustomNavigationBar({EdgeInsetsGeometry? labelPadding}) {
      return MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomNavigationBar(
            labelPadding: labelPadding,
            destinations: const <Widget>[
              CustomNavigationDestination(
                icon: Icon(Icons.home),
                label: selectedText,
              ),
              CustomNavigationDestination(
                icon: Icon(Icons.settings),
                label: unselectedText,
              ),
            ],
            onDestinationSelected: (int i) {},
          ),
        ),
      );
    }

    await tester.pumpWidget(buildCustomNavigationBar());
    expect(
      _getLabelPadding(tester, selectedText),
      const EdgeInsets.only(top: 4),
    );
    expect(
      _getLabelPadding(tester, unselectedText),
      const EdgeInsets.only(top: 4),
    );

    await tester
        .pumpWidget(buildCustomNavigationBar(labelPadding: labelPadding));
    expect(_getLabelPadding(tester, selectedText), labelPadding);
    expect(_getLabelPadding(tester, unselectedText), labelPadding);
  });

  testWidgets(
      "NavigationBar.labelTextStyle overrides NavigationDestination.label text style",
      (
    WidgetTester tester,
  ) async {
    const selectedText = "Home";
    const unselectedText = "Settings";
    const disabledText = "Bookmark";
    final theme = ThemeData();
    Widget buildCustomNavigationBar({
      WidgetStateProperty<TextStyle?>? labelTextStyle,
    }) {
      return MaterialApp(
        theme: theme,
        home: Scaffold(
          bottomNavigationBar: CustomNavigationBar(
            labelTextStyle: labelTextStyle,
            destinations: const <Widget>[
              CustomNavigationDestination(
                icon: Icon(Icons.home),
                label: selectedText,
              ),
              CustomNavigationDestination(
                icon: Icon(Icons.settings),
                label: unselectedText,
              ),
              CustomNavigationDestination(
                enabled: false,
                icon: Icon(Icons.bookmark),
                label: disabledText,
              ),
            ],
          ),
        ),
      );
    }

    await tester.pumpWidget(buildCustomNavigationBar());

    // Test selected label text style.
    expect(_getLabelStyle(tester, selectedText).fontSize, equals(12.0));
    expect(
      _getLabelStyle(tester, selectedText).color,
      equals(theme.colorScheme.onSurface),
    );

    // Test unselected label text style.
    expect(_getLabelStyle(tester, unselectedText).fontSize, equals(12.0));
    expect(
      _getLabelStyle(tester, unselectedText).color,
      equals(theme.colorScheme.onSurfaceVariant),
    );

    // Test disabled label text style.
    expect(_getLabelStyle(tester, disabledText).fontSize, equals(12.0));
    expect(
      _getLabelStyle(tester, disabledText).color,
      equals(theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.38)),
    );

    const selectedTextStyle = TextStyle(fontSize: 15, color: Color(0xFF00FF00));
    const unselectedTextStyle =
        TextStyle(fontSize: 15, color: Color(0xFF0000FF));
    const disabledTextStyle = TextStyle(fontSize: 16, color: Color(0xFFFF0000));
    await tester.pumpWidget(
      buildCustomNavigationBar(
        labelTextStyle: const WidgetStateProperty<
            TextStyle?>.fromMap(<WidgetStatesConstraint, TextStyle?>{
          WidgetState.disabled: disabledTextStyle,
          WidgetState.selected: selectedTextStyle,
          WidgetState.any: unselectedTextStyle,
        }),
      ),
    );

    // Test selected label text style.
    expect(
      _getLabelStyle(tester, selectedText).fontSize,
      equals(selectedTextStyle.fontSize),
    );
    expect(
      _getLabelStyle(tester, selectedText).color,
      equals(selectedTextStyle.color),
    );

    // Test unselected label text style.
    expect(
      _getLabelStyle(tester, unselectedText).fontSize,
      equals(unselectedTextStyle.fontSize),
    );
    expect(
      _getLabelStyle(tester, unselectedText).color,
      equals(unselectedTextStyle.color),
    );

    // Test disabled label text style.
    expect(
      _getLabelStyle(tester, disabledText).fontSize,
      equals(disabledTextStyle.fontSize),
    );
    expect(
      _getLabelStyle(tester, disabledText).color,
      equals(disabledTextStyle.color),
    );
  });

  testWidgets(
      "NavigationBar.maintainBottomViewPadding can consume bottom MediaQuery.padding",
      (
    WidgetTester tester,
  ) async {
    const double bottomPadding = 40;
    const TextDirection textDirection = TextDirection.ltr;

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: textDirection,
          child: MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.only(bottom: bottomPadding),
            ),
            child: Scaffold(
              bottomNavigationBar: CustomNavigationBar(
                maintainBottomViewPadding: true,
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
              ),
            ),
          ),
        ),
      ),
    );

    final double safeAreaBottomPadding = tester
        .widget<Padding>(find.byType(Padding).first)
        .padding
        .resolve(textDirection)
        .bottom;
    expect(safeAreaBottomPadding, equals(0));
  });

  testWidgets("NavigationBar does not crash at zero area",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox.shrink(
            child: CustomNavigationBar(
              destinations: const <Widget>[
                CustomNavigationDestination(icon: Icon(Icons.add), label: "X"),
                CustomNavigationDestination(icon: Icon(Icons.abc), label: "Y"),
              ],
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(CustomNavigationBar)), Size.zero);
  });
}

Widget _buildWidget(Widget child, {bool? useMaterial3}) {
  return MaterialApp(
    theme: ThemeData(useMaterial3: useMaterial3),
    home: Scaffold(bottomNavigationBar: Center(child: child)),
  );
}

Material _getMaterial(WidgetTester tester) {
  return tester.firstWidget<Material>(
    find.descendant(
      of: find.byType(CustomNavigationBar),
      matching: find.byType(Material),
    ),
  );
}

ShapeDecoration? _getIndicatorDecoration(WidgetTester tester) {
  return tester
      .firstWidget<Ink>(
        find.descendant(
          of: find.byType(FadeTransition),
          matching: find.byType(Ink),
        ),
      )
      .decoration as ShapeDecoration?;
}

class IconWithRandomColor extends StatelessWidget {
  const IconWithRandomColor({required this.icon, super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final Color randomColor = Color(
      (Random().nextDouble() * 0xFFFFFF).toInt(),
    ).withValues(alpha: 1.0);
    return Icon(icon, color: randomColor);
  }
}

bool _sizeAlmostEqual(Size a, Size b, {double maxDiff = 0.05}) {
  return (a.width - b.width).abs() <= maxDiff &&
      (a.height - b.height).abs() <= maxDiff;
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

TextStyle _getLabelStyle(WidgetTester tester, String text) {
  return tester
      .widget<RichText>(
        find.descendant(of: find.text(text), matching: find.byType(RichText)),
      )
      .text
      .style!;
}
