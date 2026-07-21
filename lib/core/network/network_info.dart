import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstraction over connectivity so repositories can short-circuit to
/// [NetworkFailure] without depending on `connectivity_plus` directly.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    final List<ConnectivityResult> result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}
