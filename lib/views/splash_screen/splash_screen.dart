import 'package:currencyx/common/assets/app_icons.dart';
import 'package:currencyx/common/constants/colors.dart';
import 'package:currencyx/views/home_screen/home_screen.dart';
import 'package:currencyx/views/home_screen/viewmodel/home_viewmodel.dart';
import 'package:currencyx/views/splash_screen/widgets/label_icon.dart';
import 'package:currencyx/views/splash_screen/widgets/loading_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;
  int _retryCount = 0;
  static const _maxRetries = 5;

  void _retry() {
    _retryCount = 0;
    ref.invalidate(homeViewModelProvider);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(homeViewModelProvider, (previous, next) {
      if (_navigated) return;
      if (next.hasValue) {
        _navigated = true;
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        );
      }
      if (next.hasError) {
        _retryCount++;
        if (_retryCount < _maxRetries) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted && !_navigated) {
              ref.invalidate(homeViewModelProvider);
            }
          });
        } else {
          final message = '${next.error}'.replaceFirst('Exception: ', '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 30),
              action: SnackBarAction(label: 'Retry', onPressed: _retry),
            ),
          );
        }
      }
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 27),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      color: AppColors.primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: .3),
                          blurRadius: 50,
                          offset: const Offset(0, 25),
                          spreadRadius: -12,
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(20.5),
                      child: Icon(
                        AppIcons.logo,
                        color: AppColors.white,
                        size: 55,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'CurrencyX',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      height: 36 / 30,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Global currency exchange rates\nat your fingertips',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      height: 24 / 16,
                      color: AppColors.secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Column(
              children: [
                Row(
                  children: [
                    Icon(
                      AppIcons.fetch,
                      color: AppColors.primaryColor,
                      size: 13.33,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Fetching latest exchange rates...',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 21 / 14,
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                LoadingProgressBar(),
                SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LabelIcon(icon: AppIcons.shield, label: 'SECURE'),
                    LabelIcon(icon: AppIcons.earth, label: 'GLOBAL'),
                    LabelIcon(
                      icon: AppIcons.lightning,
                      label: 'INSTANT',
                      showBullet: false,
                    ),
                  ],
                ),
                SizedBox(height: 80),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
