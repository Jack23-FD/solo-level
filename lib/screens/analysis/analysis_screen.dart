import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/constants/app_constants.dart';
import '../../app/theme/app_colors.dart';
import '../../models/plan_model.dart';
import '../../models/task_model.dart';
import '../../providers/plan_provider.dart';
import '../../providers/task_provider.dart';
import '../../services/task_service.dart';
import '../../widgets/rpg_card.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  String? _selectedPlanId;
  DateTime _selectedDate = DateTime.now();
  Map<String, int> _completionCounts = {};
  bool _isLoadingStats = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final plans = Provider.of<PlanProvider>(context, listen: false)
          .plans
          .where((p) => !p.isSRank)
          .toList();
      if (plans.isNotEmpty) {
        setState(() {
          _selectedPlanId = plans.first.id;
        });
        _loadStats();
      }
    });
  }

  Future<void> _loadStats() async {
    if (_selectedPlanId == null) return;
    
    setState(() => _isLoadingStats = true);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final tasks = taskProvider.getPlanTasks(_selectedPlanId!);
    
    final taskService = TaskService();
    final Map<String, int> counts = {};
    
    for (final task in tasks) {
      counts[task.id] = await taskService.getCompletedCount(task.id, _selectedDate);
    }
    
    if (mounted) {
      setState(() {
        _completionCounts = counts;
        _isLoadingStats = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGlow,
              onPrimary: AppColors.textWhite,
              surface: AppColors.secondaryBackground,
              onSurface: AppColors.textWhite,
            ),
            dialogBackgroundColor: AppColors.primaryBackground,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    final allPlans = Provider.of<PlanProvider>(context).plans;
    final plans = allPlans.where((p) => !p.isSRank).toList();
    
    // Ensure selected plan is valid
    if (plans.isNotEmpty && !plans.any((p) => p.id == _selectedPlanId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedPlanId = plans.first.id;
          });
          _loadStats();
        }
      });
      _selectedPlanId = plans.first.id;
    }
    
    if (plans.isEmpty) {
      return const Center(
        child: Text(
          'NO PLANS AVAILABLE FOR ANALYSIS',
          style: TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      );
    }

    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = _selectedPlanId != null 
        ? taskProvider.getPlanTasks(_selectedPlanId!) 
        : <TaskModel>[];

    // Filter tasks created ON OR BEFORE the selected date
    final targetDateStr = _selectedDate.toIso8601String().split('T').first;
    final visibleTasks = tasks.where((task) {
      final createdStr = task.createdAt.toIso8601String().split('T').first;
      return createdStr.compareTo(targetDateStr) <= 0;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text('HABIT ANALYSIS'),
        backgroundColor: AppColors.primaryBackground,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Controls Section
            RpgCard(
              systemTitle: 'ANALYSIS PARAMETERS',
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: DropdownButtonFormField<String>(
                      value: _selectedPlanId,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryGlow),
                      dropdownColor: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                      style: const TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.map, color: AppColors.primaryGlow, size: 20),
                        filled: true,
                        fillColor: AppColors.secondaryBackground.withValues(alpha: 0.3),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.glassBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.primaryGlow),
                        ),
                      ),
                      items: plans.map((PlanModel plan) {
                        return DropdownMenuItem<String>(
                          value: plan.id,
                          child: Text(plan.title.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() => _selectedPlanId = newValue);
                          _loadStats();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      borderRadius: BorderRadius.circular(8),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.calendar_today, color: AppColors.primaryGlow, size: 20),
                          filled: true,
                          fillColor: AppColors.secondaryBackground.withValues(alpha: 0.3),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.glassBorder),
                          ),
                        ),
                        child: Text(
                          'TARGET DATE: $targetDateStr',
                          style: const TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats Section
            const Text(
              'COMPLETION RATE',
              style: TextStyle(
                color: AppColors.textLightBlue,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),

            if (_isLoadingStats)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primaryGlow),
                ),
              )
            else if (visibleTasks.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'NO TASKS EXISTED ON THIS DATE',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: visibleTasks.length,
                  itemBuilder: (context, index) {
                    final task = visibleTasks[index];
                    
                    // Calculate total days from task creation to selected date
                    final createdAt = DateTime(task.createdAt.year, task.createdAt.month, task.createdAt.day);
                    final targetDt = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
                    int totalDays = targetDt.difference(createdAt).inDays + 1; // Inclusive of creation day
                    if (totalDays < 1) totalDays = 1;

                    final completedCount = _completionCounts[task.id] ?? 0;
                    final missedCount = totalDays - completedCount;
                    final percentage = (completedCount / totalDays).clamp(0.0, 1.0);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: RpgCard(
                        systemTitle: task.title,
                        borderColor: percentage >= 1.0 ? AppColors.sRankGold : AppColors.primaryGlow,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStat('COMPLETED', completedCount.toString(), AppColors.lowPriorityGreen, CrossAxisAlignment.start),
                                _buildStat('MISSED', missedCount.toString(), AppColors.systemWarningRed, CrossAxisAlignment.center),
                                _buildStat('TOTAL DAYS', totalDays.toString(), AppColors.textLightBlue, CrossAxisAlignment.end),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: percentage,
                                      minHeight: 8,
                                      backgroundColor: AppColors.primaryBackground,
                                      color: percentage >= 1.0 ? AppColors.sRankGold : AppColors.primaryGlow,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${(percentage * 100).toInt()}%',
                                  style: TextStyle(
                                    color: percentage >= 1.0 ? AppColors.sRankGold : AppColors.primaryGlow,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color, CrossAxisAlignment alignment) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}
