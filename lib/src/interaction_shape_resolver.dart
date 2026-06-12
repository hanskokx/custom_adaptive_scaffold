import "package:flutter/material.dart";

const Set<WidgetState> selectedShapeStates = <WidgetState>{
  WidgetState.selected,
};

ShapeBorder? resolveInteractionShape({
  required WidgetStateProperty<ShapeBorder?>? shape,
  required bool isSelected,
  required bool isHovered,
  required bool isPressed,
  required bool isFocused,
}) {
  if (shape == null) return null;

  final List<Set<WidgetState>> candidates = <Set<WidgetState>>[];
  final Set<WidgetState> activeStates = <WidgetState>{
    if (isSelected) WidgetState.selected,
    if (isHovered) WidgetState.hovered,
    if (isPressed) WidgetState.pressed,
    if (isFocused) WidgetState.focused,
  };

  if (activeStates.isNotEmpty) {
    candidates.add(activeStates);
  }
  if (isHovered) {
    candidates.add(<WidgetState>{
      if (isSelected) WidgetState.selected,
      WidgetState.hovered,
    });
    candidates.add(<WidgetState>{WidgetState.hovered});
  }
  if (isPressed) {
    candidates.add(<WidgetState>{
      if (isSelected) WidgetState.selected,
      WidgetState.pressed,
    });
    candidates.add(<WidgetState>{WidgetState.pressed});
  }
  if (isFocused) {
    candidates.add(<WidgetState>{
      if (isSelected) WidgetState.selected,
      WidgetState.focused,
    });
    candidates.add(<WidgetState>{WidgetState.focused});
  }
  if (isSelected) {
    candidates.add(selectedShapeStates);
  }

  final Set<String> seen = <String>{};
  for (final Set<WidgetState> candidate in candidates) {
    final List<String> signature = candidate
        .map((WidgetState state) => state.name)
        .toList()
      ..sort();
    final String key = signature.join(",");
    if (!seen.add(key)) continue;

    final ShapeBorder? resolved = shape.resolve(candidate);
    if (resolved != null) return resolved;
  }

  return null;
}