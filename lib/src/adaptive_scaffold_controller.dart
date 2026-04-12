import "package:flutter/widgets.dart";

/// Indicates which pane should be focused when a layout is collapsed.
enum PanelFocus { body, secondaryBody }

/// Controls pane intent for primary/secondary style layouts.
///
/// On wider layouts both panes can still be visible; this intent is primarily
/// used for collapsed layouts where only one pane is shown.
class AdaptiveScaffoldController extends ValueNotifier<PanelFocus?> {
  AdaptiveScaffoldController({
    PanelFocus? initialIntent,
  }) : super(initialIntent);

  bool get hasExplicitIntent => value != null;

  void showSecondaryBody() {
    if (value == PanelFocus.secondaryBody) return;
    value = PanelFocus.secondaryBody;
  }

  void showBody() {
    if (value == PanelFocus.body) return;
    value = PanelFocus.body;
  }
}

/// Provides [AdaptiveScaffoldController] to descendants.
class AdaptiveScaffoldScope
    extends InheritedNotifier<AdaptiveScaffoldController> {
  const AdaptiveScaffoldScope({
    required AdaptiveScaffoldController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static AdaptiveScaffoldController of(BuildContext context) {
    final AdaptiveScaffoldScope? scope =
        context.dependOnInheritedWidgetOfExactType<AdaptiveScaffoldScope>();

    assert(scope != null, "AdaptiveScaffoldScope not found in widget tree.");

    return scope!.notifier!;
  }

  static AdaptiveScaffoldController? maybeOf(BuildContext context) {
    final AdaptiveScaffoldScope? scope =
        context.dependOnInheritedWidgetOfExactType<AdaptiveScaffoldScope>();
    return scope?.notifier;
  }
}

/// Exposes whether the active layout is currently collapsed.
class AdaptiveBody extends InheritedWidget {
  const AdaptiveBody({
    required this.viewIsCollapsed,
    required super.child,
    super.key,
  });

  final bool viewIsCollapsed;

  static AdaptiveBody? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AdaptiveBody>();
  }

  @override
  bool updateShouldNotify(AdaptiveBody oldWidget) {
    return viewIsCollapsed != oldWidget.viewIsCollapsed;
  }
}
