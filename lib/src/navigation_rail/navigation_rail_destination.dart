import "../material.dart";
import "../navigation_destination.dart";

class NavigationRailDestination extends NavigationDestination {
  const NavigationRailDestination({
    required super.icon,
    required Widget label,
    super.key,
    super.selectedIcon,
    super.indicatorColor,
    super.indicatorShape,
    super.margin,
    super.padding,
    super.disabled,
    super.tooltip,
  }) : _label = label;

  final Widget _label;

  String? get tooltipLabel => tooltipMessage;

  Widget get labelWidget => _label;
}
