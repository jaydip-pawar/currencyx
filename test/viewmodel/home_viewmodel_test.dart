import 'package:currencyx/models/currency_data/currency_data.dart';
import 'package:currencyx/repositories/currency_repository.dart';
import 'package:currencyx/services/currency_cache.dart';
import 'package:currencyx/views/home_screen/viewmodel/home_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCurrencyRepository extends Mock implements CurrencyRepository {}

class MockCurrencyCache extends Mock implements CurrencyCache {}

void main() {
  late MockCurrencyRepository mockRepo;
  late MockCurrencyCache mockCache;
  late ProviderContainer container;

  final testCurrencies = [
    CurrencyData(
      code: 'USD',
      name: 'US Dollar',
      timestamp: 1234567890,
      rate: 1.0,
    ),
    CurrencyData(code: 'EUR', name: 'Euro', timestamp: 1234567890, rate: 0.85),
  ];

  setUp(() {
    mockRepo = MockCurrencyRepository();
    mockCache = MockCurrencyCache();
    when(() => mockRepo.loadFromCache()).thenReturn([]);
    when(() => mockCache.baseCurrency).thenReturn('USD');
    when(() => mockCache.setBaseCurrency(any())).thenAnswer((_) async {});
    when(() => mockCache.clearAll()).thenAnswer((_) async {});
    container = ProviderContainer(
      overrides: [
        currencyRepositoryProvider.overrideWithValue(mockRepo),
        currencyCacheProvider.overrideWithValue(mockCache),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('HomeViewModel', () {
    test('fetches currencies on build', () async {
      when(
        () => mockRepo.fetchCurrencies(base: any(named: 'base')),
      ).thenAnswer((_) async => testCurrencies);

      final result = await container.read(homeViewModelProvider.future);

      expect(result, testCurrencies);
      verify(() => mockRepo.fetchCurrencies(base: 'USD')).called(1);
    });

    test('sets error state on fetch failure', () async {
      when(
        () => mockRepo.fetchCurrencies(base: any(named: 'base')),
      ).thenAnswer((_) async => throw Exception('Network error'));

      // Trigger provider build
      container.listen(homeViewModelProvider, (_, _) {});
      // Allow async build to complete
      await Future<void>.delayed(Duration.zero);

      expect(container.read(homeViewModelProvider).hasError, true);
    });

    test('refreshRates updates state with new data', () async {
      when(
        () => mockRepo.fetchCurrencies(base: any(named: 'base')),
      ).thenAnswer((_) async => testCurrencies);
      when(
        () => mockRepo.refreshRates(base: any(named: 'base')),
      ).thenAnswer((_) async => testCurrencies);

      await container.read(homeViewModelProvider.future);
      await container.read(homeViewModelProvider.notifier).refreshRates();

      expect(container.read(homeViewModelProvider).value, testCurrencies);
      verify(() => mockRepo.refreshRates(base: 'USD')).called(1);
    });

    test('refreshRates sets error on failure', () async {
      when(
        () => mockRepo.fetchCurrencies(base: any(named: 'base')),
      ).thenAnswer((_) async => testCurrencies);
      when(
        () => mockRepo.refreshRates(base: any(named: 'base')),
      ).thenThrow(Exception('Refresh failed'));

      await container.read(homeViewModelProvider.future);
      await container.read(homeViewModelProvider.notifier).refreshRates();

      expect(container.read(homeViewModelProvider).hasError, true);
    });
  });

  group('BaseCurrencyNotifier', () {
    test('initial value is USD', () {
      expect(container.read(baseCurrencyProvider), 'USD');
    });

    test('set updates currency and triggers refresh', () async {
      when(
        () => mockRepo.fetchCurrencies(base: any(named: 'base')),
      ).thenAnswer((_) async => testCurrencies);

      // Initialize viewmodel first
      await container.read(homeViewModelProvider.future);

      final success = await container
          .read(baseCurrencyProvider.notifier)
          .set('EUR');

      expect(success, true);
      expect(container.read(baseCurrencyProvider), 'EUR');
      verify(() => mockCache.setBaseCurrency('EUR')).called(1);
      verify(() => mockRepo.fetchCurrencies(base: 'EUR')).called(1);
    });

    test('set returns false on API failure', () async {
      when(
        () => mockRepo.fetchCurrencies(base: any(named: 'base')),
      ).thenAnswer((_) async => testCurrencies);

      await container.read(homeViewModelProvider.future);

      when(
        () => mockRepo.fetchCurrencies(base: 'XYZ'),
      ).thenThrow(Exception('API error'));

      final success = await container
          .read(baseCurrencyProvider.notifier)
          .set('XYZ');

      expect(success, false);
      expect(container.read(baseCurrencyProvider), 'USD');
    });

    test('set with same value does nothing', () async {
      final success = await container
          .read(baseCurrencyProvider.notifier)
          .set('USD');

      expect(success, true);
      expect(container.read(baseCurrencyProvider), 'USD');
      verifyNever(() => mockRepo.fetchCurrencies(base: any(named: 'base')));
    });
  });

  group('EntriesNotifier', () {
    test('starts with one USD entry', () {
      final entries = container.read(entriesProvider);

      expect(entries.length, 1);
      expect(entries.first.currency, 'USD');
    });

    test('add creates new entry', () {
      container.read(entriesProvider.notifier).add();
      final entries = container.read(entriesProvider);

      expect(entries.length, 2);
    });

    test('remove deletes entry when more than one', () {
      container.read(entriesProvider.notifier).add();
      final entries = container.read(entriesProvider);

      container.read(entriesProvider.notifier).remove(entries.last.id);

      expect(container.read(entriesProvider).length, 1);
    });

    test('remove does not delete last entry', () {
      final entries = container.read(entriesProvider);

      container.read(entriesProvider.notifier).remove(entries.first.id);

      expect(container.read(entriesProvider).length, 1);
    });

    test('updateCurrency changes entry currency', () {
      final entries = container.read(entriesProvider);

      container
          .read(entriesProvider.notifier)
          .updateCurrency(entries.first.id, 'EUR');

      expect(container.read(entriesProvider).first.currency, 'EUR');
    });

    test('entries have unique IDs', () {
      container.read(entriesProvider.notifier).add();
      container.read(entriesProvider.notifier).add();
      final entries = container.read(entriesProvider);
      final ids = entries.map((e) => e.id).toSet();

      expect(ids.length, entries.length);
    });
  });

  group('CalculationNotifier', () {
    test('initial state has zero total', () {
      final state = container.read(calculationProvider);

      expect(state.total, 0);
      expect(state.isCalculating, false);
    });

    test('calculates total correctly', () async {
      when(
        () => mockRepo.fetchCurrencies(base: any(named: 'base')),
      ).thenAnswer((_) async => testCurrencies);

      await container.read(homeViewModelProvider.future);

      await container.read(calculationProvider.notifier).calculate([
        (code: 'EUR', amount: 85.0),
      ]);

      final state = container.read(calculationProvider);

      expect(state.total, 100.0); // 85 / 0.85 = 100
      expect(state.isCalculating, false);
    });

    test('calculates total from multiple entries', () async {
      when(
        () => mockRepo.fetchCurrencies(base: any(named: 'base')),
      ).thenAnswer((_) async => testCurrencies);

      await container.read(homeViewModelProvider.future);

      await container.read(calculationProvider.notifier).calculate([
        (code: 'USD', amount: 50.0),
        (code: 'EUR', amount: 85.0),
      ]);

      final state = container.read(calculationProvider);

      // 50/1.0 + 85/0.85 = 50 + 100 = 150
      expect(state.total, 150.0);
    });

    test('skips entries with zero amount', () async {
      when(
        () => mockRepo.fetchCurrencies(base: any(named: 'base')),
      ).thenAnswer((_) async => testCurrencies);

      await container.read(homeViewModelProvider.future);

      await container.read(calculationProvider.notifier).calculate([
        (code: 'EUR', amount: 0.0),
      ]);

      expect(container.read(calculationProvider).total, 0.0);
    });

    test('skips unknown currency codes', () async {
      when(
        () => mockRepo.fetchCurrencies(base: any(named: 'base')),
      ).thenAnswer((_) async => testCurrencies);

      await container.read(homeViewModelProvider.future);

      await container.read(calculationProvider.notifier).calculate([
        (code: 'XYZ', amount: 100.0),
      ]);

      expect(container.read(calculationProvider).total, 0.0);
    });

    test('updatedAgoLabel returns not updated yet when no timestamp', () {
      final label = container
          .read(calculationProvider.notifier)
          .updatedAgoLabel();

      expect(label, 'Not updated yet');
    });
  });

  group('NavIndexNotifier', () {
    test('initial value is 0', () {
      expect(container.read(navIndexProvider), 0);
    });

    test('set updates index', () {
      container.read(navIndexProvider.notifier).set(2);

      expect(container.read(navIndexProvider), 2);
    });
  });
}
