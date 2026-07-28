import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackService {
  FeedbackService(this.client);

  final SupabaseClient? client;

  bool get isReady => client != null;

  Future<void> createFeedback({
    required String name,
    required String phone,
    required String description,
  }) async {
    if (!isReady) {
      throw StateError('Supabase is not configured yet.');
    }

    await client!.from('feedback').insert({
      'name': name.trim(),
      'phone': phone.trim(),
      'description': description.trim(),
    });
  }

  Future<List<Map<String, dynamic>>> fetchFeedback({int limit = 10}) async {
    if (!isReady) {
      return [];
    }

    final response = await client!
        .from('feedback')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(response as List<dynamic>);
  }

  Future<void> updateFeedback({
    required String id,
    String? name,
    String? phone,
    String? description,
  }) async {
    if (!isReady) {
      throw StateError('Supabase is not configured yet.');
    }

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name.trim();
    if (phone != null) updates['phone'] = phone.trim();
    if (description != null) updates['description'] = description.trim();

    if (updates.isEmpty) {
      return;
    }

    await client!.from('feedback').update(updates).eq('id', id);
  }

  Future<void> deleteFeedback(String id) async {
    if (!isReady) {
      throw StateError('Supabase is not configured yet.');
    }

    await client!.from('feedback').delete().eq('id', id);
  }
}