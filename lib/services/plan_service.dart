import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../config/supabase_config.dart';
import '../models/plan_model.dart';

class PlanService {
  static const String _localPlansKey = 'solo_level_local_plans';

  // Fetch plans
  Future<List<PlanModel>> getPlans(String userId) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      final data = await client.from('plans').select().eq('user_id', userId).order('created_at', ascending: false);
      return (data as List).map((item) => PlanModel.fromJson(item)).toList();
    } else {
      final prefs = await SharedPreferences.getInstance();
      final plansJson = prefs.getStringList(_localPlansKey) ?? [];
      if (plansJson.isEmpty) {
        // Provide sample initial plan for demo experience
        final defaultPlan = PlanModel(
          id: const Uuid().v4(),
          userId: userId,
          title: 'Become S-Rank Developer',
          description: 'Master Flutter UI, Supabase Backend, and RPG State Architecture.',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
        );
        await prefs.setStringList(_localPlansKey, [jsonEncode(defaultPlan.toJson())]);
        return [defaultPlan];
      }
      return plansJson.map((e) => PlanModel.fromJson(jsonDecode(e))).toList();
    }
  }

  // Create plan
  Future<PlanModel> createPlan(PlanModel plan) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final data = await client.from('plans').insert(plan.toJson()).select().single();
        return PlanModel.fromJson(data);
      } catch (e) {
        if (e.toString().contains('stage')) {
          final payload = plan.toJson()..remove('stage');
          final data = await client.from('plans').insert(payload).select().single();
          return PlanModel.fromJson(data);
        }
        rethrow;
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      final plansJson = prefs.getStringList(_localPlansKey) ?? [];
      plansJson.insert(0, jsonEncode(plan.toJson()));
      await prefs.setStringList(_localPlansKey, plansJson);
      return plan;
    }
  }

  // Delete plan
  Future<void> deletePlan(String planId) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      await client.from('plans').delete().eq('id', planId);
    } else {
      final prefs = await SharedPreferences.getInstance();
      final plansJson = prefs.getStringList(_localPlansKey) ?? [];
      plansJson.removeWhere((item) {
        final map = jsonDecode(item);
        return map['id'] == planId;
      });
      await prefs.setStringList(_localPlansKey, plansJson);
    }
  }

  // Update plan
  Future<PlanModel> updatePlan(PlanModel plan) async {
    final client = SupabaseConfig.client;
    if (client != null) {
      final data = await client
          .from('plans')
          .update({
            'title': plan.title,
            'description': plan.description,
            'start_date': plan.startDate.toIso8601String().split('T').first,
            'end_date': plan.endDate.toIso8601String().split('T').first,
          })
          .eq('id', plan.id)
          .select()
          .single();
      return PlanModel.fromJson(data);
    } else {
      final prefs = await SharedPreferences.getInstance();
      final plansJson = prefs.getStringList(_localPlansKey) ?? [];
      final index = plansJson.indexWhere((item) {
        final map = jsonDecode(item);
        return map['id'] == plan.id;
      });
      if (index != -1) {
        plansJson[index] = jsonEncode(plan.toJson());
        await prefs.setStringList(_localPlansKey, plansJson);
      }
      return plan;
    }
  }
}
