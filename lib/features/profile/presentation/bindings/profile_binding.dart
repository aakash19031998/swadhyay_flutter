import 'package:get/get.dart';

import '../../../attendance/data/datasources/attendance_data_source.dart';
import '../../../attendance/data/datasources/attendance_mock_data_source_impl.dart';
import '../../../attendance/data/repositories/attendance_repository_impl.dart';
import '../../../attendance/domain/repositories/attendance_repository.dart';
import '../../../attendance/domain/usecases/get_monthly_attendance_usecase.dart';
import '../../../authentication/domain/entities/employee_entity.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    final EmployeeEntity employee = Get.arguments as EmployeeEntity;
    Get.put(ProfileController(employee));

    // Only ever opened from this screen's own "In Time" tile (see
    // MonthlyAttendanceDialog), so its dependencies live here rather than
    // needing their own route/binding — no real backend yet (see
    // AttendanceDataSource's own doc comment).
    //
    // `fenix: true` — the dialog is a separate overlay route pushed on top
    // of this one, opened via a plain `Get.find` rather than its own
    // `Bindings`; without `fenix`, GetX's smart-management can dispose
    // these lazy singletons (e.g. once it decides this route is no longer
    // "current" while the dialog sits on top of it) before the dialog's
    // `initState` reads them, throwing a "not found" exception that leaves
    // the dialog's spinner stuck forever — this is what actually caused
    // the reported "stuck loading" bug, not the mock's own 600ms latency.
    // `fenix` makes GetX transparently recreate them on the next `Get.find`
    // instead of throwing, which is safe here since they're cheap and
    // stateless.
    Get.lazyPut<AttendanceDataSource>(
      () => AttendanceMockDataSourceImpl(),
      fenix: true,
    );
    Get.lazyPut<AttendanceRepository>(
      () => AttendanceRepositoryImpl(Get.find<AttendanceDataSource>()),
      fenix: true,
    );
    Get.lazyPut<GetMonthlyAttendanceUseCase>(
      () => GetMonthlyAttendanceUseCase(Get.find<AttendanceRepository>()),
      fenix: true,
    );
  }
}
