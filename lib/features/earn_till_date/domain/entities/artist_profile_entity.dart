/// The employee-identity half of the Incentive Details screen — everything
/// shown in the left-hand profile/personal-dossier cards.
class ArtistProfileEntity {
  const ArtistProfileEntity({
    required this.name,
    required this.empCode,
    required this.staffType,
    required this.department,
    required this.companyLabel,
    required this.experienceLabel,
    required this.recruitedDate,
    required this.contractJoinedDate,
    required this.ageDobLabel,
    required this.genderStatus,
    required this.religionCaste,
    required this.mobile,
    required this.email,
    required this.localAddress,
    required this.nativeAddress,
    required this.isVerified,
    this.photoUrl,
    this.altMobile,
  });

  final String name;
  final String empCode;

  /// e.g. "ARTIST STAFF".
  final String staffType;

  /// e.g. "Setting :- PSTA".
  final String department;

  /// e.g. "H.K DESIGNS (INDIA) - HKD".
  final String companyLabel;
  final String? photoUrl;

  /// e.g. "16 Yrs 2 Mos".
  final String experienceLabel;
  final String recruitedDate;
  final String contractJoinedDate;

  /// e.g. "45 Yrs 5 Mos (08/04/1981)".
  final String ageDobLabel;

  /// e.g. "Male · Married".
  final String genderStatus;

  /// e.g. "Hindu · OPEN".
  final String religionCaste;
  final String mobile;
  final String? altMobile;
  final String email;
  final String localAddress;
  final String nativeAddress;

  /// Drives the "Verified" badge on the Personal Dossier card.
  final bool isVerified;
}
