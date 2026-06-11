// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import "package:flutter/material.dart";

/// Shared region wrapper used by compact nav destination layouts.
///
/// It ensures both nav bar and collapsed rail measure icon/label bounds from
/// the same render-object shape for hover/fill geometry.
class DestinationRegionBoundary extends StatelessWidget {
  const DestinationRegionBoundary({
    required this.regionKey,
    required this.child,
    this.opacity,
    this.alwaysIncludeSemantics = true,
    super.key,
  });

  final GlobalKey regionKey;
  final Widget child;
  final Animation<double>? opacity;
  final bool alwaysIncludeSemantics;

  @override
  Widget build(BuildContext context) {
    final Widget content = opacity == null
        ? child
        : FadeTransition(
            alwaysIncludeSemantics: alwaysIncludeSemantics,
            opacity: opacity!,
            child: child,
          );

    return RepaintBoundary(
      key: regionKey,
      child: content,
    );
  }
}
