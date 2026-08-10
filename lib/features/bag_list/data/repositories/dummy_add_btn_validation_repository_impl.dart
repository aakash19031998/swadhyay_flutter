import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/dummy_add_btn_validation_repository.dart';
import '../datasources/dummy_add_btn_validation_data_source.dart';

class DummyAddBtnValidationRepositoryImpl implements DummyAddBtnValidationRepository {
  DummyAddBtnValidationRepositoryImpl(this._dataSource);

  final DummyAddBtnValidationDataSource _dataSource;

  @override
  Future<Either<Failure, ({bool success, String message})>> validate({
    required String empCd,
    required int setId,
    required int inputQty,
    required int emrPcs,
    required int emrStone,
  }) async {
    try {
      final result = await _dataSource.validate(
        empCd: empCd,
        setId: setId,
        inputQty: inputQty,
        emrPcs: emrPcs,
        emrStone: emrStone,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
