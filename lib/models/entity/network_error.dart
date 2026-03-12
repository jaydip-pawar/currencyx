import 'package:currencyx/models/entity/base_error.dart';

class NetworkError extends BaseError {
  const NetworkError({
    required super.cause,
    super.stackTrace,
    int? httpCode,
    super.message,
    super.metadata,
  }) : super(code: httpCode);
}
