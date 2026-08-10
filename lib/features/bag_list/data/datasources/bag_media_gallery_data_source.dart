import '../models/bag_media_model.dart';

abstract class BagMediaGalleryDataSource {
  Future<List<BagMediaModel>> getMedia({required String empCd, required String styleCd});
}
