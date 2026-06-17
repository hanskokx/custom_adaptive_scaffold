// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import "../_internal_material.dart";
import "../navigation_destination.dart";

/// A convenience destination for use with [AdaptiveScaffold] that mirrors the
/// API of the upstream Flutter `AdaptiveScaffoldDestination`, accepting an
/// [IconData] and a `title` string rather than widget children.
///
/// Extends [NavigationDestination], so it can be used anywhere a
/// [NavigationDestination] is expected, including in mixed-type destination
/// lists alongside plain [NavigationDestination] instances and other subclasses.
///
/// Use this class for quick setup when you already have icon data and a label
/// string. Use [NavigationDestination] directly when you need a custom icon
/// widget (e.g. [ImageIcon], animated icon) or a custom [selectedIcon].
///
/// {@tool snippet}
/// ```dart
/// AdaptiveScaffold(
///   destinations: const [
///     AdaptiveScaffoldDestination(title: 'Inbox', icon: Icons.inbox),
///     AdaptiveScaffoldDestination(
///       title: 'Articles',
///       icon: Icons.article_outlined,
///       selectedIcon: Icons.article,
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [NavigationDestination], the base class with full widget-level control.
///  * [AdaptiveScaffold], the primary consumer of destination lists.
class AdaptiveScaffoldDestination extends NavigationDestination {
  /// Creates an [AdaptiveScaffoldDestination].
  ///
  /// [title] is used as the navigation label and tooltip (unless [tooltip] is
  /// provided explicitly). [icon] is wrapped in an [Icon] widget and used as
  /// the unselected icon. [selectedIcon] is also wrapped in an [Icon] and
  /// defaults to [icon] when not provided.
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
