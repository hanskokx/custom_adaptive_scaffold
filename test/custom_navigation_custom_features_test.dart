import "package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart";
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

  testWidgets(
      "fullWidget fill mode expands interaction rect for all rail destinations",
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: CustomNavigationRail(
            selectedIndex: 0,
            destinationFillMode: NavigationDestinationFillMode.full,
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
            destinationFillMode: NavigationDestinationFillMode.icon,
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

  testWidgets("bar icon fill mode keeps indicator-sized interaction rect", (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          bottomNavigationBar: CustomNavigationBar(
            selectedIndex: 0,
            destinationFillMode: NavigationDestinationFillMode.icon,
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
            destinationFillMode: NavigationDestinationFillMode.full,
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
            destinationFillMode: NavigationDestinationFillMode.label,
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
            destinationFillMode: NavigationDestinationFillMode.label,
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
            labelType: NavigationRailLabelType.none,
            destinationFillMode: NavigationDestinationFillMode.label,
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
