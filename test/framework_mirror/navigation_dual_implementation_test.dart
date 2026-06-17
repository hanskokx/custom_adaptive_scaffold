library;

import "package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart" as cas;
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter_test/flutter_test.dart";

enum _WidgetImpl { framework, package }

String _implName(_WidgetImpl impl) {
  return impl == _WidgetImpl.framework ? "framework" : "package";
}

Finder _barFinder(_WidgetImpl impl) {
  return impl == _WidgetImpl.framework
      ? find.byType(NavigationBar)
      : find.byType(cas.CustomNavigationBar);
}

Finder _railFinder(_WidgetImpl impl) {
  return impl == _WidgetImpl.framework
      ? find.byType(NavigationRail)
      : find.byType(cas.CustomNavigationRail);
}

Widget _buildNavigationBar({
  required _WidgetImpl impl,
  required int selectedIndex,
  required ValueChanged<int> onSelected,
  Color? backgroundColor,
  double? elevation,
  NavigationDestinationLabelBehavior? labelBehavior,
  bool maintainBottomViewPadding = false,
  List<NavigationDestination>? destinations,
}) {
  final List<NavigationDestination> effectiveDestinations = destinations ??
      const <NavigationDestination>[
        NavigationDestination(icon: Icon(Icons.home_outlined), label: "Home"),
        NavigationDestination(
          icon: Icon(Icons.search_outlined),
          label: "Search",
        ),
      ];

  if (impl == _WidgetImpl.framework) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      backgroundColor: backgroundColor,
      elevation: elevation,
      labelBehavior: labelBehavior,
      maintainBottomViewPadding: maintainBottomViewPadding,
      destinations: effectiveDestinations,
      onDestinationSelected: onSelected,
    );
  }

  return cas.CustomNavigationBar(
    selectedIndex: selectedIndex,
    backgroundColor: backgroundColor,
    elevation: elevation,
    labelBehavior: labelBehavior,
    maintainBottomViewPadding: maintainBottomViewPadding,
    destinations: effectiveDestinations
        .map(
          (NavigationDestination d) => cas.CustomNavigationDestination(
            icon: d.icon,
            selectedIcon: d.selectedIcon,
            label: d.label,
            tooltip: d.tooltip,
          ),
        )
        .toList(growable: false),
    onDestinationSelected: onSelected,
  );
}

Widget _buildNavigationRail({
  required _WidgetImpl impl,
  required int selectedIndex,
  required ValueChanged<int> onSelected,
  TextStyle? selectedLabelTextStyle,
  TextStyle? unselectedLabelTextStyle,
  IconThemeData? selectedIconTheme,
  IconThemeData? unselectedIconTheme,
  NavigationRailLabelType labelType = NavigationRailLabelType.all,
  bool extended = false,
}) {
  if (impl == _WidgetImpl.framework) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      labelType: labelType,
      extended: extended,
      selectedLabelTextStyle: selectedLabelTextStyle,
      unselectedLabelTextStyle: unselectedLabelTextStyle,
      selectedIconTheme: selectedIconTheme,
      unselectedIconTheme: unselectedIconTheme,
      destinations: const <NavigationRailDestination>[
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          label: Text("Home"),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.search_outlined),
          label: Text("Search"),
        ),
      ],
      onDestinationSelected: onSelected,
    );
  }

  return cas.CustomNavigationRail(
    selectedIndex: selectedIndex,
    labelType: labelType,
    extended: extended,
    selectedLabelTextStyle: selectedLabelTextStyle,
    unselectedLabelTextStyle: unselectedLabelTextStyle,
    selectedIconTheme: selectedIconTheme,
    unselectedIconTheme: unselectedIconTheme,
    destinations: const <cas.NavigationRailDestination>[
      cas.NavigationRailDestination(
        icon: Icon(Icons.home_outlined),
        label: Text("Home"),
      ),
      cas.NavigationRailDestination(
        icon: Icon(Icons.search_outlined),
        label: Text("Search"),
      ),
    ],
    onDestinationSelected: onSelected,
  );
}

TextStyle _iconStyle(WidgetTester tester, IconData icon) {
  final RichText iconRichText = tester.widget<RichText>(
    find.descendant(of: find.byIcon(icon), matching: find.byType(RichText)),
  );
  return iconRichText.text.style!;
}

void main() {
  for (final _WidgetImpl impl in _WidgetImpl.values) {
    testWidgets("${_implName(impl)} NavigationBar selection updates on tap", (
      WidgetTester tester,
    ) async {
      var selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return _buildNavigationBar(
                  impl: impl,
                  selectedIndex: selectedIndex,
                  onSelected: (int index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text("Search"));
      await tester.pumpAndSettle();
      expect(selectedIndex, 1);

      await tester.tap(find.text("Home"));
      await tester.pumpAndSettle();
      expect(selectedIndex, 0);
    });

    testWidgets(
        "${_implName(impl)} NavigationBar applies background and elevation", (
      WidgetTester tester,
    ) async {
      const Color color = Colors.amber;
      const double elevation = 6;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: _buildNavigationBar(
              impl: impl,
              selectedIndex: 0,
              backgroundColor: color,
              elevation: elevation,
              onSelected: (_) {},
            ),
          ),
        ),
      );

      final Finder materialFinder = find.descendant(
        of: _barFinder(impl),
        matching: find.byType(Material),
      );

      final Material material = tester.widget<Material>(materialFinder.first);
      expect(material.color, color);
      expect(material.elevation, elevation);
    });

    testWidgets(
        "${_implName(impl)} NavigationBar adds bottom padding to height",
        (WidgetTester tester) async {
      const double bottomPadding = 24;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: _buildNavigationBar(
              impl: impl,
              selectedIndex: 0,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      final double defaultHeight = tester.getSize(_barFinder(impl)).height;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.only(bottom: bottomPadding),
            ),
            child: Scaffold(
              bottomNavigationBar: _buildNavigationBar(
                impl: impl,
                selectedIndex: 0,
                onSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(
        tester.getSize(_barFinder(impl)).height,
        defaultHeight + bottomPadding,
      );
    });

    testWidgets("${_implName(impl)} NavigationBar labelBehavior parity", (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: _buildNavigationBar(
              impl: impl,
              selectedIndex: 0,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              onSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text("Home"), findsOneWidget);
      expect(find.text("Search"), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: _buildNavigationBar(
              impl: impl,
              selectedIndex: 0,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              onSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text("Home"), findsOneWidget);
      expect(find.text("Search"), findsOneWidget);
    });

    testWidgets("${_implName(impl)} NavigationBar tooltip can be shown", (
      WidgetTester tester,
    ) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: "Home",
          tooltip: "tip-home",
        ),
        NavigationDestination(
          icon: Icon(Icons.search_outlined),
          selectedIcon: Icon(Icons.search),
          label: "Search",
          tooltip: "tip-search",
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: _buildNavigationBar(
              impl: impl,
              selectedIndex: 1,
              destinations: destinations,
              onSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.longPress(find.byIcon(Icons.home_outlined));
      await tester.pumpAndSettle();
      expect(find.text("tip-home"), findsOneWidget);
    });

    testWidgets("${_implName(impl)} NavigationRail selection updates on tap", (
      WidgetTester tester,
    ) async {
      var selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return _buildNavigationRail(
                  impl: impl,
                  selectedIndex: selectedIndex,
                  onSelected: (int index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text("Search"));
      await tester.pumpAndSettle();
      expect(selectedIndex, 1);

      await tester.tap(find.text("Home"));
      await tester.pumpAndSettle();
      expect(selectedIndex, 0);
    });

    testWidgets(
        "${_implName(impl)} NavigationRail selected/unselected label styles apply",
        (
      WidgetTester tester,
    ) async {
      const TextStyle selectedStyle = TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
      );
      const TextStyle unselectedStyle = TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w300,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _buildNavigationRail(
              impl: impl,
              selectedIndex: 0,
              selectedLabelTextStyle: selectedStyle,
              unselectedLabelTextStyle: unselectedStyle,
              onSelected: (_) {},
            ),
          ),
        ),
      );

      final TextStyle selectedResolved =
          tester.renderObject<RenderParagraph>(find.text("Home")).text.style!;
      final TextStyle unselectedResolved =
          tester.renderObject<RenderParagraph>(find.text("Search")).text.style!;

      expect(selectedResolved.fontSize, selectedStyle.fontSize);
      expect(unselectedResolved.fontSize, unselectedStyle.fontSize);
    });

    testWidgets(
        "${_implName(impl)} NavigationRail selected/unselected icon themes apply",
        (
      WidgetTester tester,
    ) async {
      const IconThemeData selectedTheme = IconThemeData(
        size: 32,
        color: Color(0xFFE53935),
      );
      const IconThemeData unselectedTheme = IconThemeData(
        size: 18,
        color: Color(0xFF43A047),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _buildNavigationRail(
              impl: impl,
              selectedIndex: 0,
              selectedIconTheme: selectedTheme,
              unselectedIconTheme: unselectedTheme,
              onSelected: (_) {},
            ),
          ),
        ),
      );

      final TextStyle selectedIconStyle =
          _iconStyle(tester, Icons.home_outlined);
      final TextStyle unselectedIconStyle =
          _iconStyle(tester, Icons.search_outlined);

      expect(selectedIconStyle.color, selectedTheme.color);
      expect(selectedIconStyle.fontSize, selectedTheme.size);
      expect(unselectedIconStyle.color, unselectedTheme.color);
      expect(unselectedIconStyle.fontSize, unselectedTheme.size);
    });

    testWidgets("${_implName(impl)} NavigationRail labelType parity", (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _buildNavigationRail(
              impl: impl,
              selectedIndex: 0,
              labelType: NavigationRailLabelType.none,
              onSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text("Home"), findsOneWidget);
      expect(find.text("Search"), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _buildNavigationRail(
              impl: impl,
              selectedIndex: 0,
              labelType: NavigationRailLabelType.all,
              onSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text("Home"), findsOneWidget);
      expect(find.text("Search"), findsOneWidget);
    });

    testWidgets("${_implName(impl)} NavigationRail extended width parity", (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: <Widget>[
                _buildNavigationRail(
                  impl: impl,
                  selectedIndex: 0,
                  labelType: NavigationRailLabelType.none,
                  extended: false,
                  onSelected: (_) {},
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final double compactWidth = tester.getSize(_railFinder(impl)).width;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: <Widget>[
                _buildNavigationRail(
                  impl: impl,
                  selectedIndex: 0,
                  labelType: NavigationRailLabelType.none,
                  extended: true,
                  onSelected: (_) {},
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final double extendedWidth = tester.getSize(_railFinder(impl)).width;
      expect(extendedWidth, greaterThan(compactWidth));
    });

    testWidgets(
        "${_implName(impl)} NavigationBar destination selected state in semantics",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: _buildNavigationBar(
              impl: impl,
              selectedIndex: 0,
              onSelected: (_) {},
            ),
          ),
        ),
      );

      // Exactly one destination should expose selected=true via Semantics.
      final Iterable<Semantics> allSemantics =
          tester.widgetList<Semantics>(find.byType(Semantics));
      final Iterable<Semantics> selectedNodes = allSemantics.where(
        (Semantics s) => s.properties.selected ?? false,
      );
      expect(selectedNodes.length, 1);
    });

    testWidgets(
        "${_implName(impl)} NavigationBar empty tooltip does not display popup text",
        (WidgetTester tester) async {
      const List<NavigationDestination> destinations = <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          label: "Home",
          tooltip: "",
        ),
        NavigationDestination(
          icon: Icon(Icons.search_outlined),
          label: "Search",
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: _buildNavigationBar(
              impl: impl,
              selectedIndex: 0,
              destinations: destinations,
              onSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.longPress(find.byIcon(Icons.home_outlined));
      await tester.pumpAndSettle();
      // Any Tooltip widgets present must have an empty message (popup suppressed).
      // Both implementations must not show "Home" as a tooltip popup.
      final Iterable<Tooltip> tooltips =
          tester.widgetList<Tooltip>(find.byType(Tooltip));
      expect(
        tooltips.any(
          (Tooltip t) =>
              (t.message?.isNotEmpty ?? false) && t.message == "Home",
        ),
        isFalse,
        reason: "Empty tooltip must not show the label as a tooltip popup.",
      );
    });

    testWidgets(
        "${_implName(impl)} NavigationRail destination selected state in semantics",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _buildNavigationRail(
              impl: impl,
              selectedIndex: 0,
              onSelected: (_) {},
            ),
          ),
        ),
      );

      // Exactly one destination should expose selected=true via Semantics.
      final Iterable<Semantics> allSemantics =
          tester.widgetList<Semantics>(find.byType(Semantics));
      final Iterable<Semantics> selectedNodes = allSemantics.where(
        (Semantics s) => s.properties.selected ?? false,
      );
      expect(selectedNodes.length, 1);
    });
  }
}
