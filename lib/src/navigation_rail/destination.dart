import "../../material.dart";
import "../navigation_destination.dart";

/// A typedef alias for [NavigationRailDestination].
///
/// Use this name when you need to import both this package and
/// `package:flutter/material.dart` without hiding Flutter's
/// [NavigationRailDestination].
typedef CustomNavigationRailDestination = NavigationRailDestination;

/// A [NavigationRail] destination that can display a widget [label].
///
/// This is the rail-specific subclass of [NavigationDestination]. Unlike
/// Flutter's `NavigationRailDestination`, which requires a separate `label`
/// widget at construction time, [NavigationRailDestination] accepts the same
/// arguments as [NavigationDestination] and provides its label via the
/// [labelWidget] property so the rail can control label visibility and
/// animation.
///
/// In most cases, [NavigationDestination] can be used directly in a
/// [NavigationRail]; use [NavigationRailDestination] explicitly when you need
/// rail-specific label widget control.
///
/// See also:
///
///  * [NavigationRail], which uses this widget in its destination list.
///  * [NavigationDestination], the shared base class.
///  * [NavigationBarDestination], the bar-specific counterpart.
class NavigationRailDestination extends NavigationDestination {
  /// Creates a navigation rail destination.
  ///
  /// [icon] and [label] are required. [label] is a widget (rather than a
  /// string) so the caller can pass a pre-styled [Text] or any other widget.
  const NavigationRailDestination({
    required super.icon,
    required Widget label,
    super.key,
    super.selectedIcon,
    super.indicatorColor,
    super.indicatorShape,
    super.margin,
    super.padding,
    this.disabled = false,
    super.tooltip,
    super.badge,
    super.badgeStyle,
    super.badgeLabel,
    super.customBadge,
  }) : _label = label;

  final Widget _label;

  /// The effective enabled state for this destination.
  ///
  /// Returns `true` if the destination is enabled, or `false` if it is disabled. If [disabled] is `null`, this will return `true` by default.
  @override
  bool get enabled => !(disabled ?? false);

  /// Indicates that this destination is inaccessible.
  final bool? disabled;

  /// The effective tooltip text for this destination.
  ///
  /// Returns the resolved [tooltipMessage] string, or `null` if no tooltip
  /// should be shown.
  String? get tooltipLabel => tooltipMessage;

  /// The label widget to display beside or below the icon.
  ///
  /// This is typically a [Text] widget, but can be any widget. The rail
  /// controls visibility and animation of this widget based on [labelType]
  /// and the current selection state.
  Widget get labelWidget => _label;
}
