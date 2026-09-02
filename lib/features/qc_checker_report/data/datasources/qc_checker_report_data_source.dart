import '../../domain/entities/qc_checker_report_entity.dart';

abstract class QcCheckerReportDataSource {
  Future<QcCheckerReportEntity> getReport({
    required DateTime fromDate,
    required DateTime toDate,
    required String empCd,
  });
}
