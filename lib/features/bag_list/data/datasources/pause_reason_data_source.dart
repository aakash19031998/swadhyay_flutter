import '../models/pause_reason_model.dart';

abstract class PauseReasonDataSource {
  Future<List<PauseReasonModel>> getReasons();
}
