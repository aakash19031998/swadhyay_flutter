import 'artist_profile_entity.dart';
import 'incentive_field_entity.dart';

/// The full Earn Till Date screen's data: the employee's profile, the
/// four headline stat cards, and the full ticked-field table beneath them.
class EarnTillDateEntity {
  const EarnTillDateEntity({
    required this.profile,
    required this.fixedSalary,
    required this.fixedSalarySubtitle,
    required this.commitmentSalary,
    required this.commitmentSalarySubtitle,
    required this.hrSalary,
    required this.hrSalarySubtitle,
    required this.earnTillDate,
    required this.earnTillDateSubtitle,
    required this.fields,
    required this.lastUpdatedLabel,
  });

  final ArtistProfileEntity profile;

  final double fixedSalary;
  final String fixedSalarySubtitle;

  final double commitmentSalary;
  final String commitmentSalarySubtitle;

  final double hrSalary;
  final String hrSalarySubtitle;

  final double earnTillDate;
  final String earnTillDateSubtitle;

  final List<IncentiveFieldEntity> fields;

  /// e.g. "Current Cycle".
  final String lastUpdatedLabel;
}
