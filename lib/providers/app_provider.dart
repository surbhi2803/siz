import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/firebase_service.dart';

class AppProvider extends ChangeNotifier {
  UserModel? _currentUser;
  UserModel? _roommate;
  String? _currentRoomId;
  bool _isInitialized = false;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  UserModel? get roommate => _roommate;
  String? get currentRoomId => _currentRoomId;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  Future<void> initializeApp() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user is already authenticated
      final firebaseUser = await FirebaseService.getCurrentUser();
      
      if (firebaseUser != null) {
        // User is authenticated, load their data
        _currentUser = await FirebaseService.getUser(firebaseUser.uid);
        
        if (_currentUser != null && _currentUser!.roomIds.isNotEmpty) {
          _currentRoomId = _currentUser!.roomIds.first;
          await _loadRoommate();
        }
      } else {
        // No user authenticated, sign in anonymously
        final userCredential = await FirebaseService.signInAnonymously();
        final firebaseUser = userCredential.user;
        
        if (firebaseUser != null) {
          // Create default user
          _currentUser = UserModel(
            id: firebaseUser.uid,
            name: 'You',
            avatar: '👩‍💻',
            color: '#FF6B9D',
            email: firebaseUser.email ?? '',
            createdAt: DateTime.now(),
          );
          
          await FirebaseService.createUser(_currentUser!);
          
          // Create a room
          _currentRoomId = await FirebaseService.createRoom('My Room', firebaseUser.uid);
          
          // Add user to room
          await FirebaseService.joinRoom(_currentRoomId!, firebaseUser.uid);
          
          // Update user with room ID
          _currentUser = _currentUser!.copyWith(
            roomIds: [_currentRoomId!],
          );
          await FirebaseService.updateUser(_currentUser!);
        }
      }
      
      _isInitialized = true;
    } catch (e) {
      print('Error initializing app: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadRoommate() async {
    if (_currentRoomId == null) return;
    
    try {
      final room = await FirebaseService.getRoom(_currentRoomId!);
      if (room != null && room['members'] != null) {
        final members = List<String>.from(room['members']);
        final otherMemberId = members.firstWhere(
          (id) => id != _currentUser?.id,
          orElse: () => '',
        );
        
        if (otherMemberId.isNotEmpty) {
          _roommate = await FirebaseService.getUser(otherMemberId);
        }
      }
    } catch (e) {
      print('Error loading roommate: $e');
    }
  }

  Future<void> updateCurrentUser(UserModel user) async {
    _currentUser = user;
    await FirebaseService.updateUser(user);
    notifyListeners();
  }

  Future<void> updateRoommate(UserModel user) async {
    _roommate = user;
    await FirebaseService.updateUser(user);
    notifyListeners();
  }

  Future<void> signOut() async {
    await FirebaseService.signOut();
    _currentUser = null;
    _roommate = null;
    _currentRoomId = null;
    _isInitialized = false;
    notifyListeners();
  }

}
