import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class DebugService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Debug function to check room data
  static Future<void> debugRoom(String roomId) async {
    try {
      print('🔍 Debugging room: $roomId');
      
      final roomDoc = await _firestore.collection('rooms').doc(roomId).get();
      if (roomDoc.exists) {
        print('✅ Room exists');
        print('📄 Room data: ${roomDoc.data()}');
      } else {
        print('❌ Room does not exist');
      }
    } catch (e) {
      print('❌ Error debugging room: $e');
    }
  }

  /// Debug function to check invite code
  static Future<void> debugInviteCode(String code) async {
    try {
      print('🔍 Debugging invite code: $code');
      
      final inviteDoc = await _firestore.collection('invites').doc(code.toUpperCase()).get();
      if (inviteDoc.exists) {
        print('✅ Invite code exists');
        print('📄 Invite data: ${inviteDoc.data()}');
      } else {
        print('❌ Invite code does not exist');
      }
    } catch (e) {
      print('❌ Error debugging invite code: $e');
    }
  }

  /// Debug function to check user data
  static Future<void> debugUser(String userId) async {
    try {
      print('🔍 Debugging user: $userId');
      
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        print('✅ User exists');
        print('📄 User data: ${userDoc.data()}');
      } else {
        print('❌ User does not exist');
      }
    } catch (e) {
      print('❌ Error debugging user: $e');
    }
  }
}
