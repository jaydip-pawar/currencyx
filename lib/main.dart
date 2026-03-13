import 'package:currencyx/common/constants/colors.dart';
import 'package:currencyx/common/mapper/mapper_init.init.dart';
import 'package:currencyx/repositories/currency_repository.dart';
import 'package:currencyx/services/currency_cache.dart';
import 'package:currencyx/views/splash_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeMappers();
  await Hive.initFlutter();
  final cache = CurrencyCache();
  await cache.init();
  runApp(
    ProviderScope(
      overrides: [currencyCacheProvider.overrideWithValue(cache)],
      child: const MyApp(),
    ),
  );
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
