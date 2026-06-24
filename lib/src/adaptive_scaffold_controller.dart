import "package:flutter/widgets.dart";

/// Indicates which pane should be focused when a layout is collapsed.
///
/// Used by [AdaptiveScaffoldController] to signal to [AdaptiveScaffold]
/// which pane should be visible on a narrow (single-pane) layout.
///
/// On wider layouts where both panes can be shown simultaneously this value
/// is ignored — the scaffold always shows both panes.
enum PanelFocus {
  /// Focus the primary body pane.
  body,

  /// Focus the secondary body pane.
  secondaryBody,
}

/// Controls pane intent for primary/secondary style layouts in
/// [AdaptiveScaffold].
///
/// On wider layouts both panes can still be visible; this controller is
/// primarily used for collapsed (narrow) layouts where only one pane is
/// shown at a time.
///
/// Wrap your stateful widget to create and dispose the controller:
///
/// ```dart
/// class _MyScreenState extends State<MyScreen> {
///   final AdaptiveScaffoldController _controller =
///       AdaptiveScaffoldController();
///
///   @override
///   void dispose() {
///     _controller.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return AdaptiveScaffold(
///       controller: _controller,
///       body: (_) => MyListView(
///         onTap: () => _controller.showSecondaryBody(),
///       ),
///       secondaryBody: (_) => MyDetailView(
///         onBack: _controller.showBody,
///       ),
///     );
///   }
/// }
/// ```
///
/// See also:
///
///  * [AdaptiveScaffoldScope], which provides the controller to descendants.
///  * [AdaptiveBody], which exposes the collapsed state to body widgets.
class AdaptiveScaffoldController extends ValueNotifier<PanelFocus?> {
  /// Creates a controller with an optional [initialIntent].
  ///
  /// When [initialIntent] is null (the default), collapsed layouts preserve
  /// legacy dual-pane behavior until [showBody] or [showSecondaryBody] is
  /// called.
  ///
  /// Pass [PanelFocus.body] or [PanelFocus.secondaryBody] to opt into
  /// immediate single-pane intent on first build.
  AdaptiveScaffoldController({
    PanelFocus? initialIntent,
  }) : super(initialIntent);

  /// Whether the controller currently holds an explicit pane intent.
  ///
  /// Returns `false` until [showBody] or [showSecondaryBody] has been called,
  /// or an [initialIntent] was provided.
  bool get hasExplicitIntent => value != null;

  /// Shows the secondary body pane on collapsed layouts.
  ///
  /// Has no effect if [PanelFocus.secondaryBody] is already the current intent.
  void showSecondaryBody() {
    if (value == PanelFocus.secondaryBody) return;
    value = PanelFocus.secondaryBody;
  }

  /// Shows the primary body pane on collapsed layouts.
  ///
  /// Has no effect if [PanelFocus.body] is already the current intent.
  void showBody() {
    if (value == PanelFocus.body) return;
    value = PanelFocus.body;
  }
}

/// Provides [AdaptiveScaffoldController] to descendants via [InheritedNotifier].
///
/// Inserted into the widget tree by [AdaptiveScaffold] when a [controller] is
/// provided. Descendants can obtain the controller with [of] or [maybeOf].
class AdaptiveScaffoldScope
    extends InheritedNotifier<AdaptiveScaffoldController> {
  /// Creates a scope that provides [controller] to all descendants.
  const AdaptiveScaffoldScope({
    required AdaptiveScaffoldController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  /// Returns the nearest [AdaptiveScaffoldController] in the widget tree.
  ///
  /// Throws a [FlutterError] assertion if no [AdaptiveScaffoldScope] ancestor
  /// is found. Use [maybeOf] when the scope may be absent.
  static AdaptiveScaffoldController of(BuildContext context) {
    final AdaptiveScaffoldScope? scope =
        context.dependOnInheritedWidgetOfExactType<AdaptiveScaffoldScope>();

    assert(scope != null, "AdaptiveScaffoldScope not found in widget tree.");

    return scope!.notifier!;
  }

  /// Returns the nearest [AdaptiveScaffoldController], or `null` if none is
  /// found.
  static AdaptiveScaffoldController? maybeOf(BuildContext context) {
    final AdaptiveScaffoldScope? scope =
        context.dependOnInheritedWidgetOfExactType<AdaptiveScaffoldScope>();
    return scope?.notifier;
  }
}

/// Exposes whether the active layout is currently collapsed (single-pane).
///
/// [AdaptiveScaffold] wraps the active body and secondaryBody slot content in
/// an [AdaptiveBody] so that descendants can adapt their UI for collapsed
/// layouts without coupling to route state.
///
/// ```dart
/// final bool isCollapsed =
///     AdaptiveBody.of(context)?.viewIsCollapsed ?? false;
/// ```
class AdaptiveBody extends InheritedWidget {
  /// Creates an [AdaptiveBody] that exposes [viewIsCollapsed] to descendants.
  const AdaptiveBody({
    required this.viewIsCollapsed,
    required super.child,
    super.key,
  });

  /// Whether the current layout is collapsed to a single pane.
  ///
  /// `true` when [AdaptiveScaffold] is on a narrow breakpoint and
  /// [AdaptiveScaffoldController] has an explicit intent. `false` on wider
  /// layouts where both panes are visible simultaneously.
  final bool viewIsCollapsed;

  /// Returns the nearest [AdaptiveBody] ancestor, or `null` if none is found.
  ///
  /// ```dart
  /// final bool isCollapsed =
  ///     AdaptiveBody.of(context)?.viewIsCollapsed ?? false;
  /// ```
  static AdaptiveBody? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AdaptiveBody>();
  }

  @override
  bool updateShouldNotify(AdaptiveBody oldWidget) {
    return viewIsCollapsed != oldWidget.viewIsCollapsed;
  }
}
