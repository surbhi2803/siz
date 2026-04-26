import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../screens/add_expense_screen.dart';
import '../screens/add_todo_screen.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions ✨',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF333333),
          ),
        ).animate()
          .fadeIn(duration: 600.ms)
          .slideX(begin: -0.3, end: 0),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'Add Expense',
                'Split a bill 💸',
                Icons.receipt_long_rounded,
                const Color(0xFFFFD8E8), // Baby pink
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: _buildActionCard(
                context,
                'Add Todo',
                'New task 📝',
                Icons.checklist_rounded,
                const Color(0xFFC8FCEA), // Mint green
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddTodoScreen()),
                ),
              ),
            ),
          ],
        ).animate()
          .fadeIn(duration: 800.ms, delay: 200.ms)
          .slideY(begin: 0.3, end: 0),
      ],
    );
  }
  
  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
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
              child: Icon(
                icon,
                color: const Color(0xFF333333),
                size: 24,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),
            
            const SizedBox(height: 4),
            
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
