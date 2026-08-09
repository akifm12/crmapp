import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'router.dart';

class BlueArrowApp extends StatelessWidget {
  const BlueArrowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Blue Arrow',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}
