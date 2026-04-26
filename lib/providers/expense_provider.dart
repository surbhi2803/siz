import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';
import '../services/firebase_service.dart';
import '../providers/app_provider.dart';

class ExpenseProvider extends ChangeNotifier {
  List<Expense> _expenses = [];
  String? _roomId;
  StreamSubscription<List<Expense>>? _expensesSubscription;
  
  List<Expense> get expenses => _expenses;

  double get totalExpenses => _expenses.fold(0, (sum, expense) => sum + expense.amount);
  
  Map<String, double> get balances {
    Map<String, double> balances = {'You': 0.0, 'Roomie': 0.0};
    
    for (var expense in _expenses) {
      if (expense.isSplit) {
        double splitAmount = expense.amount / 2;
        if (expense.paidBy == 'You') {
          balances['You'] = balances['You']! + splitAmount;
          balances['Roomie'] = balances['Roomie']! - splitAmount;
        } else {
          balances['You'] = balances['You']! - splitAmount;
          balances['Roomie'] = balances['Roomie']! + splitAmount;
        }
      } else {
        if (expense.paidBy == 'You') {
          balances['You'] = balances['You']! + expense.amount;
          balances['Roomie'] = balances['Roomie']! - expense.amount;
        } else {
          balances['You'] = balances['You']! - expense.amount;
          balances['Roomie'] = balances['Roomie']! + expense.amount;
        }
      }
    }
    
    return balances;
  }

  String get balanceSummary {
    final balances = this.balances;
    final youOwe = balances['You']!;
    final roomieOwes = balances['Roomie']!;
    
    if (youOwe > 0) {
      return 'You owe \$${youOwe.toStringAsFixed(2)}';
    } else if (roomieOwes > 0) {
      return 'Roomie owes \$${roomieOwes.toStringAsFixed(2)}';
    } else {
      return 'All settled up! 🎉';
    }
  }

  void setRoomId(String roomId) {
    if (_roomId != roomId) {
      _roomId = roomId;
      _expensesSubscription?.cancel();
      _loadExpenses();
    }
  }

  void _loadExpenses() {
    if (_roomId == null) return;
    
    _expensesSubscription = FirebaseService.getExpensesStream(_roomId!)
        .listen((expenses) {
      _expenses = expenses;
      notifyListeners();
    });
  }

  Future<void> addExpense(Expense expense) async {
    await FirebaseService.addExpense(expense);
  }

  Future<void> updateExpense(Expense expense) async {
    await FirebaseService.updateExpense(expense);
  }

  Future<void> deleteExpense(String expenseId) async {
    await FirebaseService.deleteExpense(expenseId);
  }

  Future<void> markAsPaid(String expenseId) async {
    final expense = _expenses.firstWhere((e) => e.id == expenseId);
    final updatedExpense = expense.copyWith(
      isPaid: true,
      paidAt: DateTime.now(),
    );
    await FirebaseService.updateExpense(updatedExpense);
  }

  Future<void> markAsUnpaid(String expenseId) async {
    final expense = _expenses.firstWhere((e) => e.id == expenseId);
    final updatedExpense = expense.copyWith(
      isPaid: false,
      paidAt: null,
    );
    await FirebaseService.updateExpense(updatedExpense);
  }

  List<Expense> getExpensesByCategory(String category) {
    return _expenses.where((e) => e.category == category).toList();
  }

  List<Expense> getRecentExpenses({int limit = 5}) {
    final sortedExpenses = List<Expense>.from(_expenses);
    sortedExpenses.sort((a, b) => b.date.compareTo(a.date));
    return sortedExpenses.take(limit).toList();
  }

  @override
  void dispose() {
    _expensesSubscription?.cancel();
    super.dispose();
  }
}
