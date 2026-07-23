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
  static const String enterPinNumber = 'Enter pin number';
  static const String pinRequired = 'Please enter a valid 4-digit PIN';
  static const String signIn = 'SIGN IN';
  static const String invalidCredentials = 'Invalid employee number or PIN';

  // Home / Drawer.
  static const String welcome = 'Welcome,';
  static const String empCode = 'Emp Code';
  static const String inTime = 'InTime';
  static const String bagList = 'Bag List';
  static const String skipBag = 'Skip Bag';
  static const String changePassword = 'Change Password';
  static const String reports = 'Reports';
  static const String designImage = 'Design Image';
  static const String qcChecking = 'Qc Checking';
  static const String timingReport = 'Timing Report';
  static const String artistProduction = 'Artist Production';
  static const String folloperReport = 'Folloper Report';
  static const String logout = 'Logout';
  static const String logoutConfirmTitle = 'Logout';
  static const String logoutConfirmMessage =
      'Are you sure you want to log out? Your progress has been saved. We look forward to seeing you again.';

  // Bag list.
  static const String bagQty = 'Bag Qty';
  static const String designPoints = 'Design Points';
  static const String totalPoints = 'Total Points';
  static const String totalBags = 'Bags';
  static const String totalImages = 'Images';
  static const String start = 'Start';
  static const String pause = 'Pause';
  static const String resume = 'Resume';
  static const String done = 'Done';
  static const String completed = 'Completed';

  // Bag detail.
  static const String backPause = 'Back / Pause';
  static const String metal = 'Metal';
  static const String designGrossWt = 'Design Gross Wt';
  static const String extra = 'Extra';
  static const String diamondWax = 'Diamond (Wax)';
  static const String extra2 = 'Extra2';
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
  static const String noDataAvailable = 'No data available';
  static const String manufacturingInstructions = 'Manufacturing Instructions';
  static const String srNo = 'Sr No';
  static const String shape = 'Shape';
  static const String sizeMm = 'Size (MM)';
  static const String pcs = 'Pcs';
  static const String weightCt = 'Wt (ct)';
  static const String color = 'Color';
  static const String clarity = 'Clarity';
  static const String materialCode = 'Material Code';
  static const String rmDescription = 'Description';
  static const String allocatedQty = 'Allocated Qty';
  static const String issuedQty = 'Issued Qty';
  static const String status = 'Status';
  static const String bagSummary = 'Bag Summary';

  // Bag completion.
  static const String firstReceived = 'First Received';
  static const String addNewWorkEntry = 'Add New Work Entry';
  static const String bagNoShort = 'Bag No.';
  static const String designNoLabel = 'Design No.';
  static const String orderNo = 'OrderNo';
  static const String workType = 'Work Type';
  static const String work = 'Work';
  static const String pieceStone = 'Piece/Stone';
  static const String add = 'ADD';
  static const String setting = 'Setting';
  static const String pieces = 'Pieces';
  static const String select = 'Select';
  static const String pleaseSelectPndPredData = 'Please select Pnd/Pred data';
  static const String recordedSettings = 'Recorded Settings';
  static const String pendingSettings = 'Pending Settings';
  static const String addSettingBeforeSubmit = 'Add at least one setting before submitting';
  static const String bagCompletedSuccess = 'Bag completed successfully';

  // Profile.
  static const String profile = 'Profile';
  static const String empCodeLabel = 'Emp. Code';
  static const String department = 'Department';
  static const String inTimeLabel = 'In Time';
  static const String workEfficiency = 'Work Efficiency';
  static const String performanceMetric = 'Performance Metric';
  static const String performanceExcellent = 'Excellent';
  static const String performanceGood = 'Good';
  static const String performanceNeedsImprovement = 'Needs Improvement';

  // Artist production report.
  static const String artistProductionReportTitle = 'Artist Production Report';
  static const String fromDate = 'From Date';
  static const String toDate = 'To Date';
  static const String show = 'Show';
  static const String prediction = 'Prediction';
  static const String totalPrediction = 'Total Prediction';
  static const String actualPcsStone = 'Actual Pcs/Stone';
  static const String workTypeSummary = 'Work Type Summary';
  static const String productionDetail = 'Production Detail';
  static const String selectDateRangeAndShow = 'Select a date range and tap Show to load the report';
  static const String invalidDateRange = 'From date must be before or equal to To date';

  // Timing report.
  static const String usedMinutes = 'Used Minutes';
  static const String unusedMinutes = 'Unused';
  static const String noTimingData = 'No timing data for this month yet';

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
}
