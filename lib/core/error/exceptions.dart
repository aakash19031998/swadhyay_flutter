/// Exceptions thrown by data sources (remote or local). Repositories catch
/// these and translate them into [Failure]s for the domain/presentation
/// layers — exceptions must never cross the repository boundary.
class ServerException implements Exception {
  const ServerException({this.message = 'Server error', this.statusCode});

  final String message;
  final int? statusCode;
}

class CacheException implements Exception {
  const CacheException({this.message = 'Cache error'});

  final String message;
}

class NetworkException implements Exception {
  const NetworkException({this.message = 'No internet connection'});

  final String message;
}

class UnauthorizedException implements Exception {
  const UnauthorizedException({this.message = 'Session expired'});

  final String message;
}

class ValidationException implements Exception {
  const ValidationException({required this.message});

  final String message;
}
