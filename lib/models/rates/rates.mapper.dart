// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'rates.dart';

class RatesMapper extends ClassMapperBase<Rates> {
  RatesMapper._();

  static RatesMapper? _instance;
  static RatesMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RatesMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Rates';

  static bool _$success(Rates v) => v.success;
  static const Field<Rates, bool> _f$success = Field('success', _$success);
  static int _$timestamp(Rates v) => v.timestamp;
  static const Field<Rates, int> _f$timestamp = Field('timestamp', _$timestamp);
  static String _$base(Rates v) => v.base;
  static const Field<Rates, String> _f$base = Field('base', _$base);
  static String _$date(Rates v) => v.date;
  static const Field<Rates, String> _f$date = Field('date', _$date);
  static Map<String, double> _$rates(Rates v) => v.rates;
  static const Field<Rates, Map<String, double>> _f$rates = Field(
    'rates',
    _$rates,
  );

  @override
  final MappableFields<Rates> fields = const {
    #success: _f$success,
    #timestamp: _f$timestamp,
    #base: _f$base,
    #date: _f$date,
    #rates: _f$rates,
  };

  static Rates _instantiate(DecodingData data) {
    return Rates(
      data.dec(_f$success),
      data.dec(_f$timestamp),
      data.dec(_f$base),
      data.dec(_f$date),
      data.dec(_f$rates),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Rates fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Rates>(map);
  }

  static Rates fromJson(String json) {
    return ensureInitialized().decodeJson<Rates>(json);
  }
}

mixin RatesMappable {
  String toJson() {
    return RatesMapper.ensureInitialized().encodeJson<Rates>(this as Rates);
  }

  Map<String, dynamic> toMap() {
    return RatesMapper.ensureInitialized().encodeMap<Rates>(this as Rates);
  }

  RatesCopyWith<Rates, Rates, Rates> get copyWith =>
      _RatesCopyWithImpl<Rates, Rates>(this as Rates, $identity, $identity);
  @override
  String toString() {
    return RatesMapper.ensureInitialized().stringifyValue(this as Rates);
  }

  @override
  bool operator ==(Object other) {
    return RatesMapper.ensureInitialized().equalsValue(this as Rates, other);
  }

  @override
  int get hashCode {
    return RatesMapper.ensureInitialized().hashValue(this as Rates);
  }
}

extension RatesValueCopy<$R, $Out> on ObjectCopyWith<$R, Rates, $Out> {
  RatesCopyWith<$R, Rates, $Out> get $asRates =>
      $base.as((v, t, t2) => _RatesCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class RatesCopyWith<$R, $In extends Rates, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, double, ObjectCopyWith<$R, double, double>> get rates;
  $R call({
    bool? success,
    int? timestamp,
    String? base,
    String? date,
    Map<String, double>? rates,
  });
  RatesCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _RatesCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Rates, $Out>
    implements RatesCopyWith<$R, Rates, $Out> {
  _RatesCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Rates> $mapper = RatesMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, double, ObjectCopyWith<$R, double, double>>
  get rates => MapCopyWith(
    $value.rates,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(rates: v),
  );
  @override
  $R call({
    bool? success,
    int? timestamp,
    String? base,
    String? date,
    Map<String, double>? rates,
  }) => $apply(
    FieldCopyWithData({
      if (success != null) #success: success,
      if (timestamp != null) #timestamp: timestamp,
      if (base != null) #base: base,
      if (date != null) #date: date,
      if (rates != null) #rates: rates,
    }),
  );
  @override
  Rates $make(CopyWithData data) => Rates(
    data.get(#success, or: $value.success),
    data.get(#timestamp, or: $value.timestamp),
    data.get(#base, or: $value.base),
    data.get(#date, or: $value.date),
    data.get(#rates, or: $value.rates),
  );

  @override
  RatesCopyWith<$R2, Rates, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _RatesCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

