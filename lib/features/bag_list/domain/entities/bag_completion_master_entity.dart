import 'package:equatable/equatable.dart';

import 'comp_pred_entity.dart';
import 'pending_setting_entity.dart';

/// `BagDoneDetail`'s response — drives the Bag Completion ("Done") screen's
/// Add Dummy Work Entry section (gated on [addDummyWork]) and its Pending
/// Setting table ([pndPred]).
class BagCompletionMasterEntity extends Equatable {
  const BagCompletionMasterEntity({
    required this.bagSchr,
    required this.bagNo,
    required this.bagOdNo,
    required this.bagPcs,
    required this.bagDesignCd,
    required this.bagDesignCtg,
    required this.bagDia,
    required this.addDummyWork,
    required this.pndPred,
    required this.compPred,
    required this.workType,
  });

  /// `BagSchr` — passed as `schr` when fetching `SubWorkType` options for
  /// whichever Work Type the user selects.
  final String bagSchr;
  final int bagNo;
  final String bagOdNo;
  final double bagPcs;
  final String bagDesignCd;
  final String bagDesignCtg;
  final int bagDia;
  final bool addDummyWork;
  final List<PendingSettingEntity> pndPred;
  final List<CompPredEntity> compPred;
  final List<String> workType;

  @override
  List<Object?> get props => [
        bagSchr,
        bagNo,
        bagOdNo,
        bagPcs,
        bagDesignCd,
        bagDesignCtg,
        bagDia,
        addDummyWork,
        pndPred,
        compPred,
        workType,
      ];
}
