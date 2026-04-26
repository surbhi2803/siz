import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';
import '../widgets/todo_item.dart';
import 'add_todo_screen.dart';

class TodosScreen extends StatefulWidget {
  const TodosScreen({super.key});

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All')),
              const PopupMenuItem(value: 'High', child: Text('High Priority')),
              const PopupMenuItem(value: 'Medium', child: Text('Medium Priority')),
              const PopupMenuItem(value: 'Low', child: Text('Low Priority')),
            ],
            child: const Icon(Icons.filter_list_rounded),
          ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          List<Todo> todos = _getFilteredTodos(todoProvider);
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildTodosList(todos),
              _buildTodosList(todoProvider.pendingTodos),
              _buildTodosList(todoProvider.completedTodos),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTodoScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Todo'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  List<Todo> _getFilteredTodos(TodoProvider todoProvider) {
    List<Todo> todos = todoProvider.todos;
    
    if (_selectedFilter != 'All') {
      todos = todos.where((todo) => todo.priority == _selectedFilter.toLowerCase()).toList();
    }
    
    return todos;
  }

  Widget _buildTodosList(List<Todo> todos) {
    if (todos.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return TodoItem(todo: todo)
          .animate()
          .fadeIn(duration: 600.ms, delay: (index * 100).ms)
          .slideX(begin: 0.3, end: 0);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '📝',
            style: TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 24),
          Text(
            'No todos yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first task to get organized!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddTodoScreen()),
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add First Todo'),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
  }
}

