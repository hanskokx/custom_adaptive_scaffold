import "../material.dart";
import "navigation_bar/destination.dart";
import "navigation_rail/destination.dart";
import "navigation_rail/navigation_rail.dart";

/// A typedef alias for [NavigationDestination].
///
/// Use this name when you need to import both this package and
/// `package:flutter/material.dart` without hiding Flutter's own
/// `NavigationDestination` class.
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:custom_adaptive_scaffold/custom_adaptive_scaffold.dart';
///
/// CustomNavigationDestination(
///   icon: Icon(Icons.inbox),
///   label: 'Inbox',
/// )
/// ```
typedef CustomNavigationDestination = NavigationDestination;

/// A navigation destination widget that can be used with [NavigationBar],
/// [NavigationRail], or [AdaptiveScaffold].
///
/// [NavigationDestination] serves as the base class for all navigation
/// destinations in this package. It can be used directly or subclassed
/// (see [NavigationBarDestination] and [NavigationRailDestination]).
///
/// This widget is a drop-in replacement for Flutter's `NavigationDestination`
/// with additional properties for [margin], [padding], [indicatorColor],
/// [indicatorShape], and [enabled] state, plus conversion helpers
/// [toRailDestination] and [toBarDestination].
///
/// {@tool snippet}
/// A simple destination list suitable for [AdaptiveScaffold]:
///
/// ```dart
/// AdaptiveScaffold(
///   destinations: const <NavigationDestination>[
///     NavigationDestination(
///       icon: Icon(Icons.inbox_outlined),
///       selectedIcon: Icon(Icons.inbox),
///       label: 'Inbox',
///     ),
///     NavigationDestination(
///       icon: Icon(Icons.article_outlined),
///       selectedIcon: Icon(Icons.article),
///       label: 'Articles',
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [NavigationBarDestination], the bar-specific subclass.
///  * [NavigationRailDestination], the rail-specific subclass.
///  * [NavigationBar], which displays a row of [NavigationDestination]s.
///  * [NavigationRail], which displays a column of [NavigationDestination]s.
class NavigationDestination extends StatelessWidget {
  /// Creates a navigation destination.
  ///
  /// [icon] is required. [label] and [tooltip] are both optional; if [label]
  /// is omitted the [tooltip] is used as the accessible label text.
  const NavigationDestination({
    required this.icon,
    super.key,
    String? label,
    Widget? selectedIcon,
    this.indicatorColor,
    this.indicatorShape,
    this.margin,
    this.padding,
    this.enabled = true,
    this.tooltip,
  })  : selectedIcon = selectedIcon ?? icon,
        _labelText = label;

  /// Indicates that this destination is selectable.
  ///
  /// Tapping an enabled destination has an effect. The icon and label are
  /// rendered with a normal-opacity style to communicate the enabled state.
  ///
  /// Defaults to `true`.
  final bool enabled;

  /// The [Widget] (usually an [Icon]) that is displayed for this destination
  /// when it is not selected.
  ///
  /// The icon will use the unselected [IconThemeData] from the closest
  /// [NavigationBarThemeData] or [NavigationRailThemeData] ancestor.
  final Widget icon;

  /// The optional [Widget] (usually an [Icon]) that is displayed when this
  /// destination is selected.
  ///
  /// If [selectedIcon] is non-null, the destination will fade from [icon]
  /// to [selectedIcon] when going from unselected to selected.
  ///
  /// Defaults to [icon] when not provided.
  final Widget selectedIcon;

  final String? _labelText;

  /// The text label that appears below (bar) or beside (rail) the icon.
  ///
  /// Returns [_labelText] when provided, falls back to [tooltipMessage],
  /// and returns an empty string when neither is available.
  String get label => _labelText ?? tooltipMessage ?? "";

  /// The text to display in the tooltip for this destination, shown when the
  /// user long-presses (or right-clicks, depending on
  /// [NavigationBarThemeData.tooltipTrigger]).
  ///
  /// If [tooltip] is an empty string, no tooltip is shown.
  ///
  /// Defaults to `null`, in which case [label] is used as the tooltip text.
  final String? tooltip;

  /// Resolves the effective tooltip message.
  ///
  /// Returns `null` when [tooltip] is an empty string (explicitly no tooltip).
  /// Returns [tooltip] when it is non-empty. Falls back to [_labelText] when
  /// [tooltip] is `null` and a non-empty label is available.
  String? get tooltipMessage {
    if (tooltip == null) {
      return _labelText?.isNotEmpty == true ? _labelText : null;
    }
    return tooltip!.isNotEmpty ? tooltip : null;
  }

  /// The color of the selection indicator shown behind the icon.
  ///
  /// If null, [NavigationBarThemeData.indicatorColor] or
  /// [NavigationRailThemeData.indicatorColor] is used instead.
  final Color? indicatorColor;

  /// The shape of the selection indicator shown behind the icon.
  ///
  /// If null, [NavigationBarThemeData.indicatorShape] or
  /// [NavigationRailThemeData.indicatorShape] is used instead.
  final ShapeBorder? indicatorShape;

  /// Applies a margin around this destination item.
  ///
  /// If null, [NavigationBarThemeData.margin] or
  /// [NavigationRailThemeData.margin] is used. Defaults to
  /// [EdgeInsets.zero] when neither is set.
  final EdgeInsetsGeometry? margin;

  /// Applies padding inside this destination item's content area.
  ///
  /// If null, [NavigationBarThemeData.padding] or
  /// [NavigationRailThemeData.padding] is used. Defaults to
  /// [EdgeInsets.zero] when neither is set.
  final EdgeInsetsGeometry? padding;

  Widget get _labelWidget => _labelText?.isNotEmpty == true
      ? Text(_labelText!)
      : (tooltipMessage != null
          ? Text(tooltipMessage!)
          : const SizedBox.shrink());

  // Internal: converts to a [NavigationRailDestination].
  // Not part of the public API — use [AdaptiveScaffold.toRailDestination] instead.
  NavigationRailDestination toRailDestination() {
    if (this is NavigationRailDestination) {
      return this as NavigationRailDestination;
    }

    // Preserve explicit empty-string tooltips ("") so suppression semantics
    // are kept, while still forwarding label fallback when tooltip is null.
    final String? railTooltip = tooltip ?? tooltipMessage;

    return NavigationRailDestination(
      icon: icon,
      label: _labelWidget,
      selectedIcon: selectedIcon,
      indicatorColor: indicatorColor,
      indicatorShape: indicatorShape,
      margin: margin,
      padding: padding,
      disabled: !enabled,
      tooltip: railTooltip,
    );
  }

  // Internal: converts to a [NavigationBarDestination].
  // Not part of the public API.
  NavigationBarDestination toBarDestination() {
    if (this is NavigationBarDestination) {
      return this as NavigationBarDestination;
    }

    return NavigationBarDestination(
      key: key,
      icon: icon,
      label: label,
      selectedIcon: selectedIcon,
      indicatorColor: indicatorColor,
      indicatorShape: indicatorShape,
      margin: margin,
      padding: padding,
      enabled: enabled,
      // Forward raw tooltip so explicit empty-string suppression is preserved.
      tooltip: tooltip,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RailDestination(
      icon: icon,
      label: _labelWidget,
    );
  }
}
