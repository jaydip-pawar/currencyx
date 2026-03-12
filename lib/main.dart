import 'package:currencyx/common/constants/colors.dart';
import 'package:currencyx/common/mapper/mapper_init.init.dart';
import 'package:currencyx/views/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeMappers();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'CurrencyX',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
    ),
    home: const SplashScreen(),
  );
}
