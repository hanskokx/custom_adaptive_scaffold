import "package:flutter/material.dart";

/// Tooltip widget for use in a [NavigationDestination].
///
/// It appears just above the navigation bar when one of the destinations is
/// long pressed.
class DestinationTooltip extends StatefulWidget {
  /// Adds a tooltip to the [child] widget.
  const DestinationTooltip({
    required this.message,
    required this.tooltipOffset,
    required this.tooltipTrigger,
    required this.child,
    super.key,
  });

  /// The text that is rendered in the tooltip when it appears.
  final String? message;

  /// The x/y offset used for positioning the tooltip.
  final Offset tooltipOffset;

  /// The trigger mode used by the tooltip.
  final TooltipTriggerMode? tooltipTrigger;

  /// The widget that, when pressed, will show a tooltip.
  final Widget child;

  @override
  State<DestinationTooltip> createState() => _DestinationTooltipState();
}

class _DestinationTooltipState extends State<DestinationTooltip> {
  final GlobalKey<TooltipState> _tooltipKey = GlobalKey<TooltipState>();
  bool _tooltipVisible = false;

  void _showTooltip() {
    if (!mounted) {
      return;
    }

    setState(() {
      _tooltipVisible = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _tooltipKey.currentState?.ensureTooltipVisible();

      Future<void>.delayed(const Duration(milliseconds: 1700), () {
        if (!mounted) {
          return;
        }
        setState(() {
          _tooltipVisible = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.message == null || widget.message!.isEmpty) {
      return widget.child;
    }

    final bool usesManualVisibility = switch (widget.tooltipTrigger) {
      TooltipTriggerMode.longPress || TooltipTriggerMode.tap => true,
      _ => false,
    };

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: switch (widget.tooltipTrigger) {
        TooltipTriggerMode.longPress => _showTooltip,
        _ => null,
      },
      onSecondaryTapUp: switch (widget.tooltipTrigger) {
        TooltipTriggerMode.tap => (_) => _showTooltip(),
        _ => null,
      },
      child: TooltipVisibility(
        visible: usesManualVisibility ? _tooltipVisible : true,
        child: Tooltip(
          key: _tooltipKey,
          message: widget.message!,
          verticalOffset: widget.tooltipOffset.dy,
          excludeFromSemantics: true,
          preferBelow: false,
          margin: EdgeInsets.only(left: widget.tooltipOffset.dx),
          triggerMode: usesManualVisibility
              ? TooltipTriggerMode.manual
              : widget.tooltipTrigger,
          child: widget.child,
        ),
      ),
    );
  }
}
