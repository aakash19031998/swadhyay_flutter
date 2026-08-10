import '../models/sub_work_type_model.dart';

abstract class SubWorkTypeDataSource {
  Future<List<SubWorkTypeModel>> getSubWorkTypes({
    required String schr,
    required String workType,
    required String empCd,
  });
}
