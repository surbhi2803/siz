class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String paidBy;
  final String description;
  final DateTime date;
  final bool isSplit;
  final String roomId;
  final String paidById;
  final bool isPaid;
  final DateTime? paidAt;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.paidBy,
    required this.description,
    required this.date,
    required this.roomId,
    required this.paidById,
    this.isSplit = true,
    this.isPaid = false,
    this.paidAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'paidBy': paidBy,
      'description': description,
      'date': date.toIso8601String(),
      'isSplit': isSplit,
      'roomId': roomId,
      'paidById': paidById,
      'isPaid': isPaid,
      'paidAt': paidAt?.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      category: json['category'],
      paidBy: json['paidBy'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      roomId: json['roomId'],
      paidById: json['paidById'],
      isSplit: json['isSplit'] ?? true,
      isPaid: json['isPaid'] ?? false,
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
    );
  }

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    String? paidBy,
    String? description,
    DateTime? date,
    bool? isSplit,
    String? roomId,
    String? paidById,
    bool? isPaid,
    DateTime? paidAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      paidBy: paidBy ?? this.paidBy,
      description: description ?? this.description,
      date: date ?? this.date,
      isSplit: isSplit ?? this.isSplit,
      roomId: roomId ?? this.roomId,
      paidById: paidById ?? this.paidById,
      isPaid: isPaid ?? this.isPaid,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}
