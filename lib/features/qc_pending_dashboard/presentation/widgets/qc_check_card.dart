import 'package:flutter/material.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/qc_check_entity.dart';

/// Small grid card for one QC check — adapted from a reference "compact ID
/// card" design (avatar ring, an emp code pill, two metric tiles). The
/// avatar shows [QcCheckEntity.imageUrl] (`DeptQCPendingEmpList`'s
/// `EmpImg`) when present, falling back to a plain person icon on a
/// missing URL or a failed load — same gradient ring either way.
class QcCheckCard extends StatelessWidget {
  const QcCheckCard({required this.check, required this.onTap, super.key});

  final QcCheckEntity check;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: AppDimensions.qcCardMaxWidth),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingSm,
              vertical: AppDimensions.spacingMd,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: AppDimensions.qcCardAvatarSize,
                  height: AppDimensions.qcCardAvatarSize,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.surface),
                    padding: const EdgeInsets.all(1.5),
                    child: ClipOval(
                      child: (check.imageUrl == null || check.imageUrl!.isEmpty)
                          ? const CircleAvatar(
                              backgroundColor: AppColors.primaryContainer,
                              child: Icon(Icons.person, color: AppColors.primary),
                            )
                          : Image.network(
                              check.imageUrl!,
                              width: AppDimensions.qcCardAvatarSize,
                              height: AppDimensions.qcCardAvatarSize,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                                backgroundColor: AppColors.primaryContainer,
                                child: Icon(Icons.person, color: AppColors.primary),
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingXs, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                  ),
                  child: Text(
                    '#${check.empCode}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                if (check.empName.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingXxs),
                  Text(
                    check.empName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontSize: (Theme.of(context).textTheme.bodySmall?.fontSize ?? 12) + 3,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
                const SizedBox(height: AppDimensions.spacingSm),
                Row(
                  children: [
                    Expanded(
                      child: _StatChip(
                        icon: Icons.shopping_bag_rounded,
                        iconColor: AppColors.info,
                        iconBackground: AppColors.infoContainer,
                        label: 'BAGS',
                        value: '${check.totalBags}',
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingXs),
                    Expanded(
                      child: _StatChip(
                        icon: Icons.diamond_rounded,
                        iconColor: AppColors.warning,
                        iconBackground: AppColors.warningContainer,
                        label: 'PIECES',
                        value: '${check.totalPieces}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A small "KPI chip": a colored icon badge above a bold number and a
/// muted label — a more modern stat treatment than plain text-only tiles.
class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXxs),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle),
            child: Icon(icon, size: 12, color: iconColor),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
          ),
        ],
      ),
    );
  }
}
