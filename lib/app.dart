import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsound/app/router/app_router.dart';
import 'package:nsound/app/theme/app_theme_data.dart';
import 'package:nsound/bloc/theme/theme_bloc.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "NSound",
          theme: AppThemeData.getTheme(),
          onGenerateRoute: (settings) => AppRouter.generateRoute(settings),
        );
      },
    );
  }
}
