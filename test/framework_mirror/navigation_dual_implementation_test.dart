library;

import "package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart" as cas;
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:flutter_test/flutter_test.dart";

enum _WidgetImpl { framework, package }

String _implName(_WidgetImpl impl) {
  return impl == _WidgetImpl.framework ? "framework" : "package";
}

Widget _buildNavigationBar({
  required _WidgetImpl impl,
  required int selectedIndex,
  required ValueChanged<int> onSelected,
  Color? backgroundColor,
  double? elevation,
}) {
  if (impl == _WidgetImpl.framework) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      backgroundColor: backgroundColor,
      elevation: elevation,
      destinations: const <Widget>[
        NavigationDestination(icon: Icon(Icons.home_outlined), label: "Home"),
        NavigationDestination(
            icon: Icon(Icons.search_outlined), label: "Search"),
      ],
      onDestinationSelected: onSelected,
    );
  }

  return cas.CustomNavigationBar(
    selectedIndex: selectedIndex,
    backgroundColor: backgroundColor,
    elevation: elevation,
    destinations: const <Widget>[
      cas.CustomNavigationDestination(
        icon: Icon(Icons.home_outlined),
        label: "Home",
      ),
      cas.CustomNavigationDestination(
        icon: Icon(Icons.search_outlined),
        label: "Search",
      ),
    ],
    onDestinationSelected: onSelected,
  );
}

Widget _buildNavigationRail({
  required _WidgetImpl impl,
  required int selectedIndex,
  required ValueChanged<int> onSelected,
  TextStyle? selectedLabelTextStyle,
  TextStyle? unselectedLabelTextStyle,
}) {
  if (impl == _WidgetImpl.framework) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      labelType: NavigationRailLabelType.all,
      selectedLabelTextStyle: selectedLabelTextStyle,
      unselectedLabelTextStyle: unselectedLabelTextStyle,
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
    labelType: NavigationRailLabelType.all,
    selectedLabelTextStyle: selectedLabelTextStyle,
    unselectedLabelTextStyle: unselectedLabelTextStyle,
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
        of: impl == _WidgetImpl.framework
            ? find.byType(NavigationBar)
            : find.byType(cas.CustomNavigationBar),
        matching: find.byType(Material),
      );

      final Material material = tester.widget<Material>(materialFinder.first);
      expect(material.color, color);
      expect(material.elevation, elevation);
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
  }
}
