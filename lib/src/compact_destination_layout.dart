// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import "package:flutter/material.dart";

import "destination_region_boundary.dart";

/// Shared compact icon+label layout used by nav bar and collapsed rail.
class CompactDestinationLayout extends StatelessWidget {
  const CompactDestinationLayout({
    required this.icon,
    required this.iconKey,
    required this.labelKey,
    required this.label,
    required this.positionAnimation,
    required this.labelOpacity,
    this.padding = EdgeInsets.zero,
    this.height,
    super.key,
  });

  final Widget icon;
  final GlobalKey iconKey;
  final GlobalKey labelKey;
  final Widget label;
  final Animation<double> positionAnimation;
  final Animation<double> labelOpacity;
  final EdgeInsetsGeometry padding;
  final double? height;

  @override
  Widget build(BuildContext context) {
    Widget layout = CustomMultiChildLayout(
      delegate: _CompactDestinationLayoutDelegate(
        animation: positionAnimation,
      ),
      children: <Widget>[
        LayoutId(
          id: _CompactDestinationLayoutDelegate.iconId,
          child: DestinationRegionBoundary(
            regionKey: iconKey,
            child: icon,
          ),
        ),
        LayoutId(
          id: _CompactDestinationLayoutDelegate.labelId,
          child: DestinationRegionBoundary(
            regionKey: labelKey,
            opacity: labelOpacity,
            child: label,
          ),
        ),
      ],
    );

    if (height != null) {
      layout = SizedBox(height: height, child: layout);
    }

    return RepaintBoundary(
      child: Padding(
        padding: padding,
        child: layout,
      ),
    );
  }
}

class _CompactDestinationLayoutDelegate extends MultiChildLayoutDelegate {
  _CompactDestinationLayoutDelegate({required this.animation})
      : super(relayout: animation);

  final Animation<double> animation;

  static const int iconId = 1;
  static const int labelId = 2;

  @override
  void performLayout(Size size) {
    double halfWidth(Size value) => value.width / 2;
    double halfHeight(Size value) => value.height / 2;

    final Size iconSize = layoutChild(iconId, BoxConstraints.loose(size));
    final Size labelSize = layoutChild(labelId, BoxConstraints.loose(size));

    final double yPositionOffset = Tween<double>(
      begin: halfHeight(iconSize),
      end: halfHeight(iconSize) + halfHeight(labelSize),
    ).transform(animation.value);
    final double iconYPosition = halfHeight(size) - yPositionOffset;

    positionChild(
      iconId,
      Offset(halfWidth(size) - halfWidth(iconSize), iconYPosition),
    );

    positionChild(
      labelId,
      Offset(
        halfWidth(size) - halfWidth(labelSize),
        iconYPosition + iconSize.height,
      ),
    );
  }

  @override
  bool shouldRelayout(_CompactDestinationLayoutDelegate oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
