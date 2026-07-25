import 'package:flutter/material.dart';
import '../app/constants/app_constants.dart';
import '../app/theme/app_colors.dart';
import '../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final Function(bool?) onToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    this.onDelete,
    this.onEdit,
  });

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case AppConstants.prioritySRank:
        return AppColors.sRankGold;
      case AppConstants.priorityElite:
        return Colors.purpleAccent;
      case AppConstants.priorityHigh:
        return AppColors.highPriorityRed;
      case AppConstants.priorityLow:
        return AppColors.lowPriorityGreen;
      case AppConstants.priorityCasual:
        return Colors.cyan;
      case AppConstants.priorityStar:
        return Colors.blueGrey;
      case AppConstants.priorityMedium:
      default:
        return AppColors.mediumPriorityOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(task.priority);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: task.isCompleted
            ? AppColors.secondaryBackground.withValues(alpha: 0.5)
            : AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.isCompleted
              ? AppColors.glassBorder.withValues(alpha: 0.3)
              : AppColors.primaryGlow.withValues(alpha: 0.7),
          width: task.isCompleted ? 1 : 1.5,
        ),
        boxShadow: task.isCompleted
            ? []
            : [
                BoxShadow(
                  color: AppColors.primaryGlow.withValues(alpha: 0.15),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Custom Checkbox
              GestureDetector(
                onTap: () => onToggle(!task.isCompleted),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? AppColors.primaryGlow
                        : Colors.transparent,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: task.isCompleted
                          ? AppColors.primaryGlow
                          : AppColors.textLightBlue,
                      width: 2,
                    ),
                    boxShadow: task.isCompleted
                        ? [
                            const BoxShadow(
                              color: AppColors.primaryGlow,
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: task.isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 20,
                          color: AppColors.primaryBackground,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 14),

              // Task Text Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Priority Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: priorityColor, width: 1),
                          ),
                          child: Text(
                            task.priority.toUpperCase(),
                            style: TextStyle(
                              color: priorityColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // XP Reward Tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGlow.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '+${task.xpReward} XP',
                            style: const TextStyle(
                              color: AppColors.primaryGlow,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: task.isCompleted
                            ? AppColors.textMuted
                            : AppColors.textWhite,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Action Options
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                color: AppColors.secondaryBackground,
                onSelected: (value) {
                  if (value == 'edit' && onEdit != null) onEdit!();
                  if (value == 'delete' && onDelete != null) onDelete!();
                },
                itemBuilder: (context) => [
                  if (onEdit != null)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: AppColors.primaryGlow,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Edit Quest',
                            style: TextStyle(color: AppColors.textWhite),
                          ),
                        ],
                      ),
                    ),
                  if (onDelete != null)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: AppColors.systemWarningRed,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delete Quest',
                            style: TextStyle(color: AppColors.systemWarningRed),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
