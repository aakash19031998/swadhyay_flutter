import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_routes.dart';
import '../../domain/entities/bag_entity.dart';

class SettingEntry {
  const SettingEntry({required this.setting, required this.pieces});

  final String setting;
  final int pieces;
}

/// Drives the "Done" completion form opened from both the bag list and the
/// bag detail screen: record which settings/pieces were worked on, then
/// submit to close out the bag. The Work Type / Work option lists and the
/// pending Pnd/Pred data table are static placeholders — both come from the
/// backend once that contract exists.
class BagCompletionController extends GetxController {
  BagCompletionController(this.bag);

  final BagEntity bag;

  static const List<String> workTypeOptions = ['Setting', 'Polish', 'Casting', 'Filing'];
  static const List<String> workOptions = ['C1', 'LC1', 'R1', 'P1'];

  final Rxn<String> workType = Rxn<String>();
  final Rxn<String> work = Rxn<String>();
  final RxString piece = ''.obs;

  final RxList<SettingEntry> recordedSettings = <SettingEntry>[
    const SettingEntry(setting: 'C1', pieces: 1),
    const SettingEntry(setting: 'LC1', pieces: 7),
  ].obs;

  bool get canAdd =>
      workType.value != null && work.value != null && (int.tryParse(piece.value.trim()) ?? 0) > 0;

  void onWorkTypeChanged(String? value) => workType.value = value;

  void onWorkChanged(String? value) => work.value = value;

  void onPieceChanged(String value) => piece.value = value;

  void addEntry() {
    if (!canAdd) return;

    final String selectedWork = work.value!;
    final int addedPieces = int.parse(piece.value.trim());

    // Same setting recorded again adds to its running piece count instead
    // of creating a duplicate row — only a setting not yet recorded gets a
    // new entry.
    final int existingIndex = recordedSettings.indexWhere((entry) => entry.setting == selectedWork);
    if (existingIndex == -1) {
      recordedSettings.add(SettingEntry(setting: selectedWork, pieces: addedPieces));
    } else {
      final SettingEntry existing = recordedSettings[existingIndex];
      recordedSettings[existingIndex] = SettingEntry(
        setting: existing.setting,
        pieces: existing.pieces + addedPieces,
      );
    }

    work.value = null;
    piece.value = '';
  }

  void removeEntry(int index) => recordedSettings.removeAt(index);

  void submit() {
    if (recordedSettings.isEmpty) {
      Get.snackbar(AppStrings.somethingWentWrong, AppStrings.addSettingBeforeSubmit);
      return;
    }
    Get.snackbar(AppStrings.bagList, AppStrings.bagCompletedSuccess);
    Get.until((route) => route.settings.name == AppRoutes.bagList);
  }

  void cancel() => Get.back();
}
