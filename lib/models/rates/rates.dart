import 'package:dart_mappable/dart_mappable.dart';

part 'rates.mapper.dart';

@MappableClass()
class Rates with RatesMappable {
  Rates(this.success, this.timestamp, this.base, this.date, this.rates);
  
  final bool success;
  final int timestamp;
  final String base;
  final String date;
  final Map<String, double> rates;
}
