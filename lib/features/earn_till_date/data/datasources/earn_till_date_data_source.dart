import '../../domain/entities/earn_till_date_entity.dart';

/// No real backend exists for this screen yet, so — same as
/// `DashboardDataSource`/`AttendanceDataSource` — this returns a domain
/// entity directly instead of a `data/models` shape parsed from JSON. Add a
/// `data/models` layer (and a real `ApiEndpoints` entry) once an actual
/// earn-till-date endpoint exists.
abstract class EarnTillDateDataSource {
  Future<EarnTillDateEntity> getEarnTillDate({
    required String empCd,
    required String empName,
  });
}
