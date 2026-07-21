import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';

/// Pure, stateless form validators. Kept out of widgets/controllers so
/// validation rules are unit-testable and reusable across every form field
/// in the app.
class Validators {
  const Validators._();

  static String? employeeNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.employeeNumberRequired;
    }
    return null;
  }

  static String? pin(String? value) {
    if (value == null || value.length != AppDimensions.pinLength) {
      return AppStrings.pinRequired;
    }
    return null;
  }

  static String? required(String? value, {String message = 'This field is required'}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return AppStrings.passwordsDoNotMatch;
    if (value != original) return AppStrings.passwordsDoNotMatch;
    return null;
  }
}
