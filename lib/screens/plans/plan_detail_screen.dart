import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../app/constants/app_constants.dart';
import '../../app/theme/app_colors.dart';
import '../../models/plan_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/plan_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/edit_task_dialog.dart';
import '../../widgets/level_up_dialog.dart';
import '../../widgets/rpg_card.dart';
import '../../widgets/task_card.dart';

class PlanDetailScreen extends StatefulWidget {
  final String planId;

  const PlanDetailScreen({super.key, required this.planId});

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).currentUser;
      if (user != null) {
        Provider.of<TaskProvider>(
          context,
          listen: false,
        ).fetchTasks(user.id, planId: widget.planId);
      }
    });
  }

  void _showAddTaskToPlanModal(BuildContext context, PlanModel plan) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedPriority = plan.isSRank ? AppConstants.prioritySRank : AppConstants.priorityLow;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ADD PLAN QUEST',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primaryGlow,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.glassBorder),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: AppColors.textWhite),
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      hintText: 'e.g., Build Auth System UI',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: AppColors.textWhite),
                    decoration: const InputDecoration(
                      labelText: 'Task Objective',
                      hintText: 'Detailed requirements...',
                    ),
                  ),
                  if (!plan.isSRank) ...[
                    const SizedBox(height: 16),
                    Text(
                      'PRIORITY & XP',
                      style: TextStyle(
                        color: AppColors.textLightBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          [
                            AppConstants.priorityStar,
                            AppConstants.priorityLow,
                            AppConstants.priorityMedium,
                            AppConstants.priorityHigh,
                            AppConstants.priorityElite,
                          ].map((p) {
                            final isSelected = selectedPriority == p;
                            return ChoiceChip(
                              label: Text(
                                p.toUpperCase(),
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.primaryBackground
                                      : AppColors.textWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.primaryGlow,
                              backgroundColor: AppColors.primaryBackground,
                              onSelected: (val) {
                                if (val) {
                                  setModalState(() {
                                    selectedPriority = p;
                                  });
                                }
                              },
                            );
                          }).toList(),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) return;
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        final user = authProvider.currentUser;
                        if (user != null) {
                          await Provider.of<TaskProvider>(
                            context,
                            listen: false,
                          ).addTask(
                            userId: user.id,
                            planId: plan.id,
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                            priority: selectedPriority,
                          );
                        }
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text(
                        'ADD TO PLAN',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditPlanModal(BuildContext context, PlanModel plan) {
    final titleController = TextEditingController(text: plan.title);
    final descController = TextEditingController(text: plan.description);
    DateTime startDate = plan.startDate;
    DateTime endDate = plan.endDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'EDIT PLAN',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primaryGlow,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.glassBorder),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: AppColors.textWhite),
                    decoration: const InputDecoration(labelText: 'Plan Title'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: AppColors.textWhite),
                    decoration: const InputDecoration(
                      labelText: 'Plan Objective',
                    ),
                  ),
                  if (!plan.isSRank) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: AppColors.primaryGlow,
                            ),
                            label: Text(
                              DateFormat('MMM dd, yyyy').format(startDate),
                              style: const TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 11,
                              ),
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: startDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2035),
                              );
                              if (picked != null) {
                                setModalState(() => startDate = picked);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(
                              Icons.flag,
                              size: 14,
                              color: AppColors.primaryGlow,
                            ),
                            label: Text(
                              DateFormat('MMM dd, yyyy').format(endDate),
                              style: const TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 11,
                              ),
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: endDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2035),
                              );
                              if (picked != null) {
                                setModalState(() => endDate = picked);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) return;
                        final updated = plan.copyWith(
                          title: titleController.text.trim(),
                          description: descController.text.trim(),
                          startDate: startDate,
                          endDate: endDate,
                        );
                        await Provider.of<PlanProvider>(
                          context,
                          listen: false,
                        ).updatePlan(updated);
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text(
                        'UPDATE PLAN',
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final planProvider = Provider.of<PlanProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final plan = planProvider.plans.firstWhere(
      (p) => p.id == widget.planId,
      orElse: () => PlanModel(
        id: widget.planId,
        userId: '',
        title: 'Plan Details',
        description: '',
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      ),
    );

    final DateFormat formatter = DateFormat('MMM dd, yyyy');
    final planTasks = taskProvider.getPlanTasks(plan.id);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text(plan.title.toUpperCase()),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primaryGlow),
            onPressed: () => _showEditPlanModal(context, plan),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Info Header RpgCard
            RpgCard(
              systemTitle: plan.isSRank
                  ? 'S-RANK PLAN // PERMANENT GOAL'
                  : 'PLAN METRICS // ID#${plan.id.length >= 6 ? plan.id.substring(0, 6) : plan.id}',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (plan.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      plan.description,
                      style: const TextStyle(color: AppColors.textLightBlue),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (plan.isSRank)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TYPE',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                              ),
                            ),
                            const Text(
                              'S-RANK GOAL',
                              style: TextStyle(
                                color: AppColors.sRankGold,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.sRankGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.sRankGold),
                          ),
                          child: const Text(
                            'PERMANENT',
                            style: TextStyle(
                              color: AppColors.sRankGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TIMELINE',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              '${formatter.format(plan.startDate)} - ${formatter.format(plan.endDate)}',
                              style: const TextStyle(
                                color: AppColors.primaryGlow,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGlow.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryGlow),
                          ),
                          child: Text(
                            '${plan.durationInDays} DAYS',
                            style: const TextStyle(
                              color: AppColors.primaryGlow,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tasks List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'PLAN TASKS',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_task,
                    color: AppColors.primaryGlow,
                  ),
                  onPressed: () => _showAddTaskToPlanModal(context, plan),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (planTasks.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.add_task,
                      color: AppColors.textMuted,
                      size: 36,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'NO TASKS ASSIGNED TO THIS PLAN',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                      ),
                      onPressed: () => _showAddTaskToPlanModal(context, plan),
                      child: const Text(
                        'ADD TASK',
                        style: TextStyle(color: AppColors.textWhite),
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: planTasks.length,
                itemBuilder: (context, index) {
                  final task = planTasks[index];
                  return TaskCard(
                    task: task,
                    onToggle: (val) async {
                      final didLevelUp = await taskProvider
                          .toggleTaskCompletion(task, authProvider);
                      if (context.mounted && didLevelUp) {
                        LevelUpDialog.show(
                          context,
                          authProvider.currentUser?.level ?? 2,
                        );
                      }
                    },
                    onEdit: () {
                      EditTaskDialog.show(
                        context,
                        task: task,
                        onSave: (updatedTask) {
                          taskProvider.updateTask(updatedTask);
                        },
                      );
                    },
                    onDelete: () async {
                      final confirmed = await ConfirmDeleteDialog.show(
                        context,
                        title: 'Delete Quest',
                        message: 'Are you sure you want to delete "${task.title}"?',
                      );
                      if (confirmed) {
                        taskProvider.deleteTask(task.id);
                      }
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
