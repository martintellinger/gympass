import 'package:flutter/material.dart';

import 'core/routing/router.dart';
import 'core/theme/app_theme.dart';

class BytFitApp extends StatelessWidget {
  const BytFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BýtFit Klub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
