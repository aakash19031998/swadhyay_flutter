import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/bag_media_entity.dart';
import '../models/bag_media_model.dart';
import 'bag_media_gallery_data_source.dart';

/// Real-backend implementation, wired in whenever
/// [AppConfig.useMockBagMediaGallery] is `false` (the default).
///
/// `ImageAndVideoUrls` returns every image/video suffix combination that
/// *could* exist for a style — not every entry actually has a file behind
/// it. Each candidate URL is checked before it's allowed into the result;
/// anything that doesn't resolve to a real file is silently dropped rather
/// than shown as a broken image/video in the viewer.
///
/// The check is a `GET` with `ResponseType.stream`, immediately cancelled
/// once the status code arrives — not a `HEAD` request. `DesignImageExt`/
/// `DesignVideo` are dynamically-generated-content endpoints, and those
/// commonly only implement `GET` (a `HEAD` request 404s/405s even for a URL
/// that genuinely serves an image on `GET`), so `HEAD` was producing false
/// negatives — real images being filtered out. Cancelling right after the
/// headers arrive keeps the same "don't download the body" benefit `HEAD`
/// was for, especially for the video URLs, without depending on `HEAD`
/// support.
class BagMediaGalleryRemoteDataSourceImpl implements BagMediaGalleryDataSource {
  BagMediaGalleryRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<BagMediaModel>> getMedia({required String empCd, required String styleCd}) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.imageAndVideoUrls,
        data: {
          'empCd': empCd,
          'styleCd': styleCd,
          // Fixed literal per this endpoint's contract, not a real version.
          'appVersion': '1',
        },
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      final bool status = (body['status'] as String?)?.toLowerCase() == 'true';
      if (!status) {
        throw ServerException(message: body['message'] as String? ?? 'Unable to load media');
      }

      final List<dynamic> mediaJson = body['data'] as List<dynamic>? ?? const [];
      final List<BagMediaModel> candidates = [
        for (final entry in mediaJson) _fromGalleryJson(entry as Map<String, dynamic>),
      ];

      final List<bool> exists = await Future.wait(candidates.map((model) => _exists(model.url)));
      return [
        for (int i = 0; i < candidates.length; i++)
          if (exists[i]) candidates[i],
      ];
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to load media', statusCode: e.response?.statusCode);
    }
  }

  /// `ImageAndVideoUrls` uses capitalized `Url`/`Type` keys (`"Image"` /
  /// `"Video"`) — a different convention than [BagMediaModel.fromJson]'s
  /// lowercase `url`/`type` (`type` matching [BagMediaType]'s enum name
  /// exactly), so this endpoint gets its own mapping instead of reusing it.
  BagMediaModel _fromGalleryJson(Map<String, dynamic> json) {
    final String type = (json['Type'] as String? ?? '').toLowerCase();
    return BagMediaModel(
      url: json['Url'] as String? ?? '',
      type: type == 'video' ? BagMediaType.video : BagMediaType.image,
    );
  }

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
