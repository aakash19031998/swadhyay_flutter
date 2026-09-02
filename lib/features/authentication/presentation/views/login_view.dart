import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_pin_field.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/gradient_blob_scaffold.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBlobScaffold(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double cardWidth = constraints.maxWidth < 480 ? constraints.maxWidth : 440;

              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: cardWidth),
                child: _LoginCard(controller: controller),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LogoBadge(),
        const SizedBox(height: AppDimensions.spacingLg),
        Container(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacingXl,
            AppDimensions.spacingXxl,
            AppDimensions.spacingXl,
            AppDimensions.spacingXl,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: _LoginForm(controller: controller),
        ),
      ],
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.avatarLg,
      height: AppDimensions.avatarLg,
      padding: const EdgeInsets.all(AppDimensions.spacingSm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SvgPicture.asset(AppAssets.logoHk, fit: BoxFit.contain),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.welcomeBack,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            AppStrings.loginSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingXl),
          AppTextField(
            label: AppStrings.employeeNumber,
            hint: AppStrings.employeeNumberHint,
            controller: controller.employeeNumberController,
            prefixIcon: Icons.badge_outlined,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(AppDimensions.empCodeLength),
            ],
            validator: (value) {
              final String trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) return AppStrings.employeeNumberRequired;
              if (trimmed.length != AppDimensions.empCodeLength) {
                return AppStrings.employeeNumberInvalidLength;
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          Text(
            AppStrings.enterPinNumber,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Obx(
            () => AppPinField(
              controller: controller.pinFieldController,
              onChanged: controller.onPinChanged,
              onCompleted: (_) => controller.login(),
              errorText: controller.pinErrorText.value,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXl),
          Obx(
            () => AppButton(
              label: AppStrings.signIn,
              isLoading: controller.isLoading.value,
              onPressed: controller.login,
            ),
          ),
        ],
      ),
    );
  }
}
