import 'package:equatable/equatable.dart';

class DesignImageEntity extends Equatable {
  const DesignImageEntity({
    required this.id,
    required this.designNo,
    required this.imageUrl,
    required this.category,
    required this.uploadedAt,
  });

  final String id;
  final String designNo;
  final String imageUrl;
  final String category;
  final DateTime uploadedAt;

  @override
  List<Object?> get props => [id, designNo, imageUrl, category, uploadedAt];
}
