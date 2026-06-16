import "package:auto_layout_frame/auto_layout_frame.dart";
import "package:flutter/material.dart";

import "navigation_rail/navigation_rail.dart";
import "navigation_type.dart";

class NavigationIcon extends StatelessWidget {
  const NavigationIcon({
    required this.data,
    required this.type,
    super.key,
  });

  final RailDestinationBuildData data;
  final NavigationType type;

  @override
  Widget build(BuildContext context) {
    // _verticalDestinationSpacingM3 = 12.0
    final Widget? spacing =
        data.material3 ? const SizedBox(height: 12.0 / 2) : null;

    return ConstrainedBox(
      constraints: BoxConstraints.tight(
        Size(data.minWidth, 44),
      ),
      child: AutoLayoutFrame(
        alignChildren: Alignment.center,
        direction: switch (type) {
          NavigationType.bar => AutoLayoutDirection.vertical,
          NavigationType.rail => AutoLayoutDirection.horizontal,
        },
        children: <Widget>[
          if (spacing != null) spacing,
          Center(
            // The shared compact item only owns the icon body.
            child: data.themedIcon,
          ),
          if (spacing != null) spacing,
        ],
      ),
    );
  }
}
