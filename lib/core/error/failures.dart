import 'package:equatable/equatable.dart';

/// Domain-level error type. Use cases return `Either<Failure, T>` (via
/// `dartz`) so the presentation layer branches on a typed failure instead of
/// catching exceptions — no try/catch belongs in a controller.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Session expired']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
