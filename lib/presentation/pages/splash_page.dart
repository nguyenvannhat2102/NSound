import 'package:flutter/material.dart';
import 'package:nsound/app/constants/assets.dart';
import 'package:nsound/app/router/app_router.dart';
import 'package:nsound/app/theme/themes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // after 2 seconds, navigate to home page
    Future.delayed(
      const Duration(seconds: 2),
      () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRouter.homeRoute);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Ink(
        decoration: BoxDecoration(
          gradient: Themes.getTheme().linearGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              Assets.logo,
              width: 200,
              height: 200,
            ),
            const Text(
              'NSound',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
