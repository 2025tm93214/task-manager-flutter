import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import 'login_screen.dart';
import 'add_edit_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  bool _isLoading = true;
  String _filter = 'All'; // All | Pending | Done

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await _taskService.getTasks();
      if (mounted) setState(() => _tasks = tasks);
    } catch (e) {
      if (mounted) _showSnack('Failed to load tasks', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Task> get _filtered {
    if (_filter == 'Pending') return _tasks.where((t) => !t.isCompleted).toList();
    if (_filter == 'Done') return _tasks.where((t) => t.isCompleted).toList();
    return _tasks;
  }

  Future<void> _deleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Task',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Delete "${task.title}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel',
                  style: TextStyle(color: Colors.grey.shade600))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935), elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _taskService.deleteTask(task.objectId!);
      if (mounted) {
        setState(() => _tasks.removeWhere((t) => t.objectId == task.objectId));
        _showSnack('Task deleted');
      }
    } catch (e) {
      if (mounted) _showSnack('Failed to delete task', isError: true);
    }
  }

  Future<void> _toggleComplete(Task task) async {
    final updated = Task(
      objectId: task.objectId,
      title: task.title,
      description: task.description,
      isCompleted: !task.isCompleted,
      createdAt: task.createdAt,
    );
    try {
      await _taskService.updateTask(updated);
      if (mounted) {
        setState(() {
          final i = _tasks.indexWhere((t) => t.objectId == task.objectId);
          if (i != -1) _tasks[i] = updated;
        });
      }
    } catch (e) {
      if (mounted) _showSnack('Failed to update', isError: true);
    }
  }

  Future<void> _logout() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    await user?.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor:
          isError ? const Color(0xFFE53935) : const Color(0xFF2E7D32),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final total = _tasks.length;
    final done = _tasks.where((t) => t.isCompleted).length;
    final pending = total - done;
    final progress = total == 0 ? 0.0 : done / total;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        title: const Text('My Tasks',
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 20, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loadTasks,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: const Text('Sign Out',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text('Cancel',
                            style: TextStyle(color: Colors.grey.shade600))),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Sign Out',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
              if (confirm == true) _logout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Stats header ──
          Container(
            color: const Color(0xFF1565C0),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              children: [
                Row(
                  children: [
                    _StatCard(label: 'Total', value: total, color: Colors.white),
                    const SizedBox(width: 12),
                    _StatCard(
                        label: 'Pending',
                        value: pending,
                        color: const Color(0xFFFFCC02)),
                    const SizedBox(width: 12),
                    _StatCard(
                        label: 'Completed',
                        value: done,
                        color: const Color(0xFF69F0AE)),
                  ],
                ),
                const SizedBox(height: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Progress',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12)),
                        Text('$done / $total done',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF69F0AE)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Filter chips ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: ['All', 'Pending', 'Done'].map((f) {
                final selected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF1565C0)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(f,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : Colors.grey.shade600)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Task list ──
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF1565C0)))
                : _filtered.isEmpty
                    ? _EmptyState(filter: _filter)
                    : RefreshIndicator(
                        color: const Color(0xFF1565C0),
                        onRefresh: _loadTasks,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                          itemCount: _filtered.length,
                          itemBuilder: (ctx, i) => _TaskTile(
                            task: _filtered[i],
                            onToggle: () => _toggleComplete(_filtered[i]),
                            onEdit: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        AddEditTaskScreen(task: _filtered[i])),
                              );
                              if (result == true) _loadTasks();
                            },
                            onDelete: () => _deleteTask(_filtered[i]),
                          ),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddEditTaskScreen()));
          if (result == true) _loadTasks();
        },
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Task',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ── Stat card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text('$value',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.75),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── Task tile ────────────────────────────────────────────────────────────────
class _TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskTile({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? const Color(0xFF1565C0)
                        : Colors.transparent,
                    border: Border.all(
                      color: task.isCompleted
                          ? const Color(0xFF1565C0)
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check_rounded,
                          size: 14, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: task.isCompleted
                            ? Colors.grey.shade400
                            : const Color(0xFF1A1A2E),
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: Colors.grey.shade400,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        task.description,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: Colors.grey.shade400),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        task.isCompleted ? 'Completed' : 'In Progress',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: task.isCompleted
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFF57F17),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Actions
              Column(
                children: [
                  _ActionBtn(
                      icon: Icons.edit_outlined,
                      color: const Color(0xFF1565C0),
                      onTap: onEdit),
                  const SizedBox(height: 6),
                  _ActionBtn(
                      icon: Icons.delete_outline_rounded,
                      color: const Color(0xFFE53935),
                      onTap: onDelete),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            filter == 'All' ? 'No tasks yet' : 'No $filter tasks',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500),
          ),
          const SizedBox(height: 6),
          Text(
            filter == 'All' ? 'Tap + to create your first task' : '',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}