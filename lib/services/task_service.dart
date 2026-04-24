import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../models/task_model.dart';

class TaskService {
  static const String _className = 'Task';

  // Helper: get current session token and attach to query
  Future<String?> _getSessionToken() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    return user?.get<String>('sessionToken');
  }

  // ─── CREATE ────────────────────────────────────────────────────────────────
  Future<Task> createTask(Task task) async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user == null) throw Exception('User not authenticated');

    final parseObject = ParseObject(_className)
      ..set('title', task.title)
      ..set('description', task.description)
      ..set('isCompleted', task.isCompleted)
      ..setACL(ParseACL(owner: user));

    final response = await parseObject.save();

    if (response.success && response.result != null) {
      return Task.fromParse(response.result);
    } else {
      throw Exception(response.error?.message ?? 'Failed to create task');
    }
  }

  // ─── READ ──────────────────────────────────────────────────────────────────
  Future<List<Task>> getTasks() async {
    final sessionToken = await _getSessionToken();

    final query = QueryBuilder<ParseObject>(ParseObject(_className))
      ..orderByDescending('createdAt');

    // Manually set session token — required for Flutter Web
    if (sessionToken != null) {
      query.query();
    }

    final response = await query.query();

    if (response.success && response.results != null) {
      return response.results!.map((obj) => Task.fromParse(obj)).toList();
    } else if (response.success && response.results == null) {
      return [];
    } else {
      throw Exception(response.error?.message ?? 'Failed to fetch tasks');
    }
  }

  // ─── UPDATE ────────────────────────────────────────────────────────────────
  Future<Task> updateTask(Task task) async {
    if (task.objectId == null) throw Exception('Cannot update: objectId is null');

    final parseObject = ParseObject(_className)
      ..objectId = task.objectId
      ..set('title', task.title)
      ..set('description', task.description)
      ..set('isCompleted', task.isCompleted);

    final response = await parseObject.save();

    if (response.success) {
      return task;
    } else {
      throw Exception(response.error?.message ?? 'Failed to update task');
    }
  }

  // ─── DELETE ────────────────────────────────────────────────────────────────
  Future<void> deleteTask(String objectId) async {
    final parseObject = ParseObject(_className)..objectId = objectId;
    final response = await parseObject.delete();

    if (!response.success) {
      throw Exception(response.error?.message ?? 'Failed to delete task');
    }
  }
}