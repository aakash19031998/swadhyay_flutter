import '../../domain/entities/bag_completion_master_entity.dart';
import '../../domain/entities/comp_pred_entity.dart';
import '../../domain/entities/pending_setting_entity.dart';
import 'comp_pred_model.dart';
import 'pending_setting_model.dart';

class BagCompletionMasterModel extends BagCompletionMasterEntity {
  const BagCompletionMasterModel({
    required super.bagSchr,
    required super.bagNo,
    required super.bagOdNo,
    required super.bagPcs,
    required super.bagDesignCd,
    required super.bagDesignCtg,
    required super.bagDia,
    required super.addDummyWork,
    required super.pndPred,
    required super.compPred,
    required super.workType,
  });

  /// Parses `BagDoneDetail`'s `data` object. `AddDummyWork` arrives as the
  /// string `"true"`/`"false"`, not a JSON boolean. `WorkType` arrives as an
  /// array of `{MstProWrkSubCtg: ...}` objects, flattened here to the plain
  /// label list the Work Type dropdown displays. `PndPred` items are
  /// `{TrnId, SetID, Pred, Pcs}`; `CompPred` items are their own, unrelated
  /// shape — `{Prediction, Stone}`.
  factory BagCompletionMasterModel.fromApiJson(Map<String, dynamic> json) {
    final List<dynamic> pndPredJson = json['PndPred'] as List<dynamic>? ?? const [];
    final List<dynamic> compPredJson = json['CompPred'] as List<dynamic>? ?? const [];
    final List<dynamic> workTypeJson = json['WorkType'] as List<dynamic>? ?? const [];

    final List<PendingSettingEntity> pndPred = [
      for (final item in pndPredJson) PendingSettingModel.fromApiJson(item as Map<String, dynamic>),
    ];
    final List<CompPredEntity> compPred = [
      for (final item in compPredJson) CompPredModel.fromApiJson(item as Map<String, dynamic>),
    ];
    final List<String> workType = [
      for (final item in workTypeJson) (item as Map<String, dynamic>)['MstProWrkSubCtg'] as String? ?? '',
    ];

    return BagCompletionMasterModel(
      bagSchr: json['BagSchr'] as String? ?? '',
      bagNo: (json['Bagno'] as num?)?.toInt() ?? 0,
      bagOdNo: json['BagOdNo'] as String? ?? '',
      bagPcs: (json['BagPcs'] as num?)?.toDouble() ?? 0,
      bagDesignCd: json['BagDesignCd'] as String? ?? '',
      bagDesignCtg: json['BagDesignCtg'] as String? ?? '',
      bagDia: (json['BagDia'] as num?)?.toInt() ?? 0,
      addDummyWork: (json['AddDummyWork'] as String? ?? '').toLowerCase() == 'true',
      pndPred: pndPred,
      compPred: compPred,
      workType: workType,
    );
  }
}
