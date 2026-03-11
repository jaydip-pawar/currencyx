// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'symbols.dart';

class SymbolsMapper extends ClassMapperBase<Symbols> {
  SymbolsMapper._();

  static SymbolsMapper? _instance;
  static SymbolsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SymbolsMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'Symbols';

  static bool _$success(Symbols v) => v.success;
  static const Field<Symbols, bool> _f$success = Field('success', _$success);
  static Map<String, String> _$symbols(Symbols v) => v.symbols;
  static const Field<Symbols, Map<String, String>> _f$symbols = Field(
    'symbols',
    _$symbols,
  );

  @override
  final MappableFields<Symbols> fields = const {
    #success: _f$success,
    #symbols: _f$symbols,
  };

  static Symbols _instantiate(DecodingData data) {
    return Symbols(data.dec(_f$success), data.dec(_f$symbols));
  }

  @override
  final Function instantiate = _instantiate;

  static Symbols fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Symbols>(map);
  }

  static Symbols fromJson(String json) {
    return ensureInitialized().decodeJson<Symbols>(json);
  }
}

mixin SymbolsMappable {
  String toJson() {
    return SymbolsMapper.ensureInitialized().encodeJson<Symbols>(
      this as Symbols,
    );
  }

  Map<String, dynamic> toMap() {
    return SymbolsMapper.ensureInitialized().encodeMap<Symbols>(
      this as Symbols,
    );
  }

  SymbolsCopyWith<Symbols, Symbols, Symbols> get copyWith =>
      _SymbolsCopyWithImpl<Symbols, Symbols>(
        this as Symbols,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return SymbolsMapper.ensureInitialized().stringifyValue(this as Symbols);
  }

  @override
  bool operator ==(Object other) {
    return SymbolsMapper.ensureInitialized().equalsValue(
      this as Symbols,
      other,
    );
  }

  @override
  int get hashCode {
    return SymbolsMapper.ensureInitialized().hashValue(this as Symbols);
  }
}

extension SymbolsValueCopy<$R, $Out> on ObjectCopyWith<$R, Symbols, $Out> {
  SymbolsCopyWith<$R, Symbols, $Out> get $asSymbols =>
      $base.as((v, t, t2) => _SymbolsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class SymbolsCopyWith<$R, $In extends Symbols, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>>
  get symbols;
  $R call({bool? success, Map<String, String>? symbols});
  SymbolsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _SymbolsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, Symbols, $Out>
    implements SymbolsCopyWith<$R, Symbols, $Out> {
  _SymbolsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Symbols> $mapper =
      SymbolsMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>>
  get symbols => MapCopyWith(
    $value.symbols,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(symbols: v),
  );
  @override
  $R call({bool? success, Map<String, String>? symbols}) => $apply(
    FieldCopyWithData({
      if (success != null) #success: success,
      if (symbols != null) #symbols: symbols,
    }),
  );
  @override
  Symbols $make(CopyWithData data) => Symbols(
    data.get(#success, or: $value.success),
    data.get(#symbols, or: $value.symbols),
  );

  @override
  SymbolsCopyWith<$R2, Symbols, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _SymbolsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

