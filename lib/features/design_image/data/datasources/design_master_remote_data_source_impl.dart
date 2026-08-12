import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../bag_list/data/models/bag_media_model.dart';
import '../models/design_master_model.dart';
import 'design_master_data_source.dart';

/// `DesignMaster`'s response is a flat `status`/`message`/`data` object,
/// `status` as the string `"True"`/`"False"` — same convention as
/// `BagDoneDetail`/`SubWorkType`. A `"False"` status (style not found, or
/// any other rejection) surfaces the API's own `message` as a
/// [ServerException] rather than quietly returning `null`.
class DesignMasterRemoteDataSourceImpl implements DesignMasterDataSource {
  DesignMasterRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<DesignMasterModel?> getDesignMaster({required String styleNo}) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.designMaster,
        data: {'dscd': styleNo},
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      final bool status = (body['status'] as String?)?.toLowerCase() == 'true';
      if (!status) {
        throw ServerException(message: body['message'] as String? ?? 'Unable to load design details');
      }

      final Map<String, dynamic>? data = body['data'] as Map<String, dynamic>?;
      if (data == null || data.isEmpty) return null;

      final DesignMasterModel parsed = DesignMasterModel.fromJson(data);
      final List<BagMediaModel> media = await _existingMedia(
        [for (final entry in parsed.media) BagMediaModel(url: entry.url, type: entry.type)],
      );

      return DesignMasterModel(
        designCode: parsed.designCode,
        imageUrl: parsed.imageUrl,
        designCtg: parsed.designCtg,
        designSctg: parsed.designSctg,
        parts: parsed.parts,
        emrStyle: parsed.emrStyle,
        designDate: parsed.designDate,
        totalDiaWt: parsed.totalDiaWt,
        defRingSize: parsed.defRingSize,
        cadWt: parsed.cadWt,
        modelWt: parsed.modelWt,
        cadVol: parsed.cadVol,
        metalWt: parsed.metalWt,
        grossWt: parsed.grossWt,
        bomItems: parsed.bomItems,
        labDetails: parsed.labDetails,
        history: parsed.history,
        media: media,
      );
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to load design details', statusCode: e.response?.statusCode);
    }
  }

  /// `DesignMaster`'s `media` array is every image/video suffix combination
  /// that *could* exist for this design — not every entry actually has a
  /// file behind it (the same shape `ImageAndVideoUrls` returns for Bag
  /// List's media gallery). Each candidate URL is checked before it's
  /// allowed into the gallery; anything that doesn't resolve to a real file
  /// is silently dropped rather than shown as a broken image/video in the
  /// viewer — same approach, same check, as
  /// `BagMediaGalleryRemoteDataSourceImpl`.
  Future<List<BagMediaModel>> _existingMedia(List<BagMediaModel> candidates) async {
    final List<bool> exists = await Future.wait(candidates.map((model) => _exists(model.url)));
    return [
      for (int i = 0; i < candidates.length; i++)
        if (exists[i]) candidates[i],
    ];
  }

  /// A `GET` with `ResponseType.stream`, cancelled immediately once the
  /// status code arrives — not a `HEAD` request, since `DesignImageExt`/
  /// `DesignVideo` are dynamically-generated-content endpoints that
  /// commonly only implement `GET` (`HEAD` 404s/405s even for a URL that
  /// genuinely serves on `GET`).
  Future<bool> _exists(String url) async {
    if (url.isEmpty) return false;
    final CancelToken cancelToken = CancelToken();
    try {
      final Response<ResponseBody> response = await _apiClient.dio.get<ResponseBody>(
        url,
        options: Options(responseType: ResponseType.stream),
        cancelToken: cancelToken,
      );
      final int? code = response.statusCode;
      cancelToken.cancel();
      return code != null && code >= 200 && code < 300;
    } catch (_) {
      return false;
    }
  }
}
