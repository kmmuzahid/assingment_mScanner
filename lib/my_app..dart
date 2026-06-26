/*
 * @Author: Km Muzahid
 * @Date: 2026-01-07 15:37:37
 * @Email: km.muzahid@gmail.com
 */
import 'package:flutter/material.dart';
import 'package:pinlink/config/color/app_color.dart';
import 'package:pinlink/config/route/app_router.dart';
import 'package:pinlink/config/route/app_router_observer.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(); // or ClampingScrollPhysics, etc.
  }

  @override
  ScrollViewKeyboardDismissBehavior getKeyboardDismissBehavior(
    BuildContext context,
  ) {
    return ScrollViewKeyboardDismissBehavior.onDrag;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const colors = ThemeColor.dark;

    return MaterialApp.router(
      scrollBehavior: CustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: MockupColors.pageBackground,
        primaryColor: MockupColors.mint,
        appBarTheme: const AppBarTheme(
          backgroundColor: MockupColors.appBarBackground,
          foregroundColor: MockupColors.textWhite,
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: MockupColors.mint,
            foregroundColor: MockupColors.pageBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: MockupColors.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: MockupColors.cardBorder),
          ),
          labelStyle: const TextStyle(color: MockupColors.textSubtle),
        ),
        dividerColor: MockupColors.cardBorder,
        dataTableTheme: const DataTableThemeData(
          headingTextStyle: TextStyle(
            color: MockupColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
          dataTextStyle: TextStyle(color: MockupColors.textSubtle),
        ),
        extensions: const [colors],
      ),
      routerConfig: appRouter.config(
        navigatorObservers: () => [AppRouterObserver()],
      ),
    );
  }
}
