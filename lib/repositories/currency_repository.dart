import 'package:currencyx/models/currency_data/currency_data.dart';
import 'package:currencyx/models/entity/network_error.dart';
import 'package:currencyx/models/rates/rates.dart';
import 'package:currencyx/models/symbols/symbols.dart';
import 'package:currencyx/services/api_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twofold/twofold.dart';

final apiServiceProvider = Provider<ApiService>((_) => ApiService());

final currencyRepositoryProvider = Provider<CurrencyRepository>(
  (ref) => CurrencyRepository(ref.read(apiServiceProvider)),
);

class CurrencyRepository {
  CurrencyRepository(this._api);

  final ApiService _api;
  Map<String, String> _symbolsMap = {};

  Future<List<CurrencyData>> fetchCurrencies({String base = 'USD'}) async {
    final results = await Future.wait([
      _api.fetchSymbols(),
      _api.fetchLatestRates(base: base),
    ]);

    final symbolsResult = results[0] as Twofold<Symbols, NetworkError>;
    final ratesResult = results[1] as Twofold<Rates, NetworkError>;

    String? errorMsg;
    Map<String, double> ratesMap = {};
    int timestamp = 0;

    symbolsResult.when(
      onSuccess: (symbols) => _symbolsMap = symbols.symbols,
      onError: (e) => errorMsg = e.getFriendlyMessage(),
    );

    ratesResult.when(
      onSuccess: (rates) {
        ratesMap = rates.rates;
        timestamp = rates.timestamp;
      },
      onError: (e) => errorMsg ??= e.getFriendlyMessage(),
    );

    if (errorMsg != null) throw Exception(errorMsg);

    return _buildCurrencyList(ratesMap, timestamp);
  }

  Future<List<CurrencyData>> refreshRates({String base = 'USD'}) async {
    final result = await _api.fetchLatestRates(base: base);

    Map<String, double> ratesMap = {};
    int timestamp = 0;
    String? errorMsg;

    result.when(
      onSuccess: (rates) {
        ratesMap = rates.rates;
        timestamp = rates.timestamp;
      },
      onError: (e) => errorMsg = e.getFriendlyMessage(),
    );

    if (errorMsg != null) throw Exception(errorMsg);

    return _buildCurrencyList(ratesMap, timestamp);
  }

  List<CurrencyData> _buildCurrencyList(
    Map<String, double> ratesMap,
    int timestamp,
  ) => ratesMap.entries.map((entry) {
    final code = entry.key;
    final name = _symbolsMap[code] ?? code;
    return CurrencyData(
      code: code,
      name: name,
      timestamp: timestamp,
      rate: entry.value,
    );
  }).toList();
}
