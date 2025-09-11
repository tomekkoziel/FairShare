import 'package:fair_share/features/authentication/screens/onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:fair_share/utils/theme/theme.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: TMyAppTheme.lightTheme,
      darkTheme: TMyAppTheme.darkTheme,
      home: const OnBoardingScreen(),
    );
  }
}