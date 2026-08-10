import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import 'dummy_add_btn_validation_data_source.dart';

/// Real-backend implementation — the only [DummyAddBtnValidationDataSource]
/// wired in by `BagCompletionBinding`. Called on every "ADD" tap on the
/// Bag Completion screen, before a row is added to the Pending Work table.
///
/// `DummyAddBtnValidation`'s response is just `status`/`message` (no
/// `data`), `status` as the string `"True"`/`"False"` — same convention as
/// `BagDoneDetail`/`SubWorkType`. Unlike those, a `"False"` status here is
/// a normal, valid outcome to surface via `message` (e.g. "Please Enter
/// Proper Input Qty."), not a thrown [ServerException] — the caller still
/// needs it to decide whether to add the row.
class DummyAddBtnValidationRemoteDataSourceImpl implements DummyAddBtnValidationDataSource {
  DummyAddBtnValidationRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<({bool success, String message})> validate({
    required String empCd,
    required int setId,
    required int inputQty,
    required int emrPcs,
    required int emrStone,
  }) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.dummyAddBtnValidation,
        data: {
          'empCd': empCd,
          'setId': setId,
          'inputQty': inputQty,
          'emrPcs': emrPcs,
          'emrStone': emrStone,
          // Fixed literal per this endpoint's contract, not a real version.
          'appVersion': '1',
        },
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      final bool success = (body['status'] as String?)?.toLowerCase() == 'true';
      final String message = body['message'] as String? ?? '';

      return (success: success, message: message);
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to validate work entry', statusCode: e.response?.statusCode);
    }
  }
}
