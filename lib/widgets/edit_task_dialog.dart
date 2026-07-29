import 'package:flutter/material.dart';
import '../app/constants/app_constants.dart';
import '../app/theme/app_colors.dart';
import '../models/task_model.dart';
import 'glowing_button.dart';

class EditTaskDialog extends StatefulWidget {
  final TaskModel task;
  final Function(TaskModel updatedTask) onSave;

  const EditTaskDialog({
    super.key,
    required this.task,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required TaskModel task,
    required Function(TaskModel updatedTask) onSave,
  }) {
    return showDialog(
      context: context,
      builder: (context) => EditTaskDialog(task: task, onSave: onSave),
    );
  }

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedPriority;
  late DateTime _dueDate;

  final List<String> _priorities = [
    AppConstants.priorityCasual,
    AppConstants.priorityLow,
    AppConstants.priorityMedium,
    AppConstants.priorityHigh,
    AppConstants.priorityElite,
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _selectedPriority = _priorities.contains(widget.task.priority)
        ? widget.task.priority
        : AppConstants.priorityMedium;
    _dueDate = widget.task.dueDate ?? DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.task.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priority: _selectedPriority,
      dueDate: _dueDate,
    );

    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryGlow, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGlow.withValues(alpha: 0.3),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'EDIT QUEST',
                      style: TextStyle(
                        color: AppColors.primaryGlow,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(color: AppColors.glassBorder),
                const SizedBox(height: 12),

                // Title
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: AppColors.textWhite),
                  decoration: const InputDecoration(
                    labelText: 'Quest Title',
                    prefixIcon: Icon(Icons.shield_outlined),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  style: const TextStyle(color: AppColors.textWhite),
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),
                const SizedBox(height: 12),

                // Priority Selection
                const Text(
                  'PRIORITY / RANK',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _priorities.map((p) {
                    final isSelected = p == _selectedPriority;
                    return ChoiceChip(
                      label: Text(p),
                      selected: isSelected,
                      selectedColor: AppColors.primaryGlow.withValues(alpha: 0.3),
                      backgroundColor: AppColors.primaryBackground,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.primaryGlow
                            : AppColors.textMuted,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryGlow
                            : AppColors.glassBorder,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedPriority = p);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Save Button
                GlowingButton(
                  text: 'SAVE CHANGES',
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
