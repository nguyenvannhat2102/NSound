import 'package:flutter/material.dart';
import 'package:nsound/app/router/app_router.dart';
import 'package:nsound/app/theme/app_theme_data.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "NSound",
      theme: AppThemeData.getTheme(),
      onGenerateRoute: (settings) => AppRouter.generateRoute(settings),
    );
  }
}
