import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/helpers/date_time_helper.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/skipped_bag_entity.dart';

class SkippedBagItem extends StatelessWidget {
  const SkippedBagItem({required this.bag, super.key});

  final SkippedBagEntity bag;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bag.bagNo, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppDimensions.spacingXxs),
                Text(bag.reason, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Text(DateTimeHelper.formatDateTime(bag.skippedAt), style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
