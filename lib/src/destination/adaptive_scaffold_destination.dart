// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import "../material.dart";
import "../navigation_destination.dart";

/// A convenience destination for use with [AdaptiveScaffold] that mirrors the
/// API of the upstream Flutter `AdaptiveScaffoldDestination`, accepting an
/// [IconData] and a title string rather than Widget children.
///
/// Extends [NavigationDestination], so it can be used anywhere a
/// [NavigationDestination] is expected, including in mixed-type destination
/// lists alongside [NavigationDestination] and other subclasses.
///
/// ```dart
/// AdaptiveScaffold(
///   destinations: const [
///     AdaptiveScaffoldDestination(title: 'Inbox', icon: Icons.inbox),
///     AdaptiveScaffoldDestination(title: 'Articles', icon: Icons.article),
///   ],
/// )
/// ```
class AdaptiveScaffoldDestination extends NavigationDestination {
  /// Creates an [AdaptiveScaffoldDestination].
  ///
  /// [title] is used as the navigation label. [icon] is the unselected icon.
  /// [selectedIcon] defaults to [icon] when not provided.
  AdaptiveScaffoldDestination({
    required String title,
    required IconData icon,
    IconData? selectedIcon,
    super.key,
    super.indicatorColor,
    super.indicatorShape,
    super.margin,
    super.padding,
    super.disabled = false,
    super.tooltip,
  }) : super(
          label: title,
          icon: Icon(icon),
          selectedIcon: selectedIcon != null ? Icon(selectedIcon) : null,
        );
}
