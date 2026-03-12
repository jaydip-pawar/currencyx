import 'package:currencyx/common/constants/colors.dart';
import 'package:flutter/material.dart';

mixin SearchableItem {
  bool filter(String query);
}

class SearchableDropdown<T extends Object> extends StatefulWidget {
  const SearchableDropdown({
    required this.items,
    required this.onChanged,
    this.selectedItem,
    this.hintText = 'Select',
    this.searchHintText = 'Search...',
    this.headerBuilder,
    this.overlayHeight = 300,
    super.key,
  });

  final List<T> items;
  final T? selectedItem;
  final ValueChanged<T> onChanged;
  final String hintText;
  final String searchHintText;
  final Widget Function(T item)? headerBuilder;
  final double overlayHeight;

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T extends Object>
    extends State<SearchableDropdown<T>>
    with SingleTickerProviderStateMixin {
  final _overlayController = OverlayPortalController();
  final _searchController = TextEditingController();
  late List<T> _filtered;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(covariant SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filtered = widget.items;
      _searchController.clear();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _show() {
    _searchController.clear();
    _filtered = widget.items;
    _overlayController.show();
    _animController.forward(from: 0);
  }

  void _hide() {
    _animController.reverse().then((_) {
      if (_overlayController.isShowing) _overlayController.hide();
    });
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = widget.items;
      } else {
        _filtered = widget.items.where((item) {
          if (item is SearchableItem) {
            return (item as SearchableItem).filter(query);
          }
          return item.toString().toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _onSelect(T item) {
    _animController.reset();
    if (_overlayController.isShowing) _overlayController.hide();
    widget.onChanged(item);
  }

  @override
  Widget build(BuildContext context) => OverlayPortal(
    controller: _overlayController,
    overlayChildBuilder: (_) => _buildOverlay(context),
    child: GestureDetector(
      onTap: _show,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.inputFillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryColorShadowColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: widget.selectedItem != null
                  ? (widget.headerBuilder != null
                        ? widget.headerBuilder!(widget.selectedItem as T)
                        : Text(
                            widget.selectedItem.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ))
                  : Text(
                      widget.hintText,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.labelTextColor,
                      ),
                    ),
            ),
            const Icon(
              Icons.expand_more,
              color: AppColors.labelTextColor,
              size: 20,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildOverlay(BuildContext outerContext) {
    final renderBox = context.findRenderObject() as RenderBox;
    final triggerPos = renderBox.localToGlobal(Offset.zero);
    final top = triggerPos.dy + renderBox.size.height + 4;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _hide,
      child: Stack(
        children: [
          Positioned(
            left: 16,
            right: 16,
            top: top,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Material(
                elevation: 8,
                shadowColor: AppColors.black.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(12),
                color: AppColors.white,
                child: Container(
                  constraints: BoxConstraints(maxHeight: widget.overlayHeight),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearch,
                          autofocus: true,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textColor,
                          ),
                          decoration: InputDecoration(
                            hintText: widget.searchHintText,
                            hintStyle: const TextStyle(
                              color: AppColors.labelTextColor,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 20,
                              color: AppColors.labelTextColor,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.primaryColorShadowColor,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.primaryColorShadowColor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.primaryColor,
                              ),
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                      Flexible(
                        child: _filtered.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'No results found',
                                  style: TextStyle(
                                    color: AppColors.labelTextColor,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: _filtered.length,
                                itemBuilder: (_, index) {
                                  final item = _filtered[index];
                                  final isSelected =
                                      item == widget.selectedItem;
                                  return InkWell(
                                    onTap: () => _onSelect(item),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      color: isSelected
                                          ? AppColors.primaryColor.withValues(
                                              alpha: .08,
                                            )
                                          : null,
                                      child: Text(
                                        item.toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? AppColors.primaryColor
                                              : AppColors.textColor,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
