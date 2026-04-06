// lib/main.dart

import 'package:flutter/material.dart';
import 'package:predict365/AuthStorage/authStorage.dart';
import 'package:predict365/PredictScreens/HomeScreens/MarketTickData.dart';

import 'package:predict365/PredictScreens/LoginScreens/LoginView.dart';
import 'package:predict365/Predict_Utils/App_Theme/App_Theme.dart';
import 'package:predict365/Predict_Utils/ColorHandlers/Apptheme.dart';
import 'package:predict365/ViewModel/BookmarkVM.dart';
import 'package:predict365/ViewModel/CancelOrderVM.dart';
import 'package:predict365/ViewModel/CategoryVM.dart';
import 'package:predict365/ViewModel/EventVM.dart';
import 'package:predict365/ViewModel/MarketChartVM.dart';
import 'package:predict365/ViewModel/UserVM.dart';
import 'package:predict365/ViewModel/authVM.dart';
import 'package:provider/provider.dart';
import 'PredictScreens/BottomNavScreen/BottomNavScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get your key from: dashboard.magic.link → your app → API Keys

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => EventViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => MarketDataViewModel()),
        ChangeNotifierProvider(create: (_) => BookmarkViewModel()),
        ChangeNotifierProvider(create: (_) => MarketTickerService()),
        ChangeNotifierProvider(create: (_) => CancelOrderViewModel()),















      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Predict365',
            theme: themeController.isDarkMode
                ? Apptheme.darkThemeData
                : Apptheme.lightThemeData,
            themeMode: themeController.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,

            home: const _AuthGate(),
          );
        },
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthStorage.instance.isLoggedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF5A623),
                strokeWidth: 2.5,
              ),
            ),
          );
        }
        return snapshot.data == true
            ? const MainNavigationPage()
            : const LoginScreen();
      },
    );
  }
}