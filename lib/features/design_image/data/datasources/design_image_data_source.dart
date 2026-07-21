import '../models/design_image_model.dart';

abstract class DesignImageDataSource {
  Future<List<DesignImageModel>> getImages({String query = ''});
}
