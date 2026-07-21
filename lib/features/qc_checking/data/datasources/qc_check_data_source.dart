import '../models/qc_check_model.dart';

abstract class QcCheckDataSource {
  Future<List<QcCheckModel>> getChecks({String query = ''});
}
