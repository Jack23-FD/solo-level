import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../app/constants/app_constants.dart';
import '../../app/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/plan_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/edit_task_dialog.dart';
import '../../widgets/level_up_dialog.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/rpg_card.dart';
import '../../widgets/task_card.dart';
import '../plans/plan_list_screen.dart';
import '../profile/profile_screen.dart';
import '../../services/audio_service.dart';
import '../../services/task_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  int _selectedNavIndex = 0;
  Timer? _oneShotResetTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _oneShotResetTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  DateTime? _lastLoadTime;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Debounce: only reload if 3+ seconds have passed since last load
      final now = DateTime.now();
      if (_lastLoadTime == null ||
          now.difference(_lastLoadTime!) > const Duration(seconds: 3)) {
        _loadData();
      }
    }
  }

  void _scheduleNextResetTimer() async {
    _oneShotResetTimer?.cancel();
    final taskService = TaskService();
    final remaining = await taskService.getTimeUntilNextReset();

    if (remaining <= Duration.zero) {
      // Reset is due right now
      _loadData();
    } else {
      // Schedule single exact one-shot timer to fire when reset is due
      _oneShotResetTimer = Timer(remaining, () {
        _loadData();
      });
    }
  }

  Future<void> _loadData() async {
    _lastLoadTime = DateTime.now();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    if (user != null) {
      await Future.wait([
        Provider.of<TaskProvider>(context, listen: false)
            .fetchTasks(user.id, authProvider: authProvider),
        Provider.of<PlanProvider>(context, listen: false).fetchPlans(user.id),
      ]);
      if (mounted) {
        _scheduleNextResetTimer();
      }
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
                          AppConstants.priorityStar,
                          AppConstants.priorityLow,
                          AppConstants.priorityMedium,
                          AppConstants.priorityHigh,
                          AppConstants.priorityElite,
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
    final planProvider = Provider.of<PlanProvider>(context);
    final user = authProvider.currentUser;
    final displayQuests = taskProvider.getTodayQuests(planProvider.plans);

    int effectiveLevel = user?.level ?? 1;
    int effectiveXp = user?.experience ?? 0;

    if (user != null && displayQuests.isNotEmpty) {
      int completedXpSum = 0;
      for (final quest in displayQuests) {
        if (quest.isCompleted) {
          completedXpSum += quest.xpReward;
        }
      }
      int storedTotalXp = ((user.level - 1) * 1000) + user.experience;
      if (completedXpSum > storedTotalXp) {
        effectiveLevel = 1 + (completedXpSum ~/ 1000);
        effectiveXp = completedXpSum % 1000;
        // NOTE: XP sync is handled by TaskProvider.fetchTasks() after data loads.
        // Do NOT call syncXpWithCompletedTasks here — it causes infinite rebuild loops.
      }
    }

    Widget bodyContent;
    if (_selectedNavIndex == 1) {
      bodyContent = const PlanListScreen();
    } else if (_selectedNavIndex == 2) {
      bodyContent = const ProfileScreen();
    } else {
      bodyContent = user == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primaryGlow),
                    const SizedBox(height: 20),
                    const Text(
                      'INITIALIZING HUNTER DATA...',
                      style: TextStyle(
                        color: AppColors.primaryGlow,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryGlow),
                          ),
                          onPressed: () {
                            authProvider.checkAuthStatus();
                          },
                          child: const Text(
                            'RELOAD STATUS',
                            style: TextStyle(color: AppColors.primaryGlow),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                          ),
                          onPressed: () {
                            authProvider.logout();
                          },
                          child: const Text(
                            'RETURN TO LOGIN',
                            style: TextStyle(color: AppColors.textWhite),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
                                    _getHunterRank(effectiveLevel),
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
                                  'LV. $effectiveLevel',
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
                            currentXp: effectiveXp,
                            maxXp: effectiveLevel * 1000,
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
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.restore_page_outlined,
                                color: AppColors.textMuted,
                                size: 22,
                              ),
                              tooltip: 'Force Reset Daily Quests (5-Min Testing)',
                              onPressed: () async {
                                final authProvider = Provider.of<AuthProvider>(
                                  context,
                                  listen: false,
                                );
                                final user = authProvider.currentUser;
                                if (user != null) {
                                  await Provider.of<TaskProvider>(
                                    context,
                                    listen: false,
                                  ).forceResetDailyTasks(
                                    user.id,
                                    authProvider: authProvider,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'System Alert: 5-Min Daily Quests Reset Completed!',
                                        ),
                                        backgroundColor: AppColors.primaryGlow,
                                      ),
                                    );
                                  }
                                }
                              },
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
                    else if (displayQuests.isEmpty)
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
                        itemCount: displayQuests.length,
                        itemBuilder: (context, index) {
                          final task = displayQuests[index];
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

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: _selectedNavIndex == 0
          ? AppBar(
              title: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryGlow, width: 1),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const Flexible(
                    child: Text(
                      'SOLO-LEVELING ...',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person, color: AppColors.primaryGlow),
                  onPressed: () {
                    if (_selectedNavIndex != 2) {
                      AudioService.playPageChange();
                      setState(() => _selectedNavIndex = 2);
                    }
                  },
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
          if (_selectedNavIndex != index) {
            AudioService.playPageChange();
            setState(() {
              _selectedNavIndex = index;
            });
          }
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
