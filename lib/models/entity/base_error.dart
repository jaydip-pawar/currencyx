abstract class BaseError implements Exception {
  const BaseError({
    required this.cause,
    this.code,
    this.stackTrace,
    this.metadata,
    this.message = '',
  });

  final Object cause;
  final int? code;
  final String message;
  final StackTrace? stackTrace;
  final Map<String, Object?>? metadata;

  String getFriendlyMessage() =>
      message.isNotEmpty ? message : 'Something went wrong. Please try again.';

  @override
  String toString() =>
      '$runtimeType('
      'code: $code, '
      'message: $message, '
      'cause: $cause, '
      'stackTrace: $stackTrace, '
      'metadata: $metadata'
      ')';
}
