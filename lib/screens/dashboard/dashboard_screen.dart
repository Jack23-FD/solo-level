import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../app/constants/app_constants.dart';
import '../../app/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/plan_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/level_up_dialog.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/rpg_card.dart';
import '../../widgets/task_card.dart';
import '../plans/plan_list_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user != null) {
      Provider.of<TaskProvider>(context, listen: false).fetchTasks(user.id);
      Provider.of<PlanProvider>(context, listen: false).fetchPlans(user.id);
    }
  }

  String _getHunterRank(int level) {
    if (level >= 50) return 'NATIONAL LEVEL HUNTER';
    if (level >= 30) return 'S-RANK HUNTER';
    if (level >= 20) return 'A-RANK HUNTER';
    if (level >= 10) return 'B-RANK HUNTER';
    if (level >= 5) return 'C-RANK HUNTER';
    if (level >= 2) return 'D-RANK HUNTER';
    return 'E-RANK HUNTER';
  }

  void _showAddQuestModal(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedPriority = AppConstants.priorityMedium;

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
                        'NEW DAILY QUEST',
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
                      labelText: 'Quest Title',
                      hintText: 'e.g., 100 Push-ups, Learn Supabase',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: AppColors.textWhite),
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Quest objective details...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'QUEST PRIORITY',
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
                          AppConstants.priorityLow,
                          AppConstants.priorityMedium,
                          AppConstants.priorityHigh,
                          AppConstants.prioritySRank,
                        ].map((String p) {
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
                            title: titleController.text.trim(),
                            description: descController.text.trim(),
                            priority: selectedPriority,
                          );
                        }
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text(
                        'ACCEPT QUEST',
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final user = authProvider.currentUser;

    Widget bodyContent;
    if (_selectedNavIndex == 1) {
      bodyContent = const PlanListScreen();
    } else if (_selectedNavIndex == 2) {
      bodyContent = const ProfileScreen();
    } else {
      bodyContent = user == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGlow),
            )
          : RefreshIndicator(
              onRefresh: () async => _loadData(),
              color: AppColors.primaryGlow,
              backgroundColor: AppColors.secondaryBackground,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP SECTION: PLAYER STATUS CARD
                    RpgCard(
                      systemTitle:
                          'HUNTER STATUS STATUS_ID#${user.id.substring(0, 6)}',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.accent,
                                child: Text(
                                  user.username.isNotEmpty
                                      ? user.username[0].toUpperCase()
                                      : 'H',
                                  style: const TextStyle(
                                    color: AppColors.textWhite,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.username.toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontSize: 18,
                                          color: AppColors.textWhite,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _getHunterRank(user.level),
                                    style: const TextStyle(
                                      color: AppColors.sRankGold,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGlow.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.primaryGlow,
                                  ),
                                ),
                                child: Text(
                                  'LV. ${user.level}',
                                  style: const TextStyle(
                                    color: AppColors.primaryGlow,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ProgressBar(
                            currentXp: user.experience,
                            maxXp: user.maxExperienceForCurrentLevel,
                            label: 'EXP PROGRESS',
                          ),
                        ],
                      ),
                    ).animate().fadeIn().moveY(begin: 15, end: 0),

                    const SizedBox(height: 24),

                    // QUESTS SECTION HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.assignment_turned_in_outlined,
                              color: AppColors.primaryGlow,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'TODAY\'S QUESTS',
                              style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: AppColors.primaryGlow,
                            size: 28,
                          ),
                          onPressed: () => _showAddQuestModal(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // QUESTS LIST
                    if (taskProvider.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(
                            color: AppColors.primaryGlow,
                          ),
                        ),
                      )
                    else if (taskProvider.todayQuests.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryBackground.withValues(
                            alpha: 0.4,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.task_alt,
                              color: AppColors.textMuted,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'NO ACTIVE QUESTS TODAY',
                              style: TextStyle(
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tap + above to accept new daily quests and gain XP.',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: taskProvider.todayQuests.length,
                        itemBuilder: (context, index) {
                          final task = taskProvider.todayQuests[index];
                          return TaskCard(
                            task: task,
                            onToggle: (val) async {
                              final didLevelUp = await taskProvider
                                  .toggleTaskCompletion(task, authProvider);
                              if (context.mounted && didLevelUp) {
                                LevelUpDialog.show(
                                  context,
                                  authProvider.currentUser?.level ??
                                      user.level + 1,
                                );
                              }
                            },
                            onDelete: () => taskProvider.deleteTask(task.id),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: _selectedNavIndex == 0
          ? AppBar(
              title: const Text('SOLO-LEVEL SYSTEM'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person, color: AppColors.primaryGlow),
                  onPressed: () => setState(() => _selectedNavIndex = 2),
                ),
              ],
            )
          : null,
      body: bodyContent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        backgroundColor: AppColors.secondaryBackground,
        selectedItemColor: AppColors.primaryGlow,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard, color: AppColors.primaryGlow),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map, color: AppColors.primaryGlow),
            label: 'Plans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person, color: AppColors.primaryGlow),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
