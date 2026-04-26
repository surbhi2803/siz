import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'firebase_service.dart';

class InviteService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate a unique 6-character invite code
  static String generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Create an invite code for a room
  static Future<String> createInviteCode(String roomId) async {
    try {
      // Generate unique code
      String code = generateInviteCode();
      
      // Check if code already exists, regenerate if needed
      bool codeExists = true;
      int attempts = 0;
      while (codeExists && attempts < 10) {
        final existingCode = await _firestore
            .collection('invites')
            .where('code', isEqualTo: code)
            .get();
        
        if (existingCode.docs.isEmpty) {
          codeExists = false;
        } else {
          code = generateInviteCode();
          attempts++;
        }
      }

      // Store invite code in Firestore
      await _firestore.collection('invites').doc(code).set({
        'code': code,
        'roomId': roomId,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'used': false,
      });

      // Update room with invite code
      await _firestore.collection('rooms').doc(roomId).update({
        'inviteCode': code,
      });

      return code;
    } catch (e) {
      print('Error creating invite code: $e');
      rethrow;
    }
  }

  /// Validate and get room ID from invite code
  static Future<String?> validateInviteCode(String code) async {
    try {
      final inviteDoc = await _firestore.collection('invites').doc(code.toUpperCase()).get();
      
      if (!inviteDoc.exists) {
        return null;
      }

      final data = inviteDoc.data()!;
      
      // Check if already used
      if (data['used'] == true) {
        return null;
      }

      // Check if expired
      final expiresAt = DateTime.parse(data['expiresAt']);
      if (DateTime.now().isAfter(expiresAt)) {
        return null;
      }

      return data['roomId'];
    } catch (e) {
      print('Error validating invite code: $e');
      return null;
    }
  }

  /// Join room with invite code
  static Future<bool> joinRoomWithCode(String code, String userId) async {
    try {
      final roomId = await validateInviteCode(code);
      
      if (roomId == null) {
        return false;
      }

      // Add user to room
      await _firestore.collection('rooms').doc(roomId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
      });

      // Update user's room list
      await _firestore.collection('users').doc(userId).update({
        'roomIds': FieldValue.arrayUnion([roomId]),
      });

      // Mark invite as used
      await _firestore.collection('invites').doc(code.toUpperCase()).update({
        'used': true,
        'usedBy': userId,
        'usedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error joining room with code: $e');
      return false;
    }
  }

  /// Get invite code for a room
  static Future<String?> getInviteCode(String roomId) async {
    try {
      final roomDoc = await _firestore.collection('rooms').doc(roomId).get();
      
      if (!roomDoc.exists) {
        return null;
      }

      final data = roomDoc.data()!;
      
      // If room has invite code, return it
      if (data.containsKey('inviteCode')) {
        return data['inviteCode'];
      }

      // Otherwise create new one
      return await createInviteCode(roomId);
    } catch (e) {
      print('Error getting invite code: $e');
      return null;
    }
  }

  /// Share invite code via system share sheet
  static Future<void> shareInviteCode(String code) async {
    try {
      final text = 'Join me on Siz! Use invite code: $code\n\nDownload the app and enter this code to split expenses and manage todos together! 💕';
      await Share.share(text, subject: 'Join me on Siz!');
    } catch (e) {
      print('Error sharing invite code: $e');
    }
  }

  /// Generate shareable link (for future deep linking)
  static String generateInviteLink(String code) {
    // This will be used with Firebase Dynamic Links
    return 'https://siz.app/join/$code';
  }

  /// Share invite link
  static Future<void> shareInviteLink(String code) async {
    try {
      final link = generateInviteLink(code);
      final text = 'Join me on Siz! 💕\n\n$link\n\nTap the link or use code: $code';
      await Share.share(text, subject: 'Join me on Siz!');
    } catch (e) {
      print('Error sharing invite link: $e');
    }
  }
}

