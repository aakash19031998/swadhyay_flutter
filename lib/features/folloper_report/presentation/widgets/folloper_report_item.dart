import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/helpers/date_time_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/entities/folloper_report_entity.dart';

class FolloperReportItem extends StatelessWidget {
  const FolloperReportItem({required this.entry, super.key});

  final FolloperReportEntity entry;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.folloperName, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppDimensions.spacingXxs),
                Text('${entry.task}  •  with ${entry.artistName}', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: AppDimensions.spacingXxs),
                Text(DateTimeHelper.formatDate(entry.workDate), style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          StatusChip(label: '${entry.hoursWorked}h', color: AppColors.info),
        ],
      ),
    );
  }
}
