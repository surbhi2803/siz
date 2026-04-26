import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../providers/todo_provider.dart';
import '../providers/app_provider.dart';
import '../models/todo.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedAssigneeId; // Will be set in initState
  String _selectedPriority = 'medium';
  DateTime? _selectedDueDate;
  
  final List<String> _priorities = ['low', 'medium', 'high'];

  @override
  void initState() {
    super.initState();
    // Set default assignee to current user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      if (mounted && _selectedAssigneeId == null) {
        setState(() {
          _selectedAssigneeId = appProvider.currentUser?.id;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Todo'),
        actions: [
          TextButton(
            onPressed: _saveTodo,
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleField(),
              const SizedBox(height: 24),
              _buildDescriptionField(),
              const SizedBox(height: 24),
              _buildAssigneeSelector(),
              const SizedBox(height: 24),
              _buildPrioritySelector(),
              const SizedBox(height: 24),
              _buildDueDateSelector(),
              const SizedBox(height: 40),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What needs to be done?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'e.g., Buy groceries',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.checklist_rounded),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        ),
      ],
    ).animate()
      .fadeIn(duration: 600.ms)
      .slideX(begin: -0.3, end: 0);
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add any additional details...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.notes_rounded),
          ),
        ),
      ],
    ).animate()
      .fadeIn(duration: 600.ms, delay: 100.ms)
      .slideX(begin: -0.3, end: 0);
  }

  Widget _buildAssigneeSelector() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final currentUser = appProvider.currentUser;
        final roommate = appProvider.roommate;

                // Build list of available assignees
                final List<Map<String, dynamic>> assignees = [];
                
                if (currentUser != null) {
                  assignees.add({
                    'id': currentUser.id,
                    'name': currentUser.name,
                    'avatar': currentUser.avatar,
                  });
                }

                if (roommate != null) {
                  assignees.add({
                    'id': roommate.id,
                    'name': roommate.name,
                    'avatar': roommate.avatar,
                  });
                }

                // Add "Both" option if roommate exists
                if (roommate != null) {
                  assignees.add({
                    'id': 'both',
                    'name': 'Both',
                    'avatar': 'both',
                  });
                }

        // If no assignees available, show message
        if (assignees.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Add a roommate to assign todos',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assign to',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: assignees.map((assignee) {
                final isSelected = _selectedAssigneeId == assignee['id'];
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Material(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedAssigneeId = assignee['id'];
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[300]!,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                                child: assignee['id'] == 'both'
                                    ? const Icon(Icons.group, size: 20, color: Color(0xFFC8FF00))
                                    : const Icon(Icons.person, size: 20),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                assignee['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey[700],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ).animate()
          .fadeIn(duration: 600.ms, delay: 200.ms)
          .slideX(begin: -0.3, end: 0);
      },
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPriority,
              isExpanded: true,
              items: _priorities.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getPriorityColor(priority),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(priority.toUpperCase()),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value!;
                });
              },
            ),
          ),
        ),
      ],
    ).animate()
      .fadeIn(duration: 600.ms, delay: 300.ms)
      .slideX(begin: -0.3, end: 0);
  }

  Widget _buildDueDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Date (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDueDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded),
                const SizedBox(width: 12),
                Text(
                  _selectedDueDate != null
                      ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                      : 'Select a due date',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: _selectedDueDate != null ? null : Colors.grey[500],
                  ),
                ),
                if (_selectedDueDate != null) ...[
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedDueDate = null;
                      });
                    },
                    icon: const Icon(Icons.clear_rounded),
                    iconSize: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    ).animate()
      .fadeIn(duration: 600.ms, delay: 400.ms)
      .slideX(begin: -0.3, end: 0);
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveTodo,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Save Todo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    ).animate()
      .fadeIn(duration: 600.ms, delay: 500.ms)
      .slideY(begin: 0.3, end: 0);
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDueDate = date;
      });
    }
  }

  void _saveTodo() {
    if (_formKey.currentState!.validate()) {
      if (_selectedAssigneeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select who to assign to')),
        );
        return;
      }

      final appProvider = Provider.of<AppProvider>(context, listen: false);
      
              // Get assignee name
              String assigneeName = 'Unknown';
              if (_selectedAssigneeId == appProvider.currentUser?.id) {
                assigneeName = appProvider.currentUser?.name ?? 'You';
              } else if (_selectedAssigneeId == appProvider.roommate?.id) {
                assigneeName = appProvider.roommate?.name ?? 'Roommate';
              } else if (_selectedAssigneeId == 'both') {
                assigneeName = 'Both';
              }

      final todo = Todo(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        assignedTo: assigneeName,
        createdBy: appProvider.currentUser?.name ?? 'You',
        createdAt: DateTime.now(),
        roomId: appProvider.currentRoomId ?? '',
        assignedToId: _selectedAssigneeId!,
        dueDate: _selectedDueDate,
        priority: _selectedPriority,
      );
      
      Provider.of<TodoProvider>(context, listen: false).addTodo(todo);
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Todo added successfully! 🎉'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
