import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/helpers/date_time_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/qc_check_entity.dart';

class QcCheckItem extends StatelessWidget {
  const QcCheckItem({required this.check, super.key});

  final QcCheckEntity check;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (check.result) {
      QcResult.pass => ('Pass', AppColors.success),
      QcResult.fail => ('Fail', AppColors.error),
      QcResult.rework => ('Rework', AppColors.warning),
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${check.bagNo}  •  ${check.designNo}', style: Theme.of(context).textTheme.titleMedium),
              ),
              StatusChip(label: label, color: color),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text('Checked by ${check.checkedBy}', style: Theme.of(context).textTheme.bodyMedium),
          Text(DateTimeHelper.formatDateTime(check.checkedAt), style: Theme.of(context).textTheme.bodySmall),
          if (check.remarks != null) ...[
            const SizedBox(height: AppDimensions.spacingXs),
            Text(check.remarks!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
