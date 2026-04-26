import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/todo.dart';

class WidgetService {
  static const String _widgetTodosKey = 'widget_todos';

  /// Update widget data with pending todos
  static Future<void> updateWidget(List<Todo> todos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Filter pending todos
      final pendingTodos = todos.where((todo) => todo.status != TodoStatus.completed).toList();
      
      // Convert to simple JSON (just what widget needs)
      final widgetData = pendingTodos.take(5).map((todo) => {
        'title': todo.title,
        'priority': todo.priority,
      }).toList();
      
      // Save to shared preferences
      await prefs.setString(_widgetTodosKey, jsonEncode(widgetData));
      
      // Trigger widget update (Android specific)
      // Note: You would need platform channels for full implementation
      print('Widget data updated: ${pendingTodos.length} pending todos');
    } catch (e) {
      print('Error updating widget: $e');
    }
  }

  /// Clear widget data
  static Future<void> clearWidget() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_widgetTodosKey);
    } catch (e) {
      print('Error clearing widget: $e');
    }
  }
}

