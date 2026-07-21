import '../../domain/entities/bag_media_entity.dart';

class BagMediaModel extends BagMediaEntity {
  const BagMediaModel({required super.url, required super.type});

  factory BagMediaModel.fromJson(Map<String, dynamic> json) {
    return BagMediaModel(
      url: json['url'] as String,
      type: BagMediaType.values.byName(json['type'] as String),
    );
  }
}
