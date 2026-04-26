import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/app_provider.dart';

class MinimalBalanceCard extends StatelessWidget {
  const MinimalBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseProvider, AppProvider>(
      builder: (context, expenseProvider, appProvider, child) {
        final balances = expenseProvider.balances;
        final youOwe = balances['You'] ?? 0;
        final roomieOwes = balances['Roomie'] ?? 0;
        
        String statusText;
        Color statusColor;
        
        if (youOwe > 0) {
          statusText = 'You owe \$${youOwe.toStringAsFixed(2)}';
          statusColor = Colors.red;
        } else if (roomieOwes > 0) {
          statusText = 'You\'re owed \$${roomieOwes.toStringAsFixed(2)}';
          statusColor = const Color(0xFFC8FF00);
        } else {
          statusText = 'All settled up';
          statusColor = const Color(0xFF666666);
        }
        
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Balance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF666666),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      youOwe > 0 ? 'You Owe' : roomieOwes > 0 ? 'Owed' : 'Settled',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: youOwe > 0 ? Colors.red : statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                statusText,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (appProvider.roommate != null) ...[
                const SizedBox(height: 8),
                Text(
                  'with ${appProvider.roommate!.name}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

