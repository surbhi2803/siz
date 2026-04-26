class UserModel {
  final String id;
  final String name;
  final String avatar;
  final String color;
  final String email;
  final DateTime createdAt;
  final List<String> roomIds;

  UserModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.color,
    required this.email,
    required this.createdAt,
    this.roomIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'color': color,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'roomIds': roomIds,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      color: json['color'],
      email: json['email'],
      createdAt: DateTime.parse(json['createdAt']),
      roomIds: List<String>.from(json['roomIds'] ?? []),
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? avatar,
    String? color,
    String? email,
    DateTime? createdAt,
    List<String>? roomIds,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      color: color ?? this.color,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      roomIds: roomIds ?? this.roomIds,
    );
  }
}
