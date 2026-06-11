// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Forked, modified, and maintained by Hans Kokx beginning in 2024.

import "package:flutter/material.dart";

/// Controls how the icon animates when a [CustomNavigationDestination]
/// transitions between selected and unselected states.
///
/// Pass this to [CustomNavigationDestination.transitionAnimation].
/// If [CustomNavigationDestination.iconBuilder] is also set, it takes
/// priority and this value is ignored.
enum NavigationDestinationAnimation {
  /// No animation — the icon swaps instantly (current default behavior).
  none,

  /// Cross-fade between the unselected and selected icon widgets.
  fadeSwap,

  /// Scale the incoming icon up and the outgoing icon down.
  scale,
}

/// Controls where rail destination selection fill and interaction effects are
/// painted.
enum NavigationRailDestinationFillMode {
  /// No fill or highlight is painted.
  none,

  /// Paint fill/highlight around the icon area only.
  ///
  /// This is the default behavior.
  iconOnly,

  /// Paint fill/highlight across icon and label area.
  content,

  /// Paint fill/highlight starting from the label left edge extending to the
  /// right boundary of the destination.
  ///
  /// Like [textOnly] but unconstrained on the right — useful for extended rails
  /// where the label fills the remaining width.
  label,

  /// Paint fill/highlight across the whole destination widget.
  full,
}

/// A builder that constructs an icon widget for a
/// [CustomNavigationDestination] with full control over the selection
/// animation.
///
/// Parameters:
/// - [animation] runs from 0 (fully unselected) to 1 (fully selected).
/// - [isSelecting] is `true` while the destination is transitioning toward
///   selected (animation moving forward or already completed), and `false`
///   while transitioning toward unselected (animation reversing or dismissed).
///   Use this to drive directional animations, e.g. bouncing up on select and
///   down on deselect.
/// - [unselectedIcon] and [selectedIcon] are already wrapped in the
///   appropriate [IconTheme] for their state.
///
/// Use this when the built-in [NavigationDestinationAnimation] presets are
/// insufficient.
typedef NavigationDestinationIconBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  bool isSelecting,
  Widget unselectedIcon,
  Widget selectedIcon,
);

/// A builder that constructs destination content with access to both icon and
/// label states.
///
/// Parameters:
/// - [animation] runs from 0 (fully unselected) to 1 (fully selected).
/// - [isSelecting] is `true` while transitioning toward selected.
/// - [unselectedIcon] and [selectedIcon] are already themed icon widgets.
/// - [unselectedLabel] and [selectedLabel] are fully built label widgets.
///
/// Use this when icon and label need to animate together.
typedef NavigationDestinationTransitionBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  bool isSelecting,
  Widget unselectedIcon,
  Widget selectedIcon,
  Widget unselectedLabel,
  Widget selectedLabel,
);
