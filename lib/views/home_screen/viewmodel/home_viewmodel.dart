import 'dart:async';

import 'package:currencyx/models/currency_data/currency_data.dart';
import 'package:currencyx/repositories/currency_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeViewModelProvider =
    AsyncNotifierProvider<HomeViewModel, List<CurrencyData>>(HomeViewModel.new);

final calculationProvider =
    NotifierProvider<CalculationNotifier, CalculationState>(
      CalculationNotifier.new,
    );

final entriesProvider = NotifierProvider<EntriesNotifier, List<EntryData>>(
  EntriesNotifier.new,
);

final navIndexProvider = NotifierProvider<NavIndexNotifier, int>(
  NavIndexNotifier.new,
);

final baseCurrencyProvider = NotifierProvider<BaseCurrencyNotifier, String>(
  BaseCurrencyNotifier.new,
);

final tickProvider = NotifierProvider<TickNotifier, int>(TickNotifier.new);

class NavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int index) => state = index;
}

class BaseCurrencyNotifier extends Notifier<String> {
  @override
  String build() => 'USD';

  void set(String code) {
    if (code == state) return;
    state = code;
    ref.read(homeViewModelProvider.notifier).refreshRates();
  }
}

class TickNotifier extends Notifier<int> {
  Timer? _timer;

  @override
  int build() {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => state++);
    ref.onDispose(() => _timer?.cancel());
    return 0;
  }
}

class EntryData {
  EntryData({required this.id, required this.currency});

  final int id;
  final String currency;

  EntryData copyWith({String? currency}) =>
      EntryData(id: id, currency: currency ?? this.currency);
}

class EntriesNotifier extends Notifier<List<EntryData>> {
  int _nextId = 1;

  @override
  List<EntryData> build() => [EntryData(id: _nextId++, currency: 'USD')];

  void add() {
    state = [...state, EntryData(id: _nextId++, currency: 'USD')];
  }

  void remove(int id) {
    if (state.length <= 1) return;
    state = state.where((e) => e.id != id).toList();
  }

  void updateCurrency(int id, String currency) {
    state = [
      for (final e in state)
        if (e.id == id) e.copyWith(currency: currency) else e,
    ];
  }
}

class CalculationState {
  const CalculationState({
    this.total = 0,
    this.timestamp,
    this.isCalculating = false,
  });

  final double total;
  final int? timestamp;
  final bool isCalculating;

  CalculationState copyWith({
    double? total,
    int? timestamp,
    bool? isCalculating,
  }) => CalculationState(
    total: total ?? this.total,
    timestamp: timestamp ?? this.timestamp,
    isCalculating: isCalculating ?? this.isCalculating,
  );
}

class CalculationNotifier extends Notifier<CalculationState> {
  @override
  CalculationState build() => const CalculationState();

  Future<void> calculate(List<({String code, double amount})> entries) async {
    state = state.copyWith(isCalculating: true);

    await ref.read(homeViewModelProvider.notifier).refreshRates();
    final currencies = ref.read(homeViewModelProvider).value ?? [];

    double total = 0;
    for (final entry in entries) {
      final data = currencies.where((c) => c.code == entry.code).firstOrNull;
      if (data != null && data.rate > 0 && entry.amount > 0) {
        total += entry.amount / data.rate;
      }
    }

    final timestamp = currencies.isNotEmpty ? currencies.first.timestamp : null;
    state = CalculationState(total: total, timestamp: timestamp);
  }

  String updatedAgoLabel() {
    if (state.timestamp == null) return 'Not updated yet';
    final updatedAt = DateTime.fromMillisecondsSinceEpoch(
      state.timestamp! * 1000,
    );
    final diff = DateTime.now().difference(updatedAt);
    if (diff.inSeconds < 60) return 'Updated just now';
    if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Updated ${diff.inHours}h ago';
    return 'Updated ${diff.inDays}d ago';
  }
}

class HomeViewModel extends AsyncNotifier<List<CurrencyData>> {
  @override
  Future<List<CurrencyData>> build() async {
    final base = ref.read(baseCurrencyProvider);
    return ref.read(currencyRepositoryProvider).fetchCurrencies(base: base);
  }

  Future<void> refreshRates() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final base = ref.read(baseCurrencyProvider);
      return ref.read(currencyRepositoryProvider).refreshRates(base: base);
    });
  }
}
