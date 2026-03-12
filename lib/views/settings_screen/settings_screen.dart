import 'package:currencyx/common/constants/colors.dart';
import 'package:currencyx/common/widgets/searchable_dropdown.dart';
import 'package:currencyx/views/home_screen/viewmodel/home_viewmodel.dart';
import 'package:currencyx/views/home_screen/widgets/currency_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseCurrency = ref.watch(baseCurrencyProvider);
    final currencyItems =
        ref
            .watch(homeViewModelProvider)
            .value
            ?.map((e) => CurrencyItem(code: e.code, name: e.name))
            .toList() ??
        [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'PREFERENCES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.labelTextColor,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryColorShadowColor),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Primary Currency',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              SearchableDropdown<CurrencyItem>(
                items: currencyItems,
                selectedItem: currencyItems
                    .where((c) => c.code == baseCurrency)
                    .firstOrNull,
                hintText: 'Select currency',
                searchHintText: 'Search currency...',
                onChanged: (value) {
                  ref.read(baseCurrencyProvider.notifier).set(value.code);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
