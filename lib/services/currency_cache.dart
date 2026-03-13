import 'package:hive/hive.dart';

class CurrencyCache {
  static const _boxName = 'currencies';
  static const _settingsBoxName = 'settings';
  static const _baseCurrencyKey = 'baseCurrency';

  late Box<Map<dynamic, dynamic>> _box;
  late Box<dynamic> _settingsBox;

  Future<void> init() async {
    _box = await Hive.openBox<Map<dynamic, dynamic>>(_boxName);
    _settingsBox = await Hive.openBox<dynamic>(_settingsBoxName);
  }

  List<Map<String, dynamic>> getAll() =>
      _box.values.map(Map<String, dynamic>.from).toList();

  Future<void> saveAll(List<Map<String, dynamic>> currencies) async {
    await _box.clear();
    for (final currency in currencies) {
      await _box.put(currency['code'], currency);
    }
  }

  bool get hasData => _box.isNotEmpty;

  Future<void> clearAll() => _box.clear();

  String get baseCurrency =>
      _settingsBox.get(_baseCurrencyKey, defaultValue: 'USD') as String;

  Future<void> setBaseCurrency(String code) =>
      _settingsBox.put(_baseCurrencyKey, code);
}
