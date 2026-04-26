import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/todo_provider.dart';
import '../models/todo.dart';

class TodoSummary extends StatelessWidget {
  const TodoSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        final pendingTodos = todoProvider.pendingTodos;
        final completedTodos = todoProvider.completedTodos;
        final totalTodos = todoProvider.totalTodos;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Todo Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                if (totalTodos > 0)
                  TextButton(
                    onPressed: () {
                      // Navigate to todos screen
                    },
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ).animate()
              .fadeIn(duration: 600.ms)
              .slideX(begin: -0.3, end: 0),
            
            const SizedBox(height: 16),
            
            if (totalTodos == 0)
              _buildEmptyState(context)
            else
              Column(
                children: [
                  _buildProgressCard(context, todoProvider),
                  const SizedBox(height: 16),
                  _buildTodoList(context, pendingTodos.take(2).toList()),
                ],
              ),
          ],
        );
      },
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          const Text(
            '📝',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          Text(
            'No todos yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first task to get organized!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
  }
  
  Widget _buildProgressCard(BuildContext context, TodoProvider todoProvider) {
    final completionRate = todoProvider.completionRate;
    final completedCount = todoProvider.completedCount;
    final totalTodos = todoProvider.totalTodos;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(completionRate * 100).toInt()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          LinearProgressIndicator(
            value: completionRate,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
            minHeight: 8,
          ),
          
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completedCount of $totalTodos completed',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              if (completedCount == totalTodos && totalTodos > 0)
                const Text(
                  '🎉 All done!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms, delay: 200.ms)
      .slideY(begin: 0.3, end: 0);
  }
  
  Widget _buildTodoList(BuildContext context, List<Todo> todos) {
    return Column(
      children: todos.asMap().entries.map((entry) {
        final index = entry.key;
        final todo = entry.value;
        return _buildTodoItem(context, todo)
          .animate()
          .fadeIn(duration: 600.ms, delay: (index * 100 + 400).ms)
          .slideX(begin: 0.3, end: 0);
      }).toList(),
    );
  }
  
  Widget _buildTodoItem(BuildContext context, Todo todo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _getPriorityColor(todo.priority),
                width: 2,
              ),
            ),
            child: todo.status == TodoStatus.completed
                ? Icon(
                    Icons.check,
                    size: 12,
                    color: _getPriorityColor(todo.priority),
                  )
                : null,
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: todo.status == TodoStatus.completed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (todo.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    todo.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getPriorityColor(todo.priority).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              todo.priority.toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getPriorityColor(todo.priority),
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
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

