import 'package:currencyx/models/currency_data/currency_data.dart';
import 'package:currencyx/models/entity/network_error.dart';
import 'package:currencyx/models/rates/rates.dart';
import 'package:currencyx/models/symbols/symbols.dart';
import 'package:currencyx/repositories/currency_repository.dart';
import 'package:currencyx/services/api_services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:twofold/twofold.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApi;
  late CurrencyRepository repository;

  setUp(() {
    mockApi = MockApiService();
    repository = CurrencyRepository(mockApi);
  });

  group('fetchCurrencies', () {
    test('returns currency list on success', () async {
      when(() => mockApi.fetchSymbols()).thenAnswer(
        (_) async =>
            Twofold.success(Symbols(true, {'USD': 'US Dollar', 'EUR': 'Euro'})),
      );
      when(() => mockApi.fetchLatestRates(base: any(named: 'base'))).thenAnswer(
        (_) async => Twofold.success(
          Rates(true, 1234567890, 'USD', '2026-03-13', {
            'USD': 1.0,
            'EUR': 0.85,
          }),
        ),
      );

      final result = await repository.fetchCurrencies(base: 'USD');

      expect(result, isA<List<CurrencyData>>());
      expect(result.length, 2);
      expect(result.any((c) => c.code == 'USD'), true);
      expect(result.any((c) => c.code == 'EUR'), true);

      final usd = result.firstWhere((c) => c.code == 'USD');
      expect(usd.name, 'US Dollar');
      expect(usd.rate, 1.0);
      expect(usd.timestamp, 1234567890);
    });

    test('throws on symbols API error', () async {
      when(() => mockApi.fetchSymbols()).thenAnswer(
        (_) async => Twofold.error(
          const NetworkError(cause: 'error', message: 'Symbols failed'),
        ),
      );
      when(() => mockApi.fetchLatestRates(base: any(named: 'base'))).thenAnswer(
        (_) async => Twofold.success(
          Rates(true, 1234567890, 'USD', '2026-03-13', {'USD': 1.0}),
        ),
      );

      expect(
        () => repository.fetchCurrencies(base: 'USD'),
        throwsA(isA<Exception>()),
      );
    });

    test('throws on rates API error', () async {
      when(() => mockApi.fetchSymbols()).thenAnswer(
        (_) async => Twofold.success(Symbols(true, {'USD': 'US Dollar'})),
      );
      when(() => mockApi.fetchLatestRates(base: any(named: 'base'))).thenAnswer(
        (_) async => Twofold.error(
          const NetworkError(cause: 'error', message: 'Rates failed'),
        ),
      );

      expect(
        () => repository.fetchCurrencies(base: 'USD'),
        throwsA(isA<Exception>()),
      );
    });

    test('passes base currency to API', () async {
      when(() => mockApi.fetchSymbols()).thenAnswer(
        (_) async => Twofold.success(Symbols(true, {'EUR': 'Euro'})),
      );
      when(() => mockApi.fetchLatestRates(base: any(named: 'base'))).thenAnswer(
        (_) async =>
            Twofold.success(Rates(true, 0, 'EUR', '2026-03-13', {'EUR': 1.0})),
      );

      await repository.fetchCurrencies(base: 'EUR');

      verify(() => mockApi.fetchLatestRates(base: 'EUR')).called(1);
    });
  });

  group('refreshRates', () {
    test('returns currency list using cached symbols', () async {
      // First call to populate symbols cache
      when(() => mockApi.fetchSymbols()).thenAnswer(
        (_) async =>
            Twofold.success(Symbols(true, {'USD': 'US Dollar', 'EUR': 'Euro'})),
      );
      when(() => mockApi.fetchLatestRates(base: any(named: 'base'))).thenAnswer(
        (_) async => Twofold.success(
          Rates(true, 1000, 'USD', '2026-03-13', {'USD': 1.0, 'EUR': 0.85}),
        ),
      );
      await repository.fetchCurrencies(base: 'USD');

      // Now refresh with new rates
      when(() => mockApi.fetchLatestRates(base: any(named: 'base'))).thenAnswer(
        (_) async => Twofold.success(
          Rates(true, 2000, 'EUR', '2026-03-13', {'USD': 1.18, 'EUR': 1.0}),
        ),
      );

      final result = await repository.refreshRates(base: 'EUR');

      expect(result.length, 2);
      expect(result.firstWhere((c) => c.code == 'USD').name, 'US Dollar');
      expect(result.firstWhere((c) => c.code == 'USD').rate, 1.18);
      verify(() => mockApi.fetchLatestRates(base: 'EUR')).called(1);
    });

    test('throws on rates error', () async {
      when(() => mockApi.fetchLatestRates(base: any(named: 'base'))).thenAnswer(
        (_) async => Twofold.error(
          const NetworkError(cause: 'error', message: 'Network error'),
        ),
      );

      expect(
        () => repository.refreshRates(base: 'USD'),
        throwsA(isA<Exception>()),
      );
    });

    test('uses code as fallback name when symbols not cached', () async {
      when(() => mockApi.fetchLatestRates(base: any(named: 'base'))).thenAnswer(
        (_) async => Twofold.success(
          Rates(true, 1000, 'USD', '2026-03-13', {'XYZ': 1.5}),
        ),
      );

      final result = await repository.refreshRates(base: 'USD');

      expect(result.first.code, 'XYZ');
      expect(result.first.name, 'XYZ');
    });
  });
}
