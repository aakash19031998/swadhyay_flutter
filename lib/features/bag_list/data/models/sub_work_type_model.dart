import '../../domain/entities/sub_work_type_entity.dart';

class SubWorkTypeModel extends SubWorkTypeEntity {
  const SubWorkTypeModel({required super.workId, required super.work});

  /// Parses one `SubWorkType` `data` array item.
  factory SubWorkTypeModel.fromApiJson(Map<String, dynamic> json) {
    return SubWorkTypeModel(
      workId: (json['WorkId'] as num?)?.toInt() ?? 0,
      work: json['Work'] as String? ?? '',
    );
  }
}
