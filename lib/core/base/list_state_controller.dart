import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../error/failures.dart';

/// Template-method base for every "search + list" screen (Bag List, QC
/// Checking, Timing Report, Artist Production, Folloper Report, Design
/// Image, Skip Bag history). Subclasses implement [fetch]; this base owns
/// the loading/empty/error/search state so it isn't re-implemented six
/// times.
abstract class ListStateController<T> extends GetxController {
  final RxList<T> items = <T>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();
  final RxString query = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    final Either<Failure, List<T>> result = await fetch(query.value);
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (data) => items.assignAll(data),
    );
    isLoading.value = false;
  }

  Future<void> refreshData() => load();

  void onQueryChanged(String value) {
    query.value = value;
    load();
  }

  /// Subclasses call their use case here, applying [searchQuery] server- or
  /// client-side as appropriate for that feature's data source.
  Future<Either<Failure, List<T>>> fetch(String searchQuery);
}
