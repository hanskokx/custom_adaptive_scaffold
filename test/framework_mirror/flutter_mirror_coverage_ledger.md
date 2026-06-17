# Flutter Mirror Coverage Ledger

Source baseline files:
- /home/hans/Downloads/navigation_bar_test.dart
- /home/hans/Downloads/navigation_bar_theme_test.dart
- /home/hans/Downloads/navigation_rail_test.dart
- /home/hans/Downloads/navigation_rail_theme_test.dart

Status values:
- Fully represented
- Partially represented
- Missing
- Intentionally divergent (must cite package-only property)

## NavigationBar Framework
| Flutter category                                          | Mirror target                                                                                          | Status            | Notes                                                                             |
| --------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ | ----------------- | --------------------------------------------------------------------------------- |
| Tap updates destination                                   | test/framework_mirror/navigation_bar_framework_mirror_test.dart                                        | Fully represented | Parity covered.                                                                   |
| Background color/elevation/safe area/text scale/zero area | test/framework_mirror/navigation_bar_framework_mirror_test.dart                                        | Fully represented | Parity covered.                                                                   |
| Tooltips (explicit, null fallback, empty suppression)     | test/framework_mirror/navigation_bar_framework_mirror_test.dart, test/navigation_destination_test.dart | Fully represented | Empty suppression restored; conversion now preserves explicit empty tooltip.      |
| Semantics default/hidden-label/disabled                   | test/framework_mirror/navigation_bar_framework_mirror_test.dart                                        | Fully represented | Tightened to include tab labels + button semantics parity.                        |
| OverlayColor active/pressed/hovered paint behavior        | test/framework_mirror/navigation_bar_framework_mirror_test.dart                                        | Fully represented | Upgraded to paint-level assertions; focused state allows valid ordering variants. |
| M3 ripple geometry/state                                  | test/framework_mirror/navigation_bar_framework_mirror_test.dart                                        | Fully represented | Updated to circle-ink parity shape in current runtime.                            |
| M2 ripple geometry/state                                  | test/framework_mirror/navigation_bar_framework_mirror_test.dart                                        | Fully represented | Covered in Material 2 group.                                                      |
| Indicator move/color/shape updates                        | test/framework_mirror/navigation_bar_framework_mirror_test.dart                                        | Fully represented | Ripple geometry expectations aligned with current parity behavior.                |

## NavigationBarTheme
| Flutter category                                         | Mirror target                                                         | Status                  | Notes                                                                                            |
| -------------------------------------------------------- | --------------------------------------------------------------------- | ----------------------- | ------------------------------------------------------------------------------------------------ |
| copyWith/equals/hashCode/lerp/debugFillProperties        | test/framework_mirror/navigation_bar_theme_framework_mirror_test.dart | Fully represented       | Includes package-added fields.                                                                   |
| Theme values used when widget props absent               | test/framework_mirror/navigation_bar_theme_framework_mirror_test.dart | Fully represented       | Icon/label state matrix (selected/unselected icon size, color, opacity; label font sizes) added. |
| Widget values override theme values                      | test/framework_mirror/navigation_bar_theme_framework_mirror_test.dart | Fully represented       | Parity covered.                                                                                  |
| Custom label style ripple behavior                       | test/framework_mirror/navigation_bar_theme_framework_mirror_test.dart | Fully represented       | Paint expectation updated to circle-ink parity shape.                                            |
| Theme overlayColor active/pressed/hovered paint behavior | test/framework_mirror/navigation_bar_theme_framework_mirror_test.dart | Fully represented       | Upgraded to paint-level assertions with focused ordering tolerance.                              |
| Custom theme wrapper overriding defaults                 | test/framework_mirror/navigation_bar_theme_framework_mirror_test.dart | Intentionally divergent | Diverges due to package-specific wrapper/type `CustomNavigationBarThemeData`.                    |

## NavigationRail Framework
| Flutter category                                            | Mirror target                                                    | Status            | Notes                              |
| ----------------------------------------------------------- | ---------------------------------------------------------------- | ----------------- | ---------------------------------- |
| LabelType layouts/spacings/group alignment/leading-trailing | test/framework_mirror/navigation_rail_framework_mirror_test.dart | Fully represented | Broad parity coverage present.     |
| Extended mode and animation/minWidth/minExtendedWidth       | test/framework_mirror/navigation_rail_framework_mirror_test.dart | Fully represented | Strong parity anchor area.         |
| Semantics matrix (none/selected/all/extended/scrollable)    | test/framework_mirror/navigation_rail_framework_mirror_test.dart | Fully represented | Covered.                           |
| Indicator and ripple behavior                               | test/framework_mirror/navigation_rail_framework_mirror_test.dart | Fully represented | Covered across multiple scenarios. |
| Disabled behavior and label opacity                         | test/framework_mirror/navigation_rail_framework_mirror_test.dart | Fully represented | Covered.                           |

## NavigationRailTheme
| Flutter category                                  | Mirror target                                                          | Status            | Notes                                                              |
| ------------------------------------------------- | ---------------------------------------------------------------------- | ----------------- | ------------------------------------------------------------------ |
| copyWith/equals/hashCode/lerp/debugFillProperties | test/framework_mirror/navigation_rail_theme_framework_mirror_test.dart | Fully represented | Includes package-added fields.                                     |
| M3 defaults                                       | test/framework_mirror/navigation_rail_theme_framework_mirror_test.dart | Fully represented | Aligned to current SDK baseline (`labelMedium` in this toolchain). |
| M2 defaults                                       | test/framework_mirror/navigation_rail_theme_framework_mirror_test.dart | Fully represented | Covered.                                                           |
| Theme values used when widget props absent        | test/framework_mirror/navigation_rail_theme_framework_mirror_test.dart | Fully represented | Covered.                                                           |
| Widget values override theme values               | test/framework_mirror/navigation_rail_theme_framework_mirror_test.dart | Fully represented | Covered.                                                           |

## Cross-Implementation Guardrail
| Category                         | Mirror target                                                  | Status            | Notes                                                                                    |
| -------------------------------- | -------------------------------------------------------------- | ----------------- | ---------------------------------------------------------------------------------------- |
| Framework vs package dual checks | test/framework_mirror/navigation_dual_implementation_test.dart | Fully represented | Semantics selected-state parity (bar + rail) and empty-tooltip suppression parity added. |

## Intentional Divergence Inventory
- test/framework_mirror/navigation_bar_framework_mirror_test.dart:
  - [DIVERGENCE] Material2 - NavigationBar uses proper defaults when no parameters are given
  - Rationale: package maintains custom Material2 baseline behavior in this scenario.
- test/framework_mirror/navigation_bar_theme_framework_mirror_test.dart:
  - [DIVERGENCE] CustomNavigationBarTheme wrapper overrides NavigationBar defaults
  - Rationale: package-only theme wrapper behavior (`CustomNavigationBarThemeData`) beyond Flutter API surface.

## Next Gap Closure (priority)
All current gaps addressed. Governance rule: keep divergence tags limited to package-only fields and wrapper behaviors; any new shared-field additions must include framework parity tests.
