import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo.dart';
import '../services/firebase_service.dart';
import '../services/widget_service.dart';

class TodoProvider extends ChangeNotifier {
  List<Todo> _todos = [];
  String? _roomId;
  StreamSubscription<List<Todo>>? _todosSubscription;
  
  List<Todo> get todos => _todos;

  List<Todo> get pendingTodos => _todos.where((todo) => todo.status == TodoStatus.pending).toList();
  List<Todo> get inProgressTodos => _todos.where((todo) => todo.status == TodoStatus.inProgress).toList();
  List<Todo> get completedTodos => _todos.where((todo) => todo.status == TodoStatus.completed).toList();

  int get totalTodos => _todos.length;
  int get completedCount => completedTodos.length;
  double get completionRate => totalTodos > 0 ? completedCount / totalTodos : 0.0;

  List<Todo> get overdueTodos {
    final now = DateTime.now();
    return _todos.where((todo) => 
      todo.dueDate != null && 
      todo.dueDate!.isBefore(now) && 
      todo.status != TodoStatus.completed
    ).toList();
  }

  List<Todo> get upcomingTodos {
    final now = DateTime.now();
    final threeDaysFromNow = now.add(const Duration(days: 3));
    return _todos.where((todo) => 
      todo.dueDate != null && 
      todo.dueDate!.isAfter(now) && 
      todo.dueDate!.isBefore(threeDaysFromNow) &&
      todo.status != TodoStatus.completed
    ).toList();
  }

  void setRoomId(String roomId) {
    if (_roomId != roomId) {
      _roomId = roomId;
      _todosSubscription?.cancel();
      _loadTodos();
    }
  }

  void _loadTodos() {
    if (_roomId == null) return;
    
    _todosSubscription = FirebaseService.getTodosStream(_roomId!)
        .listen((todos) {
      _todos = todos;
      // Update home screen widget with pending todos
      WidgetService.updateWidget(_todos);
      notifyListeners();
    });
  }

  Future<void> addTodo(Todo todo) async {
    await FirebaseService.addTodo(todo);
  }

  Future<void> updateTodo(Todo todo) async {
    await FirebaseService.updateTodo(todo);
  }

  Future<void> deleteTodo(String todoId) async {
    await FirebaseService.deleteTodo(todoId);
  }

  Future<void> toggleTodoStatus(String todoId) async {
    final todo = _todos.firstWhere((t) => t.id == todoId);
    TodoStatus newStatus;
    switch (todo.status) {
      case TodoStatus.pending:
        newStatus = TodoStatus.inProgress;
        break;
      case TodoStatus.inProgress:
        newStatus = TodoStatus.completed;
        break;
      case TodoStatus.completed:
        newStatus = TodoStatus.pending;
        break;
    }
    final updatedTodo = todo.copyWith(status: newStatus);
    await FirebaseService.updateTodo(updatedTodo);
  }

  List<Todo> getTodosByUser(String userId) {
    return _todos.where((todo) => todo.assignedTo == userId).toList();
  }

  List<Todo> getTodosByPriority(String priority) {
    return _todos.where((todo) => todo.priority == priority).toList();
  }

  @override
  void dispose() {
    _todosSubscription?.cancel();
    super.dispose();
  }
}
