import "package:flutter/material.dart";

class ExtendedNavigationRailAnimation extends InheritedWidget {
  const ExtendedNavigationRailAnimation({
    required this.animation,
    required super.child,
    super.key,
  });

  final Animation<double> animation;

  @override
  bool updateShouldNotify(ExtendedNavigationRailAnimation old) =>
      animation != old.animation;
}
