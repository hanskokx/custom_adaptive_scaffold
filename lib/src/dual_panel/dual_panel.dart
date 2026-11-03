import "package:material_ui/material_ui.dart" hide NavigationDestination;

import "../adaptive_layout.dart";
import "../adaptive_scaffold_controller.dart";
import "../breakpoints.dart";
import "../navigation_destination.dart";
import "../slot_layout.dart";

/// A responsive layout that displays a primary body and an optional secondary
/// body side-by-side on wider screens.
///
/// On screens narrower than [breakpoint], only the [body] is shown and
/// [AdaptiveBody.of] reports `viewIsCollapsed: true`. On screens at or above
/// [breakpoint], both [body] and [secondaryBody] are displayed in a split
/// layout and [AdaptiveBody.of] reports `viewIsCollapsed: false`.
///
/// {@macro dual_panel.breakpoint}
///
/// ```dart
/// DualPanel(
///   body: PostList(),
///   secondaryBody: PostDetail(postId: selectedId),
///   maxWidth: 800,
/// )
/// ```
///
/// See also:
///
///  * [AdaptiveLayout], which [DualPanel] wraps internally.
///  * [AdaptiveBody], which exposes the collapsed state to descendants.
///  * [SplitView] and [SplitViewDetector], which detect the split-view
///    state and are commonly used inside [DualPanel] body slots.
class DualPanel extends StatefulWidget {
  /// The primary content displayed on all screen sizes.
  ///
  /// On narrow screens this is the only visible pane. On wide screens it
  /// occupies the left (or main) portion of the split layout.
  final Widget body;

  /// The secondary content displayed alongside [body] on wide screens.
  ///
  /// When `null` (the default), no secondary pane is rendered and
  /// [DualPanel] behaves as a single-column layout regardless of screen
  /// width. On narrow screens this widget is never built.
  final Widget? secondaryBody;

  /// Maximum width for the body content on wider screens.
  ///
  /// When `null` (the default), no width constraint is applied and the
  /// body fills the available space. Set this to cap the body width
  /// (e.g. for readability on very wide displays).
  final double? maxWidth;

  /// The breakpoint at which the layout switches to the wide (split)
  /// configuration and [secondaryBody] becomes visible.
  ///
  /// {@macro dual_panel.breakpoint}
  ///
  /// Defaults to [Breakpoints.mediumAndUp].
  final Breakpoint breakpoint;

  /// Creates a responsive dual-panel layout.
  ///
  /// The [body] argument must not be null. The [breakpoint] must be wider
  /// than [Breakpoints.smallAndUp] (enforced by an assertion).
  const DualPanel({
    required this.body,
    this.secondaryBody,
    this.maxWidth,
    this.breakpoint = Breakpoints.mediumAndUp,
    super.key,
  }) : assert(
         breakpoint > Breakpoints.smallAndUp,
         "breakpoint must be wider than Breakpoints.smallAndUp",
       );

  @override
  State<DualPanel> createState() => _DualPanelState();
}

class _DualPanelState extends State<DualPanel> {
  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      internalAnimations: true,
      bodyRatio: 0.5,
      body: SlotLayout(
        config: <Breakpoint, SlotLayoutConfig>{
          Breakpoints.smallAndUp: SlotLayout.from(
            key: const Key("Body Small"),
            builder: (context) {
              return AdaptiveBody(
                viewIsCollapsed: true,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: widget.maxWidth ?? double.infinity,
                    ),
                    child: widget.body,
                  ),
                ),
              );
            },
          ),
          widget.breakpoint: SlotLayout.from(
            key: const Key("Body Large"),
            builder: (context) {
              return AdaptiveBody(
                viewIsCollapsed: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: widget.maxWidth ?? double.infinity,
                    ),
                    child: widget.body,
                  ),
                ),
              );
            },
          ),
        },
      ),
      secondaryBody: widget.secondaryBody == null
          ? null
          : SlotLayout(
              config: <Breakpoint, SlotLayoutConfig>{
                widget.breakpoint: SlotLayout.from(
                  key: const Key("Secondary Body"),
                  builder: (context) {
                    return AdaptiveBody(
                      viewIsCollapsed: false,
                      child: widget.secondaryBody!,
                    );
                  },
                ),
              },
            ),
    );
  }
}

/// Configuration for navigation elements displayed alongside a [DualPanel]
/// shell.
///
/// Provides optional leading/trailing widgets for the navigation rail and
/// a list of [NavigationDestination]s for the bottom navigation bar.
///
/// ```dart
/// DualPanelNavigationConfig(
///   destinations: [
///     NavigationDestination(icon: Icon(Icons.home), label: "Home"),
///     NavigationDestination(icon: Icon(Icons.search), label: "Search"),
///   ],
///   leadingUnextendedNavRail: Logo(height: 24),
///   leadingExtendedNavRail: Logo(height: 40),
/// )
/// ```
class DualPanelNavigationConfig {
  /// Creates a navigation configuration.
  const DualPanelNavigationConfig({
    this.destinations,
    this.leadingUnextendedNavRail,
    this.leadingExtendedNavRail,
    this.trailingNavRail,
  });

  /// The navigation destinations displayed in the bottom navigation bar
  /// and, when applicable, the navigation rail.
  ///
  /// When `null`, no destinations are rendered.
  final List<NavigationDestination>? destinations;

  /// A widget displayed at the top of the navigation rail when it is in
  /// its collapsed (unextended) state.
  ///
  /// Typically a logo or icon. When `null`, nothing is shown.
  final Widget? leadingUnextendedNavRail;

  /// A widget displayed at the top of the navigation rail when it is in
  /// its expanded (extended) state.
  ///
  /// Typically a logo with a label. When `null`, nothing is shown.
  final Widget? leadingExtendedNavRail;

  /// A widget displayed at the bottom of the navigation rail.
  ///
  /// Typically a settings icon or user avatar. When `null`, nothing is
  /// shown.
  final Widget? trailingNavRail;

  /// Returns a new [DualPanelNavigationConfig] with the given fields
  /// replaced with new values.
  ///
  /// Each parameter is optional. Omitted fields retain their current value.
  ///
  /// ```dart
  /// final config = DualPanelNavigationConfig(
  ///   destinations: [home, search],
  ///   leadingUnextendedNavRail: Logo(height: 24),
  /// );
  ///
  /// final updated = config.copyWith(
  ///   destinations: [home, search, profile],
  /// );
  /// ```
  DualPanelNavigationConfig copyWith({
    List<NavigationDestination>? destinations,
    Widget? leadingUnextendedNavRail,
    Widget? leadingExtendedNavRail,
    Widget? trailingNavRail,
  }) {
    return DualPanelNavigationConfig(
      destinations: destinations ?? this.destinations,
      leadingUnextendedNavRail:
          leadingUnextendedNavRail ?? this.leadingUnextendedNavRail,
      leadingExtendedNavRail:
          leadingExtendedNavRail ?? this.leadingExtendedNavRail,
      trailingNavRail: trailingNavRail ?? this.trailingNavRail,
    );
  }

  @override
  String toString() {
    return "DualPanelNavigationConfig("
        "destinations: $destinations, "
        "leadingUnextendedNavRail: $leadingUnextendedNavRail, "
        "leadingExtendedNavRail: $leadingExtendedNavRail, "
        "trailingNavRail: $trailingNavRail"
        ")";
  }
}

/// {@template dual_panel.breakpoint}
/// The breakpoint that controls when [DualPanel] switches between single-pane
/// and split-pane layouts.
///
/// Must be wider than [Breakpoints.smallAndUp]. The secondary body is only
/// built when the screen width meets or exceeds this breakpoint.
/// {@endtemplate}
