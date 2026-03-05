import 'package:flutter/material.dart';
import 'package:predict365/PredictScreens/LoginScreens/LoginView.dart';
import 'package:predict365/Predict_Utils/App_Theme/App_Theme.dart';
import 'package:predict365/Predict_Utils/ColorHandlers/Apptheme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
  return  MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeController()),

        ],
        child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
    return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Flutter Demo',
    theme: themeController.isDarkMode
    ? Apptheme.darkThemeData
        : Apptheme.lightThemeData,
    themeMode: themeController.isDarkMode
    ? ThemeMode.dark
        : ThemeMode.light,
    home: const LoginScreen(),
    );
    }));

  }
}

