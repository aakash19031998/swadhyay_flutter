import 'package:dio/dio.dart';

import 'exceptions.dart';

/// Runs [action], translating a [DioException] into a [ServerException] —
/// the `try { ... } on DioException catch (e) { throw ServerException(...);
/// }` wrapper copy-pasted around nearly every remote data source method.
/// Only the Dio-to-[ServerException] translation is shared here; each
/// endpoint's own response-status parsing (which varies — some throw
/// [ServerException] themselves on `status: false`, others return a
/// `success: false` result normally) stays untouched inside [action].
///
/// [buildMessage] computes the [ServerException.message] from the
/// [DioException] — most call sites ignore it and return a fixed string;
/// a few (e.g. login) pull the message out of the error response body
/// instead.
Future<T> wrapDioErrors<T>(Future<T> Function() action, String Function(DioException e) buildMessage) async {
  try {
    return await action();
  } on DioException catch (e) {
    throw ServerException(message: buildMessage(e), statusCode: e.response?.statusCode);
  }
}
