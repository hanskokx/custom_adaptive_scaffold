// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import "package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart";
import "package:flutter/material.dart";

void main() {
  runApp(const MyApp());
}

/// The main application widget for this example.
class MyApp extends StatelessWidget {
  /// Creates a const main application widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        navigationRailTheme: const CustomNavigationRailThemeData(
          selectedIconTheme: IconThemeData(
            color: Colors.red,
            size: 28,
          ),
          selectedLabelTextStyle: TextStyle(
            fontSize: 16,
            color: Colors.red,
          ),
          unselectedLabelTextStyle: TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
          margin: EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.symmetric(horizontal: 6),
        ),
        navigationBarTheme: const CustomNavigationBarThemeData(
          tooltipVerticalOffset: 56,
          margin: EdgeInsets.symmetric(horizontal: 4),
          padding: EdgeInsets.symmetric(vertical: 2),
          labelPadding: EdgeInsets.only(top: 6),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

/// Creates a basic adaptive page with navigational elements and a body using
/// [AdaptiveScaffold].
class MyHomePage extends StatefulWidget {
  /// Creates a const [MyHomePage].
  const MyHomePage({super.key, this.transitionDuration = 1000});

  /// Declare transition duration.
  final int transitionDuration;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedTab = 0;
  int _transitionDuration = 1000;
  final AdaptiveScaffoldController _scaffoldController =
      AdaptiveScaffoldController();

  // Initialize transition time variable.
  @override
  void initState() {
    super.initState();
    setState(() {
      _transitionDuration = widget.transitionDuration;
    });
  }

  @override
  void dispose() {
    _scaffoldController.dispose();
    super.dispose();
  }

  // #docregion Example
  @override
  Widget build(BuildContext context) {
    // Define the children to display within the body at different breakpoints.
    final List<Widget> children = <Widget>[
      for (int i = 0; i < 10; i++)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            color: const Color.fromARGB(255, 255, 201, 197),
            height: 400,
          ),
        ),
    ];
    return AdaptiveScaffold(
      // An option to override the default transition duration.
      transitionDuration: Duration(milliseconds: _transitionDuration),
      navigationTheme: const AdaptiveScaffoldNavigationThemeData(
        compactLabelBehavior: NavigationRailLabelType.selected,
        transitionAnimation: NavigationDestinationAnimation.fadeSwap,
        transitionCurve: Curves.easeOutCubic,
        transitionDuration: Duration(milliseconds: 220),
        destinationFillRegion: NavigationDestinationRegion.content,
        destinationFillShape: StadiumBorder(),
      ),
      // An option to override the default breakpoints used for small, medium,
      // mediumLarge, large, and extraLarge.
      smallBreakpoint: const Breakpoint(endWidth: 700),
      mediumBreakpoint: const Breakpoint(beginWidth: 700, endWidth: 1000),
      mediumLargeBreakpoint: const Breakpoint(beginWidth: 1000, endWidth: 1200),
      largeBreakpoint: const Breakpoint(beginWidth: 1200, endWidth: 1600),
      extraLargeBreakpoint: const Breakpoint(beginWidth: 1600),
      useDrawer: false,
      selectedIndex: _selectedTab,
      onSelectedIndexChange: (int index) {
        setState(() {
          _selectedTab = index;
        });
      },
      destinations: <CustomNavigationDestination>[
        // Default: no animation, full-item indicator.
        const CustomNavigationDestination(
          icon: Icon(Icons.inbox_outlined),
          selectedIcon: Icon(Icons.inbox),
          label: "Inbox",
        ),
        // Built-in fade-swap transition between icons.
        const CustomNavigationDestination(
          icon: Icon(Icons.article_outlined),
          selectedIcon: Icon(Icons.article),
          label: "Articles",
          transitionAnimation: NavigationDestinationAnimation.fadeSwap,
          transitionCurve: Curves.easeInOut,
        ),
        // Label hidden; indicator scoped to icon only.
        const CustomNavigationDestination(
          icon: Icon(Icons.chat_outlined),
          selectedIcon: Icon(Icons.chat),
          label: "Chat",
          hideLabel: true,
          iconIndicatorShape: CircleBorder(),
        ),
        CustomNavigationDestination(
          icon: const Icon(Icons.video_call_outlined),
          selectedIcon: const Icon(Icons.video_call),
          label: "Video",
          transitionBuilder: (
            BuildContext context,
            Animation<double> animation,
            bool isSelecting,
            Widget unselectedIcon,
            Widget selectedIcon,
            Widget unselectedLabel,
            Widget selectedLabel,
          ) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FadeTransition(
                  opacity: animation,
                  child: animation.isForwardOrCompleted
                      ? selectedIcon
                      : unselectedIcon,
                ),
                const SizedBox(height: 4),
                FadeTransition(
                  opacity: animation,
                  child: animation.isForwardOrCompleted
                      ? selectedLabel
                      : unselectedLabel,
                ),
              ],
            );
          },
        ),
        const CustomNavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: "Home",
        ),
      ],
      controller: _scaffoldController,
      smallBody: (_) => ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      "Small-screen controller demo",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Tap to switch from body to secondaryBody on compact layouts.",
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _scaffoldController.showSecondaryBody,
                      child: const Text("Show secondaryBody"),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ...children,
        ],
      ),
      body: (_) => GridView.count(crossAxisCount: 2, children: children),
      mediumLargeBody: (_) =>
          GridView.count(crossAxisCount: 3, children: children),
      largeBody: (_) => GridView.count(crossAxisCount: 4, children: children),
      extraLargeBody: (_) =>
          GridView.count(crossAxisCount: 5, children: children),
      smallSecondaryBody: (_) => Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  "secondaryBody",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "This pane is shown on small screens when the controller focus is secondaryBody.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: _scaffoldController.showBody,
                  child: const Text("Back to body"),
                ),
              ],
            ),
          ),
        ),
      ),
      secondaryBody: (_) => Container(
        color: const Color.fromARGB(255, 234, 158, 192),
      ),
      mediumLargeSecondaryBody: (_) => Container(
        color: const Color.fromARGB(255, 234, 158, 192),
      ),
      largeSecondaryBody: (_) => Container(
        color: const Color.fromARGB(255, 234, 158, 192),
      ),
      extraLargeSecondaryBody: (_) => Container(
        color: const Color.fromARGB(255, 234, 158, 192),
      ),
    );
  }
// #enddocregion Example
}
