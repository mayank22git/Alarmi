import 'package:flutter/material.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1100 && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= 650 && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}
