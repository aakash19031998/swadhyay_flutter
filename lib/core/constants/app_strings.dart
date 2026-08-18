/// Centralized user-facing copy. No screen should inline a literal string.
///
/// Kept as a plain static class (rather than generated localization) for V1
/// since the product is single-locale; if/when localization is introduced,
/// this class becomes the single place to redirect into `AppLocalizations`
/// without touching call sites.
class AppStrings {
  const AppStrings._();

  // App.
  static const String appName = 'Swadhyay';

  // Common.
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String ok = 'OK';
  static const String save = 'Save';
  static const String submit = 'Submit';
  static const String somethingWentWrong = 'Something went wrong';

  /// Error/failure snackbar title app-wide — distinct from
  /// [somethingWentWrong], which is still used as [AppErrorWidget]'s
  /// default body message and other non-snackbar body text.
  static const String alertWarning = 'Alert/Warning';
  static const String success = 'Success';
  static const String noInternetConnection = 'No internet connection';
  static const String noDataFound = 'No data found';
  static const String loading = 'Loading...';
  static const String search = 'Search';

  // Login.
  static const String welcomeBack = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to continue to your workspace';
  static const String employeeNumber = 'Employee number';
  static const String employeeNumberHint = 'Enter your employee number';
  static const String employeeNumberRequired = 'Employee number is required';
  static const String employeeNumberInvalidLength = 'Employee number must be exactly 5 digits';
  static const String enterPinNumber = 'Enter pin number';
  static const String pinRequired = 'Please enter a valid 4-digit PIN';
  static const String signIn = 'SIGN IN';
  static const String invalidCredentials = 'Invalid employee number or PIN';
  static const String loginSuccessTitle = 'Success';

  // Home / Drawer.
  static const String welcome = 'Welcome,';
  static const String empCode = 'Emp Code';
  static const String inTime = 'InTime';
  static const String bagList = 'Bag List';
  static const String skipBag = 'Skip Bag';
  static const String changePassword = 'Change Password';
  static const String reports = 'Reports';
  static const String designImage = 'Design Image';
  static const String designImageSearchHint = 'Search Design Code, EMR Style...';
  static const String designMasterSearchPrompt = 'Enter a style number and tap Search to view design details.';
  static const String designMasterNotFound = 'No design found for this style number.';
  static const String designMasterEnterStyleNo = 'Please enter a style number to search';
  static const String viewGallery = 'View Gallery';
  static const String generalTab = 'General';
  static const String billOfMaterialTab = 'BOM';
  static const String labDetailsTab = 'Lab';
  static const String historyTab = 'History';
  static const String designCode = 'Design Code';
  static const String designCtg = 'Design Ctg';
  static const String designSctg = 'Design SCtg';
  static const String parts = 'Parts';
  static const String emrStyle = 'EMR Style';
  static const String designDate = 'Design Date';
  static const String totalDiaWt = 'Total Dia Wt';
  static const String defRingSize = 'Def. Size';
  static const String cadWt = 'CAD Wt';
  static const String modelWt = 'Model Wt';
  static const String cadVol = 'CAD VOL';
  static const String metalWt = 'Metal Wt';
  static const String grossWt = 'Gross Wt';
  static const String rmType = 'RmType';
  static const String rmCode = 'RmCode';
  static const String sizeName = 'SizeName';
  static const String rmWeight = 'RmWeight';
  static const String setCode = 'SetCode';
  static const String stonePosition = 'Stone Position';
  static const String labourCd = 'LabourCd';
  static const String labourNm = 'LabourNm';
  static const String qcChecking = 'Qc Checking';
  static const String timingReport = 'Timing Report';
  static const String artistProduction = 'Artist Production';
  static const String folloperReport = 'Folloper Report';
  static const String brandSpecification = 'Brand Specification';
  static const String logout = 'Logout';
  static const String logoutConfirmTitle = 'Logout';
  static const String logoutConfirmMessage =
      'Are you sure you want to log out? Your progress has been saved. We look forward to seeing you again.';

  // Bag list.
  static const String bagQty = 'Bag Qty';
  static const String designPoints = 'Design Points';
  static const String totalPoints = 'Total Points';
  static const String totalBags = 'Bags';
  static const String totalPcs = 'Pcs';
  static const String start = 'Start';
  static const String pause = 'Pause';
  static const String resume = 'Resume';
  static const String done = 'Done';
  static const String completed = 'Completed';
  static const String scanBag = 'Scan Bag';
  static const String noMediaFound = 'No images or videos found for this design';
  static const String videoUnavailable = 'This video could not be loaded';
  static const String cameraPermissionDeniedTitle = 'Camera Permission Needed';
  static const String cameraPermissionDeniedMessage =
      'Camera access was denied. Please allow camera permission from app settings to scan.';
  static const String cameraUnavailable = 'No front camera available on this device';
  static const String openSettings = 'Open Settings';
  static const String pauseReasonTitle = 'Pause Reason';
  static const String pauseReasonMessage = 'Please let us know why you are pausing this task.';
  static const String pauseReasonRequired = 'Reason is required';

  // Bag detail.
  static const String back = 'Back';
  static const String metal = 'Metal';
  static const String designGrossWt = 'Design Gross Wt';
  static const String designNetWt = 'Design Net Weight';
  static const String designInstr = 'Design Instr.';
  static const String custInstr = 'Cust Instr.';
  static const String stampInstr = 'Stamp Instr.';
  static const String rhodInstr = 'Rhod Instr.';
  static const String diamInstr = 'Diam Instr.';
  static const String sizeInstr = 'Size Instr.';
  static const String diamondDetails = 'Diamond Details';
  static const String bagRmSummary = 'BagRmSummary';
  static const String delDate = 'Del Date';
  static const String size = 'Size';
  static const String customer = 'Customer';
  static const String part = 'Part';
  static const String poNo = 'PoNo';
  static const String styleNo = 'Style No.';
  static const String designCategory = 'Design Ctg/Sub Ctg';
  static const String noDataAvailable = 'No data available';
  static const String manufacturingInstructions = 'Manufacturing Instructions';
  static const String srNo = 'Sr No';
  static const String itemCode = 'Item Code';
  static const String pcs = 'Pcs';
  static const String weight = 'Weight';
  static const String materialType = 'Material Type';
  static const String currentQty = 'Current Qty';
  static const String wt = 'WT';
  static const String bagSummary = 'Bag Summary';

  // Bag completion.
  static const String firstReceived = 'First Received';
  static const String addNewWorkEntry = 'Add Dummy Work Entry';
  static const String bagNoShort = 'Bag No.';
  static const String designNoLabel = 'Design No.';
  static const String orderNo = 'Order No';
  static const String workType = 'Work Type';
  static const String work = 'Work';
  static const String pieceStone = 'Piece/Stone';
  static const String add = 'ADD';
  static const String transactionId = 'Transaction Id';
  static const String setId = 'SET ID';
  static const String setting = 'Setting';
  static const String pieces = 'Pieces';
  static const String piecesStones = 'Pieces/Stones';
  static const String completedWork = 'Completed Work';
  static const String pendingWork = 'Pending Work';
  static const String addSettingBeforeSubmit = 'Add at least one setting before submitting';
  static const String submitConfirmTitle = 'Submit Entry';
  static const String submitConfirmMessage =
      'Are you sure you want to save this work entry? Once submitted, the bag will be marked as completed.';

  // Profile.
  static const String profile = 'Profile';
  static const String empCodeLabel = 'Emp. Code';
  static const String department = 'Department';
  static const String inTimeLabel = 'In Time';
  static const String companyCodeLabel = 'Company Code';
  static const String totalHrsTillDateLabel = 'Total Hrs Till Date';
  static const String otHrsLabel = 'OT Hrs';
  static const String presentDaysLabel = 'Present Days';

  // Artist production report.
  static const String artistProductionReportTitle = 'Artist Production Report';
  static const String fromDate = 'From Date';
  static const String toDate = 'To Date';
  static const String show = 'Show';
  static const String prediction = 'Parts Qty';
  static const String actualBagPieces = 'Actual Bag Pieces';
  static const String actualPcsStone = 'Actual Pcs/Stone';
  static const String workTypeSummary = 'Work Type Summary';
  static const String productionDetail = 'Production Detail';
  static const String selectDateRangeAndShow = 'Select a date range and tap Show to load the report';
  static const String invalidDateRange = 'From date must be before or equal to To date';
  static const String selectDate = 'Select Date';
  static const String toDateRequired = 'Please select a To date';

  // Timing report.
  static const String usedMinutes = 'Used Minutes';
  static const String unusedMinutes = 'Unused Minutes';
  static const String totalMinutes = 'Total Minutes';
  static const String noTimingData = 'No timing data for this month yet';
  static const String selectMonth = 'Select Month';
  static const String tillDateSummary = 'Till Date Summary';
  static const String dailyBreakdown = 'Daily Breakdown';

  // Skip bag.
  static const String bagNumber = 'Bag Number';
  static const String bagNumberHint = 'Enter or scan bag number';
  static const String reason = 'Reason';
  static const String skipBagAction = 'Skip Bag';
  static const String bagSkippedSuccess = 'Bag skipped successfully';
  static const String skipHistory = 'Skip History';

  // Change password.
  static const String currentPassword = 'Current Password';
  static const String newPassword = 'New Password';
  static const String confirmNewPassword = 'Confirm New Password';
  static const String passwordUpdated = 'Password updated successfully';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String changePasswordSubtitle = 'Set up a new 4-digit code to keep your account secure';
  static const String updatePassword = 'Update Password';
  static const String hide = 'Hide';
  static const String pinStrengthEmpty = 'Enter 4 digits';
  static const String pinStrengthWeak = 'Weak PIN';
  static const String pinStrengthModerate = 'Moderate';
  static const String pinStrengthStrong = 'Strong PIN';

  // Brand specification.
  static const String brandNameLabel = 'Brand Name';
  static const String filterSectionTitle = 'Filter';
  static const String specificationsSectionTitle = 'Specifications';
  static const String selectBrand = 'Select Brand';
  static const String selectBrandRequired = 'Please select a brand';
  static const String noMatchingSpecifications = 'No matching specifications found';
  static const String searchSpecificationsHint = 'Search in specifications...';
  static const String pdfUnavailable = 'No specification sheet is available for this row';
  static const String pdfOpenFailed = 'Unable to download or open this specification sheet';
  static const String productId = 'Product Id';
  static const String specHkStyle = 'SpecHKStyle';
  static const String custMaterial = 'CustMaterial';
  static const String specStyleKt = 'SpecStyleKT';
  static const String specStyleCol = 'SpecStyleCol';
  static const String specCustomer = 'Spec Customer';
  static const String shortCode = 'Short Code';
}
