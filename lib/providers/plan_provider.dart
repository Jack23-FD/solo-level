import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/plan_model.dart';
import '../services/plan_service.dart';
import 'task_provider.dart';

class PlanProvider with ChangeNotifier {
  final PlanService _planService = PlanService();

  List<PlanModel> _plans = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PlanModel> get plans => _plans;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPlans(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _plans = await _planService.getPlans(userId);
    } catch (e) {
      _errorMessage = 'Failed to load plans: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PlanModel?> createPlan({
    required String userId,
    required String title,
    required String description,
    String stage = 'Casual',
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newPlan = PlanModel(
        id: const Uuid().v4(),
        userId: userId,
        title: title,
        description: description,
        stage: stage,
        startDate: startDate,
        endDate: endDate,
      );
      final created = await _planService.createPlan(newPlan);
      _plans.insert(0, created);
      return created;
    } catch (e) {
      _errorMessage = 'Failed to create plan: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePlan(String planId, {TaskProvider? taskProvider}) async {
    try {
      await _planService.deletePlan(planId);
      _plans.removeWhere((p) => p.id == planId);
      if (taskProvider != null) {
        await taskProvider.deleteTasksForPlan(planId);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete plan: $e';
      notifyListeners();
    }
  }

  Future<bool> updatePlan(PlanModel updatedPlan) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updated = await _planService.updatePlan(updatedPlan);
      final index = _plans.indexWhere((p) => p.id == updatedPlan.id);
      if (index != -1) {
        _plans[index] = updated;
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update plan: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
