import 'package:dartz/dartz.dart';

import 'exceptions.dart';
import 'failures.dart';

/// Runs [action], mapping [ServerException]/[NetworkException] to their
/// matching [Failure] — the `try { return Right(await ...); } on
/// ServerException ... on NetworkException ...` block copy-pasted at the
/// top of nearly every repository impl's methods. Repositories that also
/// need to map a third exception type (e.g. `AuthRepositoryImpl.login`'s
/// `UnauthorizedException`) keep their own try/catch instead of using this.
Future<Either<Failure, T>> guard<T>(Future<T> Function() action) async {
  try {
    return Right(await action());
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  } on NetworkException catch (e) {
    return Left(NetworkFailure(e.message));
  }
}
