import "material.dart";
import "navigation_bar/navigation_bar_destination.dart";
import "navigation_rail/navigation_rail.dart";
import "navigation_rail/navigation_rail_destination.dart";

class NavigationDestination extends StatelessWidget {
  const NavigationDestination({
    required this.icon,
    super.key,
    String? label,
    Widget? selectedIcon,
    this.indicatorColor,
    this.indicatorShape,
    this.padding,
    this.disabled = false,
    this.tooltip,
  })  : selectedIcon = selectedIcon ?? icon,
        _labelText = label;

  final bool disabled;

  final Widget icon;
  final Widget selectedIcon;

  final String? _labelText;

  String get label => _labelText ?? tooltip ?? "";

  final String? tooltip;

  final Color? indicatorColor;
  final ShapeBorder? indicatorShape;

  final EdgeInsetsGeometry? padding;

  Widget get _labelWidget => _labelText?.isNotEmpty == true
      ? Text(_labelText!)
      : (tooltip != null ? Text(tooltip!) : const SizedBox.shrink());

  NavigationRailDestination toRailDestination() {
    return NavigationRailDestination(
      icon: icon,
      label: _labelWidget,
      selectedIcon: selectedIcon,
      indicatorColor: indicatorColor,
      indicatorShape: indicatorShape,
      padding: padding,
    );
  }

  NavigationBarDestination toBarDestination() {
    return NavigationBarDestination(
      icon: icon,
      label: label,
      selectedIcon: selectedIcon,
      indicatorColor: indicatorColor,
      indicatorShape: indicatorShape,
      padding: padding,
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
