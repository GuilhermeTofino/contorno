class ServerException implements Exception {
  final String message;
  final String? code;

  ServerException({required this.message, this.code});

  @override
  String toString() => 'ServerException(message: $message, code: $code)';
}
