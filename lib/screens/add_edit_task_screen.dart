import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final TaskService _taskService = TaskService();
  bool _isLoading = false;
  bool _isCompleted = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description;
      _isCompleted = widget.task!.isCompleted;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      if (_isEditing) {
        await _taskService.updateTask(Task(
          objectId: widget.task!.objectId,
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          isCompleted: _isCompleted,
          createdAt: widget.task!.createdAt,
        ));
      } else {
        await _taskService.createTask(Task(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          isCompleted: false,
        ));
      }
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditing ? 'Task updated!' : 'Task created!'),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Task' : 'New Task',
          style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 20, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title field ──
              _FieldLabel(
                  label: 'Task Title',
                  icon: Icons.title_rounded,
                  required: true),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 15),
                decoration: _inputDeco(
                    hint: 'e.g. Submit assignment, Study for exam...'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Title is required';
                  if (v.trim().length < 3)
                    return 'Title must be at least 3 characters';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ── Description field ──
              _FieldLabel(
                  label: 'Description',
                  icon: Icons.notes_rounded,
                  required: false),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 15),
                decoration: _inputDeco(
                    hint: 'Add more details about this task (optional)...'),
              ),
              const SizedBox(height: 20),

              // ── Status toggle (edit only) ──
              if (_isEditing) ...[
                _FieldLabel(
                    label: 'Status',
                    icon: Icons.flag_outlined,
                    required: false),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: SwitchListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      _isCompleted ? 'Completed' : 'In Progress',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _isCompleted
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFF57F17)),
                    ),
                    subtitle: Text(
                      _isCompleted
                          ? 'This task has been finished'
                          : 'This task is still pending',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                    value: _isCompleted,
                    activeColor: const Color(0xFF1565C0),
                    onChanged: (val) => setState(() => _isCompleted = val),
                    secondary: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _isCompleted
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _isCompleted
                            ? Icons.check_circle_outline_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: _isCompleted
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFF57F17),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ── Buttons ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white))
                      : Text(
                          _isEditing ? 'Save Changes' : 'Create Task',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Cancel',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE53935)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFFE53935), width: 1.5),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool required;
  const _FieldLabel(
      {required this.label, required this.icon, required this.required});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF1565C0)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E))),
        if (required)
          const Text(' *',
              style: TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
      ],
    );
  }
}