import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/expense_provider.dart';
import '../providers/app_provider.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseProvider, AppProvider>(
      builder: (context, expenseProvider, appProvider, child) {
        final balances = expenseProvider.balances;
        final youOwe = balances['You']!;
        final roomieOwes = balances['Roomie']!;
        
        Color cardColor;
        Color iconColor;
        String emoji;
        String balanceText;
        
        if (youOwe > 0) {
          cardColor = const Color(0xFFFFD8E8); // Baby pink
          iconColor = const Color(0xFFFF7CB5); // Soft pink
          emoji = '📈';
          balanceText = 'You owe \$${youOwe.toStringAsFixed(2)}';
        } else if (roomieOwes > 0) {
          cardColor = const Color(0xFFC8FCEA); // Mint green
          iconColor = const Color(0xFF4ECDC4); // Teal
          emoji = '📉';
          balanceText = 'Roomie owes \$${roomieOwes.toStringAsFixed(2)}';
        } else {
          cardColor = const Color(0xFFEAE4FF); // Lavender
          iconColor = const Color(0xFF9B59B6); // Purple
          emoji = '🎉';
          balanceText = 'All settled up!';
        }
        
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cardColor,
                cardColor.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Balance Summary',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          balanceText,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: _buildBalanceItem(
                      context,
                      'You',
                      youOwe,
                      appProvider.currentUser?.avatar ?? '👩‍💻',
                      appProvider.currentUser?.color ?? '#FF6B9D',
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: _buildBalanceItem(
                      context,
                      'Roomie',
                      roomieOwes,
                      appProvider.roommate?.avatar ?? '👩‍🎨',
                      appProvider.roommate?.color ?? '#4ECDC4',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate()
          .fadeIn(duration: 600.ms)
          .slideY(begin: 0.3, end: 0);
      },
    );
  }
  
  Widget _buildBalanceItem(
    BuildContext context,
    String name,
    double amount,
    String avatar,
    String color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            avatar,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${amount.abs().toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: amount >= 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
