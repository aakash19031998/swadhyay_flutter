import '../../domain/entities/design_image_entity.dart';

class DesignImageModel extends DesignImageEntity {
  const DesignImageModel({
    required super.id,
    required super.designNo,
    required super.imageUrl,
    required super.category,
    required super.uploadedAt,
  });

  factory DesignImageModel.fromJson(Map<String, dynamic> json) {
    return DesignImageModel(
      id: json['id'] as String,
      designNo: json['designNo'] as String,
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
    );
  }
}
