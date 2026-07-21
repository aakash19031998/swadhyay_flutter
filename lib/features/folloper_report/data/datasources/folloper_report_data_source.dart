import '../models/folloper_report_model.dart';

abstract class FolloperReportDataSource {
  Future<List<FolloperReportModel>> getReport({String query = ''});
}
