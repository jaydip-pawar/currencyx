import 'package:currencyx/common/mapper/mapper_init.init.dart';
import 'package:currencyx/models/currency_data/currency_data.dart';
import 'package:currencyx/models/rates/rates.dart';
import 'package:currencyx/models/symbols/symbols.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(initializeMappers);

  group('Rates model', () {
    test('parses from JSON correctly', () {
      final json = <String, dynamic>{
        'success': true,
        'timestamp': 1234567890,
        'base': 'USD',
        'date': '2026-03-13',
        'rates': <String, dynamic>{'EUR': 0.85, 'GBP': 0.73},
      };

      final rates = MapperContainer.globals.fromValue<Rates>(json);

      expect(rates.success, true);
      expect(rates.timestamp, 1234567890);
      expect(rates.base, 'USD');
      expect(rates.date, '2026-03-13');
      expect(rates.rates['EUR'], 0.85);
      expect(rates.rates['GBP'], 0.73);
      expect(rates.rates.length, 2);
    });

    test('handles empty rates map', () {
      final json = <String, dynamic>{
        'success': true,
        'timestamp': 0,
        'base': 'USD',
        'date': '2026-01-01',
        'rates': <String, dynamic>{},
      };

      final rates = MapperContainer.globals.fromValue<Rates>(json);

      expect(rates.rates, isEmpty);
    });
  });

  group('Symbols model', () {
    test('parses from JSON correctly', () {
      final json = <String, dynamic>{
        'success': true,
        'symbols': <String, dynamic>{
          'USD': 'United States Dollar',
          'EUR': 'Euro',
        },
      };

      final symbols = MapperContainer.globals.fromValue<Symbols>(json);

      expect(symbols.success, true);
      expect(symbols.symbols['USD'], 'United States Dollar');
      expect(symbols.symbols['EUR'], 'Euro');
      expect(symbols.symbols.length, 2);
    });

    test('handles empty symbols map', () {
      final json = <String, dynamic>{
        'success': true,
        'symbols': <String, dynamic>{},
      };

      final symbols = MapperContainer.globals.fromValue<Symbols>(json);

      expect(symbols.symbols, isEmpty);
    });
  });

  group('CurrencyData', () {
    test('assigns symbol from static map', () {
      final data = CurrencyData(
        code: 'USD',
        name: 'US Dollar',
        timestamp: 0,
        rate: 1.0,
      );

      expect(data.symbol, r'$');
    });

    test('uses code as fallback symbol for unknown currency', () {
      final data = CurrencyData(
        code: 'XYZ',
        name: 'Unknown',
        timestamp: 0,
        rate: 1.0,
      );

      expect(data.symbol, 'XYZ');
    });

    test('symbolFor returns correct symbols', () {
      expect(CurrencyData.symbolFor('EUR'), '€');
      expect(CurrencyData.symbolFor('GBP'), '£');
      expect(CurrencyData.symbolFor('JPY'), '¥');
      expect(CurrencyData.symbolFor('INR'), '₹');
      expect(CurrencyData.symbolFor('XYZ'), 'XYZ');
    });
  });

  group('NumAmountExt.formatSum', () {
    test('formats null as empty string', () {
      const num? value = null;

      expect(value.formatSum, '');
    });

    test('formats zero', () {
      expect(0.formatSum, '00.00');
    });

    test('formats small number with leading zero', () {
      expect(5.5.formatSum, '05.50');
    });

    test('formats with two decimal places', () {
      expect(123.456.formatSum, '123.46');
    });

    test('formats with thousand separators', () {
      expect(1234567.89.formatSum, '1,234,567.89');
    });

    test('formats negative number', () {
      expect((-1234.56).formatSum, '-1,234.56');
    });

    test('formats integer value', () {
      expect(100.formatSum, '100.00');
    });
  });
}
