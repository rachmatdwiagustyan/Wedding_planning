import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants/app_colors.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const TalentaEventOrganizerApp());
}

class TalentaEventOrganizerApp extends StatelessWidget {
  const TalentaEventOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TALENTA EVENT ORGANIZER',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.warmIvory,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.deepBurgundy,
          primary: AppColors.deepBurgundy,
          secondary: AppColors.champagne,
          surface: AppColors.pureWhite,
          onPrimary: AppColors.pureWhite,
          onSurface: AppColors.charcoal,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.warmIvory,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: AppColors.charcoal),
          titleTextStyle: TextStyle(
            fontFamily: 'serif',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.pureWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.deepBurgundy,
            foregroundColor: AppColors.pureWhite,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontFamily: 'sans-serif',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        dividerColor: AppColors.divider,
      ),
      home: const SplashScreen(),
    );
  }
}
