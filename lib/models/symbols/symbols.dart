import 'package:dart_mappable/dart_mappable.dart';

part 'symbols.mapper.dart';

@MappableClass()
class Symbols with SymbolsMappable {
  Symbols(this.success, this.symbols);

  final bool success;
  final Map<String, String> symbols;
}
