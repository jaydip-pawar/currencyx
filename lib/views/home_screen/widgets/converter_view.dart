import 'package:currencyx/common/constants/colors.dart';
import 'package:currencyx/models/currency_data/currency_data.dart';
import 'package:currencyx/views/home_screen/viewmodel/home_viewmodel.dart';
import 'package:currencyx/views/home_screen/widgets/add_currency_button.dart';
import 'package:currencyx/views/home_screen/widgets/calculate_button.dart';
import 'package:currencyx/views/home_screen/widgets/currency_row.dart';
import 'package:currencyx/views/home_screen/widgets/status_indicator.dart';
import 'package:currencyx/views/home_screen/widgets/total_value_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConverterView extends ConsumerStatefulWidget {
  const ConverterView({super.key});

  @override
  ConsumerState<ConverterView> createState() => _ConverterViewState();
}

class _ConverterViewState extends ConsumerState<ConverterView> {
  final _controllers = <int, TextEditingController>{};
  bool _hasAmount = false;

  TextEditingController _controllerFor(int id) =>
      _controllers.putIfAbsent(id, TextEditingController.new);

  void _checkAmounts() {
    final has = _controllers.values.any(
      (c) => (double.tryParse(c.text) ?? 0) > 0,
    );
    if (has != _hasAmount) setState(() => _hasAmount = has);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onCalculate() {
    final entries = ref.read(entriesProvider);
    final data = entries
        .map(
          (e) => (
            code: e.currency,
            amount: double.tryParse(_controllerFor(e.id).text) ?? 0,
          ),
        )
        .toList();
    ref.read(calculationProvider.notifier).calculate(data);
  }

  void _cleanupControllers(List<EntryData> entries) {
    final activeIds = entries.map((e) => e.id).toSet();
    final staleIds = _controllers.keys
        .where((id) => !activeIds.contains(id))
        .toList();
    for (final id in staleIds) {
      _controllers[id]?.dispose();
      _controllers.remove(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(entriesProvider);
    final calcState = ref.watch(calculationProvider);
    final baseCurrency = ref.watch(baseCurrencyProvider);
    ref.watch(tickProvider);

    final currencyItems =
        ref
            .watch(homeViewModelProvider)
            .value
            ?.map((e) => CurrencyItem(code: e.code, name: e.name))
            .toList() ??
        [];
    final baseSymbol = CurrencyData.symbolFor(baseCurrency);
    final baseName =
        ref
            .watch(homeViewModelProvider)
            .value
            ?.where((c) => c.code == baseCurrency)
            .firstOrNull
            ?.name ??
        baseCurrency;
    final canDelete = entries.length > 1;

    _cleanupControllers(entries);

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAmounts());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Text(
            'Currency Converter',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Convert and sum multiple currencies instantly',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.labelTextColor.withValues(alpha: .9),
            ),
          ),
          const SizedBox(height: 24),
          TotalValueCard(
            totalValue: '$baseSymbol ${calcState.total.formatSum}',
            baseCurrency: baseCurrency,
            baseCurrencyLabel: baseName,
          ),
          const SizedBox(height: 24),
          for (int i = 0; i < entries.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            CurrencyRow(
              amountController: _controllerFor(entries[i].id),
              selectedCurrency: entries[i].currency,
              currencies: currencyItems,
              canDelete: canDelete,
              onAmountChanged: _checkAmounts,
              onCurrencyChanged: (value) {
                if (value != null) {
                  ref
                      .read(entriesProvider.notifier)
                      .updateCurrency(entries[i].id, value);
                }
              },
              onDelete: () =>
                  ref.read(entriesProvider.notifier).remove(entries[i].id),
            ),
          ],
          const SizedBox(height: 16),
          AddCurrencyButton(onPressed: ref.read(entriesProvider.notifier).add),
          const SizedBox(height: 24),
          CalculateButton(
            onPressed: (!_hasAmount || calcState.isCalculating)
                ? null
                : _onCalculate,
            isLoading: calcState.isCalculating,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StatusIndicator(
                icon: Icons.update,
                label: ref.read(calculationProvider.notifier).updatedAgoLabel(),
              ),
              const SizedBox(width: 24),
              const StatusIndicator(
                icon: Icons.public,
                label: 'Live Market Rates',
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
