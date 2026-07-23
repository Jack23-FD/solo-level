import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_colors.dart';
import '../../models/plan_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/plan_provider.dart';
import '../../widgets/rpg_card.dart';

class PlanListScreen extends StatefulWidget {
  const PlanListScreen({super.key});

  @override
  State<PlanListScreen> createState() => _PlanListScreenState();
}

class _PlanListScreenState extends State<PlanListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null) {
        Provider.of<PlanProvider>(context, listen: false).fetchPlans(user.id);
      }
    });
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
                        icon: const Icon(Icons.close, color: AppColors.textMuted),
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
                      labelText: 'Plan Title',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: AppColors.textWhite),
                    decoration: const InputDecoration(
                      labelText: 'Plan Objective',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 14, color: AppColors.primaryGlow),
                          label: Text(
                            DateFormat('MMM dd, yyyy').format(startDate),
                            style: const TextStyle(color: AppColors.textWhite, fontSize: 11),
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
                          icon: const Icon(Icons.flag, size: 14, color: AppColors.primaryGlow),
                          label: Text(
                            DateFormat('MMM dd, yyyy').format(endDate),
                            style: const TextStyle(color: AppColors.textWhite, fontSize: 11),
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
                        await Provider.of<PlanProvider>(context, listen: false).updatePlan(updated);
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text(
                        'UPDATE PLAN',
                        style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
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

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text('HUNTER PLANS'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primaryGlow),
            onPressed: () => context.push('/plans/create'),
          ),
        ],
      ),
      body: planProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGlow))
          : planProvider.plans.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.note_alt_outlined, color: AppColors.textMuted, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'NO PLANS CREATED',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Formulate long-term development plans to organize quests.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          icon: const Icon(Icons.add, color: AppColors.textWhite),
                          label: const Text(
                            'CREATE NEW PLAN',
                            style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => context.push('/plans/create'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: planProvider.plans.length,
                  itemBuilder: (context, index) {
                    final plan = planProvider.plans[index];
                    final DateFormat formatter = DateFormat('MMM dd, yyyy');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      child: RpgCard(
                        systemTitle: plan.isSRank ? 'S-RANK GOAL PLAN // OPEN-ENDED' : 'CASUAL PLAN // ${plan.durationInDays} DAYS',
                        onTap: () => context.push('/plans/${plan.id}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    plan.title,
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          fontSize: 18,
                                          color: AppColors.textWhite,
                                        ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, color: AppColors.primaryGlow, size: 20),
                                      onPressed: () => _showEditPlanModal(context, plan),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppColors.systemWarningRed, size: 20),
                                      onPressed: () => planProvider.deletePlan(plan.id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (plan.description.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                plan.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, color: AppColors.primaryGlow, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  '${formatter.format(plan.startDate)} - ${formatter.format(plan.endDate)}',
                                  style: const TextStyle(
                                    color: AppColors.textLightBlue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: (index * 100).ms).moveY(begin: 10, end: 0);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: AppColors.textWhite),
        onPressed: () => context.push('/plans/create'),
      ),
    );
  }
}
