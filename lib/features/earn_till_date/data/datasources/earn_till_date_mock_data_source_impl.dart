import '../../../../core/config/app_config.dart';
import '../../domain/entities/artist_profile_entity.dart';
import '../../domain/entities/earn_till_date_entity.dart';
import '../../domain/entities/incentive_field_entity.dart';
import 'earn_till_date_data_source.dart';

/// Placeholder data only — no backend endpoint exists for this screen yet
/// (see [EarnTillDateDataSource]'s own doc comment). [empName]/[empCd]
/// (the signed-in employee) are used verbatim; every other field is
/// illustrative, modeled on a real physical incentive paper record.
class EarnTillDateMockDataSourceImpl implements EarnTillDateDataSource {
  @override
  Future<EarnTillDateEntity> getEarnTillDate({
    required String empCd,
    required String empName,
  }) async {
    await Future.delayed(AppConfig.mockLatency);

    final ArtistProfileEntity profile = ArtistProfileEntity(
      name: empName,
      empCode: empCd,
      staffType: 'Artist Staff',
      department: 'Setting :- PSTA',
      companyLabel: 'H.K Designs (India) - HKD',
      experienceLabel: '16 Yrs 2 Mos',
      recruitedDate: '09/07/2010',
      contractJoinedDate: '01/04/2022',
      ageDobLabel: '45 Yrs 5 Mos (08/04/1981)',
      genderStatus: 'Male · Married',
      religionCaste: 'Hindu · OPEN',
      mobile: '+91 9619299127',
      altMobile: '9702678571',
      email: '${empName.toLowerCase().replaceAll(' ', '.')}@hkdesigns.com',
      localAddress:
          'Flat no 401, Bldg no 37, Palghar, Palghar(W), Mumbai, Maharashtra',
      nativeAddress: 'Vyavist Nagar, Matera, Balia, Balia, Matera',
      isVerified: true,
    );

    const List<IncentiveFieldEntity> fields = [
      IncentiveFieldEntity(
        srNo: 1,
        metricName: 'Salary',
        recordedValue: '21,450',
      ),
      IncentiveFieldEntity(
        srNo: 2,
        metricName: 'Fix Salary',
        recordedValue: '21,450',
      ),
      IncentiveFieldEntity(
        srNo: 3,
        metricName: 'Extra Day-Salary',
        recordedValue: '0.0-0',
      ),
      IncentiveFieldEntity(
        srNo: 4,
        metricName: 'Night Scheme',
        recordedValue: '0',
      ),
      IncentiveFieldEntity(
        srNo: 5,
        metricName: 'Diamond Broken',
        recordedValue: '-772',
        highlight: IncentiveFieldHighlight.warning,
      ),
      IncentiveFieldEntity(
        srNo: 6,
        metricName: 'Training Amount',
        recordedValue: '0',
      ),
      IncentiveFieldEntity(
        srNo: 7,
        metricName: 'Previous Arrears',
        recordedValue: '0',
      ),
      IncentiveFieldEntity(
        srNo: 8,
        metricName: 'InDis Penalty',
        recordedValue: '0',
      ),
      IncentiveFieldEntity(
        srNo: 9,
        metricName: 'QC Repair',
        recordedValue: '0',
      ),
      IncentiveFieldEntity(
        srNo: 10,
        metricName: 'Without Inform Leave',
        recordedValue: '0',
      ),
      IncentiveFieldEntity(
        srNo: 11,
        metricName: 'Attikalah',
        recordedValue: '0',
      ),
      IncentiveFieldEntity(
        srNo: 12,
        metricName: 'Broken Diamond Qty',
        recordedValue: '2',
        highlight: IncentiveFieldHighlight.caution,
        unit: 'pcs',
      ),
      IncentiveFieldEntity(
        srNo: 13,
        metricName: 'No Of Days',
        recordedValue: '12.0',
      ),
      IncentiveFieldEntity(
        srNo: 14,
        metricName: 'Ext Hrs',
        recordedValue: '11',
      ),
      IncentiveFieldEntity(
        srNo: 15,
        metricName: 'Total PCs',
        recordedValue: '310',
      ),
      IncentiveFieldEntity(
        srNo: 16,
        metricName: 'No Of Stone/PCs',
        recordedValue: '6,501',
      ),
      IncentiveFieldEntity(
        srNo: 17,
        metricName: 'Total Point',
        recordedValue: '7,986',
        highlight: IncentiveFieldHighlight.info,
        isBold: true,
      ),
    ];

    return EarnTillDateEntity(
      profile: profile,
      fixedSalary: 21450,
      fixedSalarySubtitle: 'Base monthly pay',
      commitmentSalary: 19800,
      commitmentSalarySubtitle: 'Guaranteed component',
      hrSalary: 145,
      hrSalarySubtitle: 'Per hour rate',
      earnTillDate: 14525,
      earnTillDateSubtitle: '12.0 Days worked',
      fields: fields,
      lastUpdatedLabel: 'Current Cycle',
    );
  }
}
