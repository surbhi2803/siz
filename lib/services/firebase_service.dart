import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/expense.dart';
import '../models/todo.dart';
import '../models/user.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Collections
  static const String _expensesCollection = 'expenses';
  static const String _todosCollection = 'todos';
  static const String _usersCollection = 'users';
  static const String _roomsCollection = 'rooms';

  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    await _messaging.requestPermission();
  }

  // Authentication
  static Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  static Future<UserCredential> signInAnonymously() async {
    try {
      print('🔐 Attempting anonymous sign-in...');
      final credential = await _auth.signInAnonymously();
      print('✅ Anonymous sign-in successful: ${credential.user?.uid}');
      return credential;
    } catch (e) {
      print('❌ Anonymous sign-in failed: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // User Management
  static Future<void> createUser(UserModel user) async {
    await _firestore
        .collection(_usersCollection)
        .doc(user.id)
        .set(user.toJson());
  }

  static Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .get();
    
    if (doc.exists) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  static Future<void> updateUser(UserModel user) async {
    await _firestore
        .collection(_usersCollection)
        .doc(user.id)
        .update(user.toJson());
  }

  // Room Management
  static Future<String> createRoom(String roomName, String createdBy) async {
    final roomRef = await _firestore.collection(_roomsCollection).add({
      'name': roomName,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      'memberIds': [createdBy], // Changed from 'members' to 'memberIds'
    });
    return roomRef.id;
  }

  static Future<void> joinRoom(String roomId, String userId) async {
    await _firestore
        .collection(_roomsCollection)
        .doc(roomId)
        .update({
      'memberIds': FieldValue.arrayUnion([userId]), // Changed from 'members' to 'memberIds'
    });
  }

  static Future<Map<String, dynamic>?> getRoom(String roomId) async {
    final doc = await _firestore
        .collection(_roomsCollection)
        .doc(roomId)
        .get();
    
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  // Expenses
  static Stream<List<Expense>> getExpensesStream(String roomId) {
    return _firestore
        .collection(_expensesCollection)
        .where('roomId', isEqualTo: roomId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromJson(doc.data()))
            .toList());
  }

  static Future<void> addExpense(Expense expense) async {
    await _firestore
        .collection(_expensesCollection)
        .doc(expense.id)
        .set(expense.toJson());
  }

  static Future<void> updateExpense(Expense expense) async {
    await _firestore
        .collection(_expensesCollection)
        .doc(expense.id)
        .update(expense.toJson());
  }

  static Future<void> deleteExpense(String expenseId) async {
    await _firestore
        .collection(_expensesCollection)
        .doc(expenseId)
        .delete();
  }

  // Todos
  static Stream<List<Todo>> getTodosStream(String roomId) {
    return _firestore
        .collection(_todosCollection)
        .where('roomId', isEqualTo: roomId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Todo.fromJson(doc.data()))
            .toList());
  }

  static Future<void> addTodo(Todo todo) async {
    await _firestore
        .collection(_todosCollection)
        .doc(todo.id)
        .set(todo.toJson());
  }

  static Future<void> updateTodo(Todo todo) async {
    await _firestore
        .collection(_todosCollection)
        .doc(todo.id)
        .update(todo.toJson());
  }

  static Future<void> deleteTodo(String todoId) async {
    await _firestore
        .collection(_todosCollection)
        .doc(todoId)
        .delete();
  }

  // Real-time updates
  static Stream<DocumentSnapshot> getRoomStream(String roomId) {
    return _firestore
        .collection(_roomsCollection)
        .doc(roomId)
        .snapshots();
  }

  // Batch operations
  static Future<void> batchUpdateExpenses(List<Expense> expenses) async {
    final batch = _firestore.batch();
    
    for (final expense in expenses) {
      final docRef = _firestore
          .collection(_expensesCollection)
          .doc(expense.id);
      batch.set(docRef, expense.toJson());
    }
    
    await batch.commit();
  }

  static Future<void> batchUpdateTodos(List<Todo> todos) async {
    final batch = _firestore.batch();
    
    for (final todo in todos) {
      final docRef = _firestore
          .collection(_todosCollection)
          .doc(todo.id);
      batch.set(docRef, todo.toJson());
    }
    
    await batch.commit();
  }

  // Cleanup
  static Future<void> deleteRoom(String roomId) async {
    // Delete all expenses in the room
    final expensesQuery = await _firestore
        .collection(_expensesCollection)
        .where('roomId', isEqualTo: roomId)
        .get();
    
    final batch = _firestore.batch();
    for (final doc in expensesQuery.docs) {
      batch.delete(doc.reference);
    }
    
    // Delete all todos in the room
    final todosQuery = await _firestore
        .collection(_todosCollection)
        .where('roomId', isEqualTo: roomId)
        .get();
    
    for (final doc in todosQuery.docs) {
      batch.delete(doc.reference);
    }
    
    // Delete the room
    batch.delete(_firestore.collection(_roomsCollection).doc(roomId));
    
    await batch.commit();
  }
}

