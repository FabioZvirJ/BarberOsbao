import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/router/app_router.dart';
import 'features/authentication/application/auth_controller.dart';
import 'design_system/theme/theme_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authControllerProvider);

    // Retrieve active theme from auth user settings (falls back to dark)
    final themeMode = userState.maybeWhen(
      data: (user) => user?.theme == 'light' ? ThemeMode.light : ThemeMode.dark,
      orElse: () => ThemeMode.dark,
    );

    return MaterialApp.router(
      title: 'BarberOsbao',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeColors.getLightTheme(),
      darkTheme: ThemeColors.getDarkTheme(),
      routerConfig: appRouter,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
        ],
      ),
    );
  }
}
