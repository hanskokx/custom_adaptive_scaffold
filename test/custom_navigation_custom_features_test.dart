import "package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  testWidgets("transitionBuilder takes precedence over iconBuilder", (
    WidgetTester tester,
  ) async {
    const transitionKey = ValueKey<String>("transition_output");
    const iconBuilderKey = ValueKey<String>("icon_builder_output");

    Widget iconBuilder(
      BuildContext context,
      Animation<double> animation,
      bool isSelecting,
      Widget unselected,
      Widget selected,
    ) {
      return const SizedBox(key: iconBuilderKey);
    }

    Widget transitionBuilder(
      BuildContext context,
      Animation<double> animation,
      bool isSelecting,
      Widget unselectedIcon,
      Widget selectedIcon,
      Widget unselectedLabel,
      Widget selectedLabel,
    ) {
      return const SizedBox(key: transitionKey);
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomNavigationBar(
            selectedIndex: 0,
            destinations: <Widget>[
              CustomNavigationDestination(
                icon: const Icon(Icons.home_outlined),
                label: "Home",
                iconBuilder: iconBuilder,
                transitionBuilder: transitionBuilder,
              ),
              const CustomNavigationDestination(
                icon: Icon(Icons.settings_outlined),
                label: "Settings",
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byKey(transitionKey), findsOneWidget);
    expect(find.byKey(iconBuilderKey), findsNothing);
  });

  testWidgets(
      "tooltipVerticalOffset is exposed through CustomNavigationBarTheme", (
    WidgetTester tester,
  ) async {
    const offset = 88.0;
    double? resolvedOffset;

    await tester.pumpWidget(
      MaterialApp(
        home: CustomNavigationBarTheme(
          data: const CustomNavigationBarThemeData(
            tooltipVerticalOffset: offset,
          ),
          child: Builder(
            builder: (BuildContext context) {
              final NavigationBarThemeData theme =
                  CustomNavigationBarTheme.of(context);
              expect(theme, isA<CustomNavigationBarThemeData>());
              resolvedOffset =
                  (theme as CustomNavigationBarThemeData).tooltipVerticalOffset;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(resolvedOffset, offset);
  });

  testWidgets("destinationTransitionBuilder is used by CustomNavigationRail", (
    WidgetTester tester,
  ) async {
    const transitionKey = ValueKey<String>("rail_transition_output");

    Widget transitionBuilder(
      BuildContext context,
      Animation<double> animation,
      bool isSelecting,
      Widget unselectedIcon,
      Widget selectedIcon,
      Widget unselectedLabel,
      Widget selectedLabel,
    ) {
      return const SizedBox(key: transitionKey);
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomNavigationRail(
            selectedIndex: 0,
            destinationTransitionBuilder: transitionBuilder,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text("Home"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text("Settings"),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byKey(transitionKey), findsNWidgets(2));
  });

  testWidgets("rail tooltips appear on long-press and secondary click", (
    WidgetTester tester,
  ) async {
    const railFallbackTooltip = "rail_settings_tooltip";

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomNavigationRail(
            selectedIndex: 0,
            destinations: const <NavigationRailDestination>[
              CustomNavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text("Home"),
                tooltip: "Go home",
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text(railFallbackTooltip),
              ),
            ],
          ),
        ),
      ),
    );

    final TestGesture hoverMouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await hoverMouse.addPointer(location: Offset.zero);
    await hoverMouse.moveTo(
      tester.getCenter(find.byIcon(Icons.settings_outlined)),
    );
    await tester.pumpAndSettle();

    final TooltipVisibility railTooltipVisibility =
        tester.widget<TooltipVisibility>(
      find
          .ancestor(
            of: find.byIcon(Icons.settings_outlined),
            matching: find.byType(TooltipVisibility),
          )
          .first,
    );
    expect(railTooltipVisibility.visible, isFalse);

    await tester.longPress(find.byIcon(Icons.home));
    await tester.pumpAndSettle();
    expect(find.byTooltip("Go home"), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));

    final Offset secondaryClickTarget =
        tester.getCenter(find.byIcon(Icons.settings_outlined));
    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await mouse.down(secondaryClickTarget);
    await mouse.up();
    await tester.pumpAndSettle();

    expect(find.byTooltip(railFallbackTooltip), findsOneWidget);

    final Tooltip railTooltip =
        tester.widget<Tooltip>(find.byType(Tooltip).first);
    expect(railTooltip.triggerMode, TooltipTriggerMode.manual);
    expect(railTooltip.preferBelow, isFalse);
    expect(railTooltip.verticalOffset, 12);
  });

  testWidgets("bar tooltips appear on long-press and secondary click", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomNavigationBar(
            selectedIndex: 0,
            destinations: const <Widget>[
              CustomNavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: "Home",
                tooltip: "Go home",
              ),
              CustomNavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: "Settings",
              ),
            ],
          ),
        ),
      ),
    );

    final TestGesture hoverMouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    await hoverMouse.addPointer(location: Offset.zero);
    await hoverMouse.moveTo(
      tester.getCenter(find.byIcon(Icons.settings_outlined)),
    );
    await tester.pumpAndSettle();

    expect(
      find.ancestor(
        of: find.byIcon(Icons.settings_outlined),
        matching: find.byType(TooltipVisibility),
      ),
      findsNothing,
    );

    await tester.longPress(find.byIcon(Icons.home));
    await tester.pumpAndSettle();
    expect(find.byTooltip("Go home"), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));

    final Offset secondaryClickTarget =
        tester.getCenter(find.byIcon(Icons.settings_outlined));
    final TestGesture mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await mouse.down(secondaryClickTarget);
    await mouse.up();
    await tester.pumpAndSettle();

    expect(find.byTooltip("Settings"), findsNothing);
  });

  testWidgets(
      "fullWidget fill mode expands interaction rect for all rail destinations",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: CustomNavigationRail(
            selectedIndex: 0,
            destinationFillRegion: NavigationDestinationRegion.full,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text("Home"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: Text("Search"),
              ),
            ],
          ),
        ),
      ),
    );

    final Finder inkResponses = find.byWidgetPredicate(
      (Widget widget) => widget.runtimeType.toString() == "_IndicatorInkWell",
    );
    expect(inkResponses, findsNWidgets(2));

    for (int i = 0; i < 2; i++) {
      final InkResponse ink = tester.widget<InkResponse>(inkResponses.at(i));
      final RenderBox box = tester.renderObject<RenderBox>(inkResponses.at(i));
      final RectCallback? rectCallback = ink.getRectCallback(box);

      expect(rectCallback, isNotNull);
      final Rect rect = rectCallback!();
      expect(rect.left, 0);
      expect(rect.width, box.size.width);
      expect(rect.height, box.size.height);
    }
  });

  testWidgets("icon fill mode keeps indicator-sized interaction rect",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: CustomNavigationRail(
            selectedIndex: 0,
            destinationFillRegion: NavigationDestinationRegion.icon,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text("Home"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: Text("Search"),
              ),
            ],
          ),
        ),
      ),
    );

    final Finder inkResponses = find.byWidgetPredicate(
      (Widget widget) => widget is InkResponse,
    );
    expect(inkResponses, findsNWidgets(2));

    final InkResponse firstInk = tester.widget<InkResponse>(inkResponses.first);
    final RenderBox firstBox =
        tester.renderObject<RenderBox>(inkResponses.first);
    final RectCallback? rectCallback = firstInk.getRectCallback(firstBox);
    expect(rectCallback, isNotNull);
    final Rect rect = rectCallback!();

    expect(rect.width, 56);
    expect(rect.height, 32);
  });

  testWidgets(
      "rail fill none with content hover does not render icon indicator",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: CustomNavigationRail(
            selectedIndex: 0,
            destinationFillRegion: NavigationDestinationRegion.none,
            destinationHoverRegion: NavigationDestinationRegion.content,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text("Home"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: Text("Search"),
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget.runtimeType.toString() == "NavigationIndicator",
      ),
      findsNothing,
    );
  });

  testWidgets(
      "rail content hover ignores hidden selected-label area on unselected destinations",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: CustomNavigationRail(
            selectedIndex: 0,
            labelType: NavigationRailLabelType.selected,
            destinationFillRegion: NavigationDestinationRegion.label,
            destinationHoverRegion: NavigationDestinationRegion.content,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text("Home"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: Text("Search"),
              ),
            ],
          ),
        ),
      ),
    );

    final Finder inkResponses = find.byWidgetPredicate(
      (Widget widget) => widget.runtimeType.toString() == "_IndicatorInkWell",
    );
    expect(inkResponses, findsNWidgets(2));

    final InkResponse selectedInk =
        tester.widget<InkResponse>(inkResponses.first);
    final RenderBox selectedBox =
        tester.renderObject<RenderBox>(inkResponses.first);
    final Rect selectedRect = selectedInk.getRectCallback(selectedBox)!();

    final InkResponse unselectedInk =
        tester.widget<InkResponse>(inkResponses.at(1));
    final RenderBox unselectedBox =
        tester.renderObject<RenderBox>(inkResponses.at(1));
    final Rect unselectedRect = unselectedInk.getRectCallback(unselectedBox)!();

    expect(unselectedRect.height, lessThan(selectedRect.height));
    expect(unselectedRect.height, lessThanOrEqualTo(40));
  });

  testWidgets(
      "rail destinationHoverRegion overrides interaction rect independently",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: CustomNavigationRail(
            selectedIndex: 0,
            destinationFillRegion: NavigationDestinationRegion.icon,
            destinationHoverRegion: NavigationDestinationRegion.full,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text("Home"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: Text("Search"),
              ),
            ],
          ),
        ),
      ),
    );

    final Finder inkResponses = find.byWidgetPredicate(
      (Widget widget) => widget.runtimeType.toString() == "_IndicatorInkWell",
    );
    expect(inkResponses, findsNWidgets(2));

    final InkResponse firstInk = tester.widget<InkResponse>(inkResponses.first);
    final RenderBox firstBox =
        tester.renderObject<RenderBox>(inkResponses.first);
    final RectCallback? rectCallback = firstInk.getRectCallback(firstBox);
    expect(rectCallback, isNotNull);
    final Rect rect = rectCallback!();

    expect(rect.left, 0);
    expect(rect.top, 0);
    expect(rect.width, firstBox.size.width);
    expect(rect.height, firstBox.size.height);
  });

  testWidgets("rail content hover region left edge matches icon left edge",
      (WidgetTester tester) async {
    Future<Rect> firstHoverRectFor(
      NavigationDestinationRegion hoverRegion,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: CustomNavigationRail(
              extended: true,
              selectedIndex: 0,
              labelType: NavigationRailLabelType.all,
              destinationFillRegion: NavigationDestinationRegion.none,
              destinationHoverRegion: hoverRegion,
              destinations: const <NavigationRailDestination>[
                NavigationRailDestination(
                  icon: Icon(Icons.chat_bubble_outline),
                  selectedIcon: Icon(Icons.chat_bubble),
                  label: Text("Chats"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search_outlined),
                  selectedIcon: Icon(Icons.search),
                  label: Text("Search"),
                ),
              ],
            ),
          ),
        ),
      );

      final Finder inkResponses = find.byWidgetPredicate(
        (Widget widget) => widget.runtimeType.toString() == "_IndicatorInkWell",
      );
      final InkResponse firstInk =
          tester.widget<InkResponse>(inkResponses.first);
      final RenderBox firstBox =
          tester.renderObject<RenderBox>(inkResponses.first);
      final RectCallback? rectCallback = firstInk.getRectCallback(firstBox);
      expect(rectCallback, isNotNull);
      final Rect localRect = rectCallback!();
      return localRect.shift(firstBox.localToGlobal(Offset.zero));
    }

    final Rect iconRegionRect = await firstHoverRectFor(
      NavigationDestinationRegion.icon,
    );
    final Rect contentRegionRect = await firstHoverRectFor(
      NavigationDestinationRegion.content,
    );

    expect(
      (contentRegionRect.left - iconRegionRect.left).abs(),
      lessThanOrEqualTo(1),
    );
  });

  testWidgets("bar icon fill mode keeps indicator-sized interaction rect", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          bottomNavigationBar: CustomNavigationBar(
            selectedIndex: 0,
            destinationFillRegion: NavigationDestinationRegion.icon,
            destinations: const <Widget>[
              CustomNavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: "Home",
              ),
              CustomNavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: "Search",
              ),
            ],
          ),
        ),
      ),
    );

    final Finder inkResponses = find.byWidgetPredicate(
      (Widget widget) =>
          widget.runtimeType.toString() == "_NavigationBarIndicatorInkWell",
    );
    expect(inkResponses, findsNWidgets(2));

    final InkResponse firstInk = tester.widget<InkResponse>(inkResponses.first);
    final RenderBox firstBox =
        tester.renderObject<RenderBox>(inkResponses.first);
    final RectCallback? rectCallback = firstInk.getRectCallback(firstBox);
    expect(rectCallback, isNotNull);
    final Rect rect = rectCallback!();

    expect(rect.width, 64);
    expect(rect.height, 32);
  });

  testWidgets(
      "bar content fill mode with hidden labels keeps padded icon interaction rect",
      (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          bottomNavigationBar: CustomNavigationBar(
            selectedIndex: 0,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            destinationFillRegion: NavigationDestinationRegion.content,
            destinations: const <Widget>[
              CustomNavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: "Home",
              ),
              CustomNavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: "Search",
              ),
            ],
          ),
        ),
      ),
    );

    final Finder inkResponses = find.byWidgetPredicate(
      (Widget widget) =>
          widget.runtimeType.toString() == "_NavigationBarIndicatorInkWell",
    );
    expect(inkResponses, findsNWidgets(2));

    final InkResponse firstInk = tester.widget<InkResponse>(inkResponses.first);
    final RenderBox firstBox =
        tester.renderObject<RenderBox>(inkResponses.first);
    final RectCallback? rectCallback = firstInk.getRectCallback(firstBox);
    expect(rectCallback, isNotNull);
    final Rect rect = rectCallback!();

    final Rect selectedIconRect = tester.getRect(find.byIcon(Icons.home).first);

    expect(rect.width, greaterThan(selectedIconRect.width));
    expect(rect.height, greaterThan(selectedIconRect.height));
    expect(rect.height, greaterThanOrEqualTo(32));
  });

  testWidgets("destinationFillShape is applied to interaction shape", (
    WidgetTester tester,
  ) async {
    final ShapeBorder fillShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: CustomNavigationRail(
            selectedIndex: 0,
            destinationFillRegion: NavigationDestinationRegion.full,
            destinationFillShape: fillShape,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text("Home"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: Text("Search"),
              ),
            ],
          ),
        ),
      ),
    );

    final Finder inkResponses = find.byWidgetPredicate(
      (Widget widget) => widget is InkResponse,
    );
    expect(inkResponses, findsNWidgets(2));

    final InkResponse firstInk = tester.widget<InkResponse>(inkResponses.first);
    expect(firstInk.customBorder, same(fillShape));
  });

  testWidgets("bar label fill mode uses label-only fixed-height pill", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          bottomNavigationBar: CustomNavigationBar(
            selectedIndex: 0,
            destinationFillRegion: NavigationDestinationRegion.label,
            destinations: const <Widget>[
              CustomNavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: "Home",
              ),
              CustomNavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: "Search",
              ),
            ],
          ),
        ),
      ),
    );

    final Finder inkResponses = find.byWidgetPredicate(
      (Widget widget) =>
          widget.runtimeType.toString() == "_NavigationBarIndicatorInkWell",
    );
    final InkResponse firstInk = tester.widget<InkResponse>(inkResponses.first);
    final RenderBox firstBox =
        tester.renderObject<RenderBox>(inkResponses.first);
    final RectCallback? rectCallback = firstInk.getRectCallback(firstBox);
    expect(rectCallback, isNotNull);
    final Rect localRect = rectCallback!();
    final Rect rect = localRect.shift(firstBox.localToGlobal(Offset.zero));

    final Rect iconRect = tester.getRect(find.byIcon(Icons.home).first);
    final Rect labelRect = tester.getRect(find.text("Home").first);

    expect(rect.height, 32);
    expect(rect.overlaps(labelRect), isTrue);
    expect(rect.width, greaterThan(labelRect.width));
    expect((rect.center.dx - labelRect.center.dx).abs(), lessThanOrEqualTo(1));
    expect(
      (rect.center.dy - labelRect.center.dy).abs(),
      lessThan((rect.center.dy - iconRect.center.dy).abs()),
    );
  });

  testWidgets("rail label fill mode uses label-only fixed-height pill", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: CustomNavigationRail(
            selectedIndex: 0,
            labelType: NavigationRailLabelType.all,
            destinationFillRegion: NavigationDestinationRegion.label,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text("Home"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: Text("Search"),
              ),
            ],
          ),
        ),
      ),
    );

    final Finder inkResponses = find.byWidgetPredicate(
      (Widget widget) => widget.runtimeType.toString() == "_IndicatorInkWell",
    );
    final InkResponse firstInk = tester.widget<InkResponse>(inkResponses.first);
    final RenderBox firstBox =
        tester.renderObject<RenderBox>(inkResponses.first);
    final RectCallback? rectCallback = firstInk.getRectCallback(firstBox);
    expect(rectCallback, isNotNull);
    final Rect localRect = rectCallback!();
    final Rect rect = localRect.shift(firstBox.localToGlobal(Offset.zero));

    final Rect iconRect = tester.getRect(find.byIcon(Icons.home).first);
    final Rect labelRect = tester.getRect(find.text("Home").first);

    expect(rect.height, 32);
    expect(rect.overlaps(labelRect), isTrue);
    expect(rect.width, greaterThan(labelRect.width));
    expect(rect.overlaps(iconRect), isFalse);
    expect(rect.left, lessThanOrEqualTo(iconRect.left));
    expect(
      rect.right,
      firstBox.localToGlobal(Offset.zero).dx + firstBox.size.width,
    );
    expect(
      (rect.center.dy - labelRect.center.dy).abs(),
      lessThan((rect.center.dy - iconRect.center.dy).abs()),
    );
  });

  testWidgets("rail extended label mode avoids icon overlap", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: CustomNavigationRail(
            extended: true,
            selectedIndex: 0,
            labelType: NavigationRailLabelType.all,
            destinationFillRegion: NavigationDestinationRegion.label,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text("Feed"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: Text("Search"),
              ),
            ],
          ),
        ),
      ),
    );

    final Finder inkResponses = find.byWidgetPredicate(
      (Widget widget) => widget.runtimeType.toString() == "_IndicatorInkWell",
    );
    final InkResponse firstInk = tester.widget<InkResponse>(inkResponses.first);
    final RenderBox firstBox =
        tester.renderObject<RenderBox>(inkResponses.first);
    final RectCallback? rectCallback = firstInk.getRectCallback(firstBox);
    expect(rectCallback, isNotNull);
    final Rect localRect = rectCallback!();
    final Rect rect = localRect.shift(firstBox.localToGlobal(Offset.zero));

    final Rect iconRect = tester.getRect(find.byIcon(Icons.home).first);
    final Rect labelRect = tester.getRect(find.text("Feed").first);

    expect(rect.height, 32);
    expect(rect.overlaps(iconRect), isFalse);
    expect(rect.overlaps(labelRect), isTrue);
    expect(
      rect.right,
      firstBox.localToGlobal(Offset.zero).dx + firstBox.size.width,
    );
  });
}
