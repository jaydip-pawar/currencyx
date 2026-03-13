import 'package:currencyx/common/constants/colors.dart';
import 'package:currencyx/views/home_screen/viewmodel/home_viewmodel.dart';
import 'package:currencyx/views/home_screen/widgets/converter_view.dart';
import 'package:currencyx/views/rates_screen/rates_screen.dart';
import 'package:currencyx/views/settings_screen/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _titles = ['CurrencyX', 'Rates', 'Settings'];

  static const _screens = [ConverterView(), RatesScreen(), SettingsScreen()];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navIndex = ref.watch(navIndexProvider);
    final isSaving = ref.watch(settingsSavingProvider);

    ref.listen(homeViewModelProvider, (previous, next) {
      if (next.hasError) {
        final message = '${next.error}'.replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.white,
        title: Text(
          _titles[navIndex],
          style: const TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _screens[navIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: navIndex,
        onDestinationSelected: isSaving
            ? null
            : ref.read(navIndexProvider.notifier).set,
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.primaryColor.withValues(alpha: .12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.swap_horiz),
            selectedIcon: Icon(Icons.swap_horiz, color: AppColors.primaryColor),
            label: 'Converter',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up),
            selectedIcon: Icon(
              Icons.trending_up,
              color: AppColors.primaryColor,
            ),
            label: 'Rates',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: AppColors.primaryColor),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
