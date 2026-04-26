class AppConstants {
  // App Info
  static const String appName = 'BFF Split';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Split expenses & share todos with your bestie! ✨';
  
  // Colors
  static const String primaryColor = '#FF6B9D';
  static const String secondaryColor = '#4ECDC4';
  static const String tertiaryColor = '#FFE66D';
  
  // Categories
  static const List<String> expenseCategories = [
    'Food',
    'Groceries',
    'Utilities',
    'Rent',
    'Entertainment',
    'Other',
  ];
  
  static const List<String> todoPriorities = [
    'low',
    'medium',
    'high',
  ];
  
  // Emojis
  static const Map<String, String> categoryEmojis = {
    'Food': '🍕',
    'Groceries': '🛒',
    'Utilities': '⚡',
    'Rent': '🏠',
    'Entertainment': '🎬',
    'Other': '📦',
  };
  
  static const Map<String, String> priorityEmojis = {
    'low': '🟢',
    'medium': '🟡',
    'high': '🔴',
  };
  
  // Messages
  static const List<String> motivationalMessages = [
    'You\'re doing great! 💪',
    'Keep it up! 🌟',
    'Amazing progress! 🎉',
    'You\'re on fire! 🔥',
    'So organized! 📋',
    'Crushing it! 💯',
  ];
  
  static const List<String> celebrationMessages = [
    'All settled up! 🎉',
    'Perfect balance! ⚖️',
    'You\'re even! ✨',
    'No debts! 🎊',
    'Clean slate! 🧹',
  ];
}

