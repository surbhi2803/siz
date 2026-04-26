import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/invite_service.dart';
import '../services/firebase_service.dart';
import '../services/debug_service.dart';
import 'home_screen.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  bool _showScanner = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinWithCode(String code) async {
    if (code.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an invite code')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final firebaseUser = await FirebaseService.getCurrentUser();
      if (firebaseUser == null) {
        throw Exception('No user authenticated');
      }

      print('🔍 Attempting to join room with code: ${code.trim().toUpperCase()}');
      print('👤 User ID: ${firebaseUser.uid}');

      // Debug the invite code first
      await DebugService.debugInviteCode(code.trim().toUpperCase());

      final success = await InviteService.joinRoomWithCode(
        code.trim().toUpperCase(),
        firebaseUser.uid,
      );

      if (!success) {
        throw Exception('Invalid or expired invite code');
      }

      // Initialize app
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider.initializeApp();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onQRCodeDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final code = barcodes.first.rawValue;
      if (code != null) {
        setState(() => _showScanner = false);
        _joinWithCode(code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showScanner) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scan QR Code'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() => _showScanner = false);
            },
          ),
        ),
        body: MobileScanner(
          onDetect: _onQRCodeDetected,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Room'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFC8FF00),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Center(
                  child: Icon(Icons.group_add, size: 50),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Join Your Roommate',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Enter the invite code your roommate\nshared with you',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Invite Code',
                  hintText: 'Enter 6-character code',
                  prefixIcon: Icon(Icons.vpn_key),
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () => _joinWithCode(_codeController.text),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Join Room'),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() => _showScanner = true);
                        },
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan QR Code'),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

