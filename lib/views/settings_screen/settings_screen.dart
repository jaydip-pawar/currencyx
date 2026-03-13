import 'package:currencyx/common/constants/colors.dart';
import 'package:currencyx/common/widgets/searchable_dropdown.dart';
import 'package:currencyx/views/home_screen/viewmodel/home_viewmodel.dart';
import 'package:currencyx/views/home_screen/widgets/currency_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _pendingCurrency;
  bool _isSaving = false;

  Future<void> _onSave() async {
    final code = _pendingCurrency;
    if (code == null) return;

    setState(() => _isSaving = true);
    ref.read(settingsSavingProvider.notifier).set(true);
    final success = await ref.read(baseCurrencyProvider.notifier).set(code);
    if (!mounted) return;
    ref.read(settingsSavingProvider.notifier).set(false);
    setState(() => _isSaving = false);

    if (success) {
      setState(() => _pendingCurrency = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Base currency updated'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseCurrency = ref.watch(baseCurrencyProvider);
    final currencyItems =
        ref
            .watch(homeViewModelProvider)
            .value
            ?.map((e) => CurrencyItem(code: e.code, name: e.name))
            .toList() ??
        [];

    final displayCurrency = _pendingCurrency ?? baseCurrency;
    final hasChanges =
        _pendingCurrency != null && _pendingCurrency != baseCurrency;

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
              IgnorePointer(
                ignoring: _isSaving,
                child: SearchableDropdown<CurrencyItem>(
                  items: currencyItems,
                  selectedItem: currencyItems
                      .where((c) => c.code == displayCurrency)
                      .firstOrNull,
                  hintText: 'Select currency',
                  searchHintText: 'Search currency...',
                  onChanged: (value) {
                    setState(() => _pendingCurrency = value.code);
                  },
                ),
              ),
              if (hasChanges) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
