import "package:flutter/material.dart";

import "../adaptive_scaffold_controller.dart";

/// An inherited widget that exposes whether the current layout is in a
/// split-view (side-by-side) configuration.
///
/// Place a [SplitView] above the body and secondary body slots of a
/// [DualPanel] to propagate the split-view state to descendants. The
/// [SplitViewDetector] updates the [notifier] automatically based on
/// [AdaptiveBody.viewIsCollapsed].
///
/// Descendants can read the current state with [SplitView.isActive]:
///
/// ```dart
/// final bool isSplit = SplitView.isActive(context);
/// ```
///
/// See also:
///
///  * [SplitViewDetector], which listens to [AdaptiveBody] and updates
///    the [notifier] automatically.
///  * [DualPanel], which typically wraps its body slots in [SplitView].
class SplitView extends InheritedNotifier<ValueNotifier<bool>> {
  /// Creates a split-view inherited widget.
  ///
  /// The [child] and [notifier] arguments must not be null.
  const SplitView({
    required super.child,
    required super.notifier,
    super.key,
  });

  /// Returns `true` if the nearest [SplitView] ancestor reports a split
  /// (side-by-side) layout.
  ///
  /// Returns `false` if no [SplitView] is found or the current layout is
  /// collapsed (single-pane).
  ///
  /// ```dart
  /// if (SplitView.isActive(context)) {
  ///   // Show side-by-side content
  /// } else {
  ///   // Show stacked/overlay content
  /// }
  /// ```
  static bool isActive(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<SplitView>()
            ?.notifier
            ?.value ??
        false;
  }
}

/// A widget that detects the current split-view state and notifies via
/// [onChanged].
///
/// [SplitViewDetector] reads [AdaptiveBody.of] after each frame and
/// reports whether the layout is in a split (side-by-side) configuration.
/// It is typically placed inside a [SplitView] to keep its [notifier] in
/// sync.
///
/// This widget does not build any visible UI — it renders [child] unchanged.
///
/// ```dart
/// SplitView(
///   notifier: isSplitNotifier,
///   child: SplitViewDetector(
///     onChanged: (isSplit) => isSplitNotifier.value = isSplit,
///     child: MyContent(),
///   ),
/// )
/// ```
///
/// See also:
///
///  * [SplitView], which provides the split-view state to descendants.
///  * [DualPanel], which uses [SplitViewDetector] internally to detect
///    layout changes.
class SplitViewDetector extends StatefulWidget {
  /// Creates a split-view detector.
  ///
  /// The [onChanged] callback is called when the split-view state changes.
  /// The [child] argument must not be null.
  const SplitViewDetector({
    required this.onChanged,
    required this.child,
    super.key,
  });

  /// Called when the split-view state changes.
  ///
  /// The boolean parameter is `true` when the layout is in split
  /// (side-by-side) mode, and `false` when collapsed (single-pane).
  final ValueChanged<bool> onChanged;

  /// The widget below this detector in the tree.
  ///
  /// This widget is returned unchanged by [build] — [SplitViewDetector]
  /// does not insert any visible UI.
  final Widget child;

  @override
  State<SplitViewDetector> createState() => _SplitViewDetectorState();
}

class _SplitViewDetectorState extends State<SplitViewDetector> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bool? collapsed = AdaptiveBody.of(context)?.viewIsCollapsed;
      if (collapsed != null) {
        widget.onChanged(!collapsed);
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
