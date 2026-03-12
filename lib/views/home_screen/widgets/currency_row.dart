import 'package:currencyx/common/constants/colors.dart';
import 'package:currencyx/common/widgets/searchable_dropdown.dart';
import 'package:currencyx/models/currency_data/currency_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CurrencyRow extends StatelessWidget {
  const CurrencyRow({
    required this.amountController,
    required this.selectedCurrency,
    required this.currencies,
    required this.onCurrencyChanged,
    required this.onDelete,
    this.canDelete = true,
    this.onAmountChanged,
    super.key,
  });

  final TextEditingController amountController;
  final String selectedCurrency;
  final List<CurrencyItem> currencies;
  final ValueChanged<String?> onCurrencyChanged;
  final VoidCallback onDelete;
  final bool canDelete;
  final VoidCallback? onAmountChanged;

  String get _symbol => CurrencyData.symbolFor(selectedCurrency);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primaryColorShadowColor),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: .04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'AMOUNT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.labelTextColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                onChanged: (_) => onAmountChanged?.call(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.inputFillColor,
                  prefixText: '$_symbol  ',
                  prefixStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.labelTextColor,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primaryColorShadowColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primaryColorShadowColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primaryColor,
                      width: 2,
                    ),
                  ),
                  hintText: '0.00',
                  hintStyle: TextStyle(
                    color: AppColors.labelTextColor.withValues(alpha: .6),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'CURRENCY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.labelTextColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SearchableDropdown<CurrencyItem>(
                items: currencies,
                selectedItem: currencies
                    .where((c) => c.code == selectedCurrency)
                    .firstOrNull,
                hintText: 'Select',
                searchHintText: 'Search currency...',
                headerBuilder: (item) => Text(
                  item.code,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColor,
                  ),
                ),
                onChanged: (value) => onCurrencyChanged(value.code),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: canDelete ? onDelete : null,
          icon: const Icon(Icons.delete_outline),
          color: canDelete ? AppColors.labelTextColor : AppColors.bulletColor,
          splashRadius: 24,
        ),
      ],
    ),
  );
}

class CurrencyItem with SearchableItem {
  const CurrencyItem({required this.code, required this.name});

  final String code;
  final String name;

  @override
  String toString() => '$code - $name';

  @override
  bool filter(String query) {
    final q = query.toLowerCase();
    return code.toLowerCase().contains(q) || name.toLowerCase().contains(q);
  }
}
