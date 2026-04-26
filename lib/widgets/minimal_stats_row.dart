import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/todo_provider.dart';

class MinimalStatsRow extends StatelessWidget {
  const MinimalStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseProvider, TodoProvider>(
      builder: (context, expenseProvider, todoProvider, child) {
        final totalExpenses = expenseProvider.totalExpenses;
        final completedTodos = todoProvider.completedCount;
        final totalTodos = todoProvider.totalTodos;

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Total Spent',
                '\$${totalExpenses.toStringAsFixed(0)}',
                Icons.attach_money,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Todos Done',
                '$completedTodos/$totalTodos',
                Icons.check_circle,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: const Color(0xFF666666)),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

