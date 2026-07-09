import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barber_osbao/apps/client/routes/app_router.dart';
import 'package:barber_osbao/apps/manager/routes/app_router.dart';
import 'package:barber_osbao/packages/core/auth/application/auth_controller.dart';
import 'package:barber_osbao/packages/core/auth/presentation/pages/login_page.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';

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

    return userState.when(
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: ThemeColors.darkBg,
          body: Center(
            child: CircularProgressIndicator(color: ThemeColors.primary),
          ),
        ),
      ),
      error: (e, s) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: ThemeColors.darkBg,
          body: Center(
            child: Text('Erro: $e', style: const TextStyle(color: Colors.white)),
          ),
        ),
      ),
      data: (user) {
        if (user == null) {
          return MaterialApp(
            title: 'BarberOsbao - Login',
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.dark,
            darkTheme: ThemeColors.getDarkTheme(),
            home: const LoginPage(),
          );
        }

        final isClient = user.role != 'admin';
        final themeMode = user.theme == 'light' ? ThemeMode.light : ThemeMode.dark;

        return MaterialApp.router(
          title: isClient ? 'BarberOsbao' : 'BarberOsbao Manager',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeColors.getLightTheme(),
          darkTheme: ThemeColors.getDarkTheme(),
          routerConfig: isClient ? appRouter : managerRouter,
          builder: (context, child) => ResponsiveBreakpoints.builder(
            child: child!,
            breakpoints: [
              const Breakpoint(start: 0, end: 450, name: MOBILE),
              const Breakpoint(start: 451, end: 800, name: TABLET),
              const Breakpoint(start: 801, end: 1920, name: DESKTOP),
            ],
          ),
        );
      },
    );
  }
}
