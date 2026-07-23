import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../app/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/plan_provider.dart';
import '../../widgets/glassmorphism_container.dart';
import '../../widgets/glowing_button.dart';

class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({super.key});

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedStage = 'Casual';

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  int get _calculatedDuration {
    return _endDate.difference(_startDate).inDays + 1;
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGlow,
              surface: AppColors.secondaryBackground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 7));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _handleCreatePlan() async {
    if (!_formKey.currentState!.validate()) return;

    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null) return;

    final planProvider = Provider.of<PlanProvider>(context, listen: false);
    final isSRank = _selectedStage == 'S-Rank';
    final created = await planProvider.createPlan(
      userId: user.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      stage: _selectedStage,
      startDate: isSRank ? DateTime(2000, 1, 1) : _startDate,
      endDate: isSRank ? DateTime(2099, 12, 31) : _endDate,
    );

    if (!mounted) return;
    if (created != null) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(planProvider.errorMessage ?? 'Plan creation failed'),
          backgroundColor: AppColors.systemWarningRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final planProvider = Provider.of<PlanProvider>(context);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text('CREATE PLAN'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: GlassmorphismContainer(
          borderRadius: 18,
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PLAN SPECIFICATIONS',
                  style: TextStyle(
                    color: AppColors.primaryGlow,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const Divider(color: AppColors.glassBorder, height: 24),

                // Title Input
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: AppColors.textWhite),
                  decoration: const InputDecoration(
                    labelText: 'Plan Name',
                    hintText: 'e.g., Become Flutter Developer, Reach 60kg',
                    prefixIcon: Icon(Icons.bookmark_border),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a plan name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Stage Selection (Casual vs S-Rank)
                Text(
                  'STAGE',
                  style: TextStyle(
                    color: AppColors.textLightBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ChoiceChip(
                      label: Text(
                        'CASUAL',
                        style: TextStyle(
                          color: _selectedStage == 'Casual' ? AppColors.primaryBackground : AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      selected: _selectedStage == 'Casual',
                      selectedColor: AppColors.primaryGlow,
                      backgroundColor: AppColors.primaryBackground,
                      onSelected: (val) {
                        if (val) setState(() => _selectedStage = 'Casual');
                      },
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: Text(
                        'S-RANK',
                        style: TextStyle(
                          color: _selectedStage == 'S-Rank' ? AppColors.primaryBackground : AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      selected: _selectedStage == 'S-Rank',
                      selectedColor: AppColors.sRankGold,
                      backgroundColor: AppColors.primaryBackground,
                      onSelected: (val) {
                        if (val) setState(() => _selectedStage = 'S-Rank');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description Input
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: const TextStyle(color: AppColors.textWhite),
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Outline main objectives and goals...',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),
                const SizedBox(height: 20),

                // Date Selectors
                if (_selectedStage == 'Casual') ...[
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDate(context, true),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('START DATE', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                                const SizedBox(height: 4),
                                Text(
                                  formatter.format(_startDate),
                                  style: const TextStyle(color: AppColors.primaryGlow, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDate(context, false),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('END DATE', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                                const SizedBox(height: 4),
                                Text(
                                  formatter.format(_endDate),
                                  style: const TextStyle(color: AppColors.primaryGlow, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Duration Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedStage == 'S-Rank'
                          ? AppColors.sRankGold.withValues(alpha: 0.6)
                          : AppColors.primaryGlow.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedStage == 'S-Rank' ? 'PLAN TYPE' : 'TOTAL DURATION',
                        style: const TextStyle(color: AppColors.textLightBlue, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text(
                        _selectedStage == 'S-Rank' ? 'S-RANK GOAL (NO TIME DURATION)' : '$_calculatedDuration DAYS',
                        style: TextStyle(
                          color: _selectedStage == 'S-Rank' ? AppColors.sRankGold : AppColors.primaryGlow,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                GlowingButton(
                  text: 'CREATE PLAN',
                  isLoading: planProvider.isLoading,
                  onPressed: _handleCreatePlan,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
