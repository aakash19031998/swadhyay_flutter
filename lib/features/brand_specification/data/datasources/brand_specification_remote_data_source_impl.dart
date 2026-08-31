import 'package:dio/dio.dart';

import '../../../../core/config/app_version.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/brand_model.dart';
import '../models/brand_specification_model.dart';
import 'brand_specification_data_source.dart';

/// Real-backend implementation for both the brand dropdown (`CustomerSpec`)
/// and its specification rows (`BrandSpecData`).
///
/// `CustomerSpec`'s response is a flat `status`/`message`/`data` object,
/// `status` as a JSON **boolean** (matches `PauseReasonMaster`, not the
/// string `"True"`/`"False"` most other endpoints use). Each `data` entry
/// is just `{"specCustomer": "..."}` — there's no separate id, so the
/// customer name itself is used as [BrandModel.id] and, in turn, as
/// `BrandSpecData`'s `custShortCd` request field.
class BrandSpecificationRemoteDataSourceImpl implements BrandSpecificationDataSource {
  BrandSpecificationRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<BrandModel>> getBrands() async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.customerSpec,
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      final bool status = body['status'] as bool? ?? false;
      if (!status) {
        throw ServerException(message: body['message'] as String? ?? 'Unable to load brands');
      }

      final List<dynamic> data = body['data'] as List<dynamic>? ?? const [];
      return [
        for (final entry in data)
          if (((entry as Map<String, dynamic>)['specCustomer'] as String?)?.isNotEmpty ?? false)
            BrandModel(id: entry['specCustomer'] as String, name: entry['specCustomer'] as String),
      ];
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to load brands', statusCode: e.response?.statusCode);
    }
  }

  /// `BrandSpecData`'s `status` is inconsistent across outcomes — a JSON
  /// boolean on success, but the string `"False"` on failure. That failure
  /// shape doubles as the app's force-update payload (`minAppVersion`/
  /// `updateUrl`), which `ApiClient`/`ForceUpdateGuard` already intercepts
  /// centrally *when a newer version is actually available*; this branch
  /// only runs for a same-shaped failure that isn't a real update (e.g. an
  /// actual business-logic rejection), so it still needs the dual-shape
  /// parse used everywhere else in this app for that reason.
  @override
  Future<List<BrandSpecificationModel>> getSpecifications({required String brandId}) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.brandSpecData,
        data: {
          'custShortCd': brandId,
          'appVersion': AppVersion.versionName,
        },
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      final dynamic rawStatus = body['status'];
      final bool status = rawStatus is bool ? rawStatus : (rawStatus as String? ?? '').toLowerCase() == 'true';
      if (!status) {
        throw ServerException(message: body['message'] as String? ?? 'Unable to load specifications');
      }

      final List<dynamic> data = body['data'] as List<dynamic>? ?? const [];
      return [
        for (final entry in data) BrandSpecificationModel.fromJson(entry as Map<String, dynamic>),
      ];
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to load specifications', statusCode: e.response?.statusCode);
    }
  }

  /// `BrandSpecPdf` resolves a row's actual PDF download link — the row
  /// itself carries no `pdfUrl` from `BrandSpecData`, so this is called
  /// fresh on tap rather than cached on the entity.
  @override
  Future<String> getSpecificationPdfUrl({
    required String productId,
    required String styleNo,
    required String custShortCd,
  }) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.brandSpecPdf,
        data: {
          'custShortCd': custShortCd,
          'productId': productId,
          'styleNo': styleNo,
          'appVersion': AppVersion.versionName,
        },
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      final dynamic rawStatus = body['status'];
      final bool status = rawStatus is bool ? rawStatus : (rawStatus as String? ?? '').toLowerCase() == 'true';
      if (!status) {
        throw ServerException(message: body['message'] as String? ?? 'Unable to load specification PDF');
      }

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>? ?? const {};
      final String? fileUrl = data['fileUrl'] as String?;
      if (fileUrl == null || fileUrl.isEmpty) {
        throw const ServerException(message: 'Unable to load specification PDF');
      }
      return fileUrl;
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to load specification PDF', statusCode: e.response?.statusCode);
    }
  }
}
