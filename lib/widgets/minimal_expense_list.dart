import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';

class MinimalExpenseList extends StatelessWidget {
  final int limit;
  
  const MinimalExpenseList({super.key, this.limit = 5});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final expenses = expenseProvider.getRecentExpenses(limit: limit);
        
        if (expenses.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.receipt_outlined, size: 48, color: Color(0xFFE5E5E5)),
                const SizedBox(height: 12),
                Text(
                  'No expenses yet',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }
        
        return Column(
          children: expenses.map((expense) {
            return GestureDetector(
              onLongPress: () {
                if (expense.isPaid) {
                  expenseProvider.markAsUnpaid(expense.id);
                } else {
                  expenseProvider.markAsPaid(expense.id);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
                ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _getCategoryEmoji(expense.category),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d, yyyy').format(expense.date),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '\$${expense.amount.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: expense.isPaid ? Colors.green : null,
                            ),
                          ),
                          if (expense.isPaid) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.check_circle, size: 16, color: Colors.green),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        expense.paidBy,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return '🍔';
      case 'transport':
        return '🚗';
      case 'utilities':
        return '💡';
      case 'entertainment':
        return '🎬';
      case 'shopping':
        return '🛍️';
      case 'health':
        return '🏥';
      case 'rent':
        return '🏠';
      default:
        return '💰';
    }
  }
}

