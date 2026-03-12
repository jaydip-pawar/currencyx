import 'package:currencyx/common/constants/colors.dart';
import 'package:currencyx/models/currency_data/currency_data.dart';
import 'package:currencyx/views/home_screen/viewmodel/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RatesScreen extends ConsumerStatefulWidget {
  const RatesScreen({super.key});

  @override
  ConsumerState<RatesScreen> createState() => _RatesScreenState();
}

class _RatesScreenState extends ConsumerState<RatesScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(homeViewModelProvider);
    final baseCurrency = ref.watch(baseCurrencyProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            style: const TextStyle(fontSize: 15, color: AppColors.textColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.primaryColorShadowColor.withValues(
                alpha: .5,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.labelTextColor,
              ),
              hintText: 'Search currency (e.g. USD, EUR)',
              hintStyle: const TextStyle(color: AppColors.labelTextColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.primaryColorShadowColor),
              ),
            ),
            child: Text(
              'BASE: 1 $baseCurrency',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.labelTextColor,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),

        Expanded(
          child: dataAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (currencies) {
              final filtered = _query.isEmpty
                  ? currencies
                  : currencies
                        .where(
                          (c) =>
                              c.code.toLowerCase().contains(
                                _query.toLowerCase(),
                              ) ||
                              c.name.toLowerCase().contains(
                                _query.toLowerCase(),
                              ),
                        )
                        .toList();

              if (filtered.isEmpty) {
                return const Center(
                  child: Text(
                    'No currencies found',
                    style: TextStyle(color: AppColors.labelTextColor),
                  ),
                );
              }

              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, index) => _RateItem(currency: filtered[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RateItem extends StatelessWidget {
  const _RateItem({required this.currency});

  final CurrencyData currency;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: AppColors.borderColor)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currency.code,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                currency.name,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.labelTextColor,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${currency.symbol} ${currency.rate.toStringAsFixed(4)}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textColor,
          ),
        ),
      ],
    ),
  );
}
