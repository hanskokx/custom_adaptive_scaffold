import "_internal_material.dart";
import "navigation_bar/destination.dart";
import "navigation_rail/destination.dart";
import "navigation_rail/navigation_rail.dart";

typedef CustomNavigationDestination = NavigationDestination;

class NavigationDestination extends StatelessWidget {
  const NavigationDestination({
    required this.icon,
    super.key,
    String? label,
    Widget? selectedIcon,
    this.indicatorColor,
    this.indicatorShape,
    this.margin,
    this.padding,
    this.disabled = false,
    this.tooltip,
  })  : selectedIcon = selectedIcon ?? icon,
        _labelText = label;

  final bool disabled;

  final Widget icon;
  final Widget selectedIcon;

  final String? _labelText;

  String get label => _labelText ?? tooltipMessage ?? "";

  final String? tooltip;

  String? get tooltipMessage {
    if (tooltip == null) {
      return _labelText?.isNotEmpty == true ? _labelText : null;
    }
    return tooltip!.isNotEmpty ? tooltip : null;
  }

  final Color? indicatorColor;
  final ShapeBorder? indicatorShape;

  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  Widget get _labelWidget => _labelText?.isNotEmpty == true
      ? Text(_labelText!)
      : (tooltipMessage != null
          ? Text(tooltipMessage!)
          : const SizedBox.shrink());

  NavigationRailDestination toRailDestination() {
    return NavigationRailDestination(
      icon: icon,
      label: _labelWidget,
      selectedIcon: selectedIcon,
      indicatorColor: indicatorColor,
      indicatorShape: indicatorShape,
      margin: margin,
      padding: padding,
      disabled: disabled,
      tooltip: tooltipMessage,
    );
  }

  NavigationBarDestination toBarDestination() {
    return NavigationBarDestination(
      icon: icon,
      label: label,
      selectedIcon: selectedIcon,
      indicatorColor: indicatorColor,
      indicatorShape: indicatorShape,
      margin: margin,
      padding: padding,
      disabled: disabled,
      tooltip: tooltipMessage,
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
