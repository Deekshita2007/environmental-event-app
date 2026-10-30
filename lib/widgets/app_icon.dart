import 'package:flutter/material.dart';

import '../utils/constants.dart';

class AppIcon extends StatelessWidget {
  final double size;

  const AppIcon({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.appIcon,
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: AppConstants.appName,
    );
  }
}
