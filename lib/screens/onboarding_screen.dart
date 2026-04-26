import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/app_provider.dart';
import '../services/firebase_service.dart';
import '../services/invite_service.dart';
import '../models/user.dart';
import '../widgets/avatar_picker.dart';
import 'home_screen.dart';
import 'join_room_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  int _currentPage = 0;
  String _selectedAvatar = 'avatar_1'; // Default to first cute avatar
  String? _customPhotoPath;
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _customPhotoPath = image.path;
          _selectedAvatar = 'custom_photo'; // Mark as custom photo
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking photo: $e')),
        );
      }
    }
  }

  Future<void> _createNewRoom() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('📝 Creating new room for: ${_nameController.text.trim()}');
      
      // First, check if user is already authenticated
      var firebaseUser = await FirebaseService.getCurrentUser();
      
      // If not authenticated, sign in anonymously
      if (firebaseUser == null) {
        print('🔐 No user found, signing in anonymously...');
        final credential = await FirebaseService.signInAnonymously();
        firebaseUser = credential.user;
        print('✅ Signed in as: ${firebaseUser?.uid}');
      }

      if (firebaseUser == null) {
        throw Exception('Failed to authenticate user');
      }

      final appProvider = Provider.of<AppProvider>(context, listen: false);

      // Create user
      print('👤 Creating user document...');
      final user = UserModel(
        id: firebaseUser.uid,
        name: _nameController.text.trim(),
        avatar: _selectedAvatar,
        color: '#C8FF00',
        email: firebaseUser.email ?? '',
        createdAt: DateTime.now(),
      );

      await FirebaseService.createUser(user);
      print('✅ User created: ${user.id}');

      // Create room
      print('🏠 Creating room...');
      final roomId = await FirebaseService.createRoom(
        '${_nameController.text.trim()}\'s Room',
        firebaseUser.uid,
      );
      print('✅ Room created: $roomId');

      // Join room
      print('🚪 Joining room...');
      await FirebaseService.joinRoom(roomId, firebaseUser.uid);
      print('✅ Joined room successfully');

      // Update user with room
      print('🔄 Updating user with room ID...');
      final updatedUser = UserModel(
        id: user.id,
        name: user.name,
        avatar: user.avatar,
        color: user.color,
        email: user.email,
        createdAt: user.createdAt,
        roomIds: [roomId],
      );
      await FirebaseService.updateUser(updatedUser);
      print('✅ User updated with room');

      // Initialize app
      print('🚀 Initializing app...');
      await appProvider.initializeApp();
      print('✅ App initialized');

      if (mounted) {
        print('🎉 Navigating to home screen...');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e, stackTrace) {
      print('❌ Error creating room: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _createNewRoom,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _joinExistingRoom() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name first')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('📝 Preparing to join existing room...');
      
      // First, check if user is already authenticated
      var firebaseUser = await FirebaseService.getCurrentUser();
      
      // If not authenticated, sign in anonymously
      if (firebaseUser == null) {
        print('🔐 No user found, signing in anonymously...');
        final credential = await FirebaseService.signInAnonymously();
        firebaseUser = credential.user;
        print('✅ Signed in as: ${firebaseUser?.uid}');
      }

      if (firebaseUser == null) {
        throw Exception('Failed to authenticate user');
      }

      // Create user
      final user = UserModel(
        id: firebaseUser.uid,
        name: _nameController.text.trim(),
        avatar: _selectedAvatar,
        color: '#C8FF00',
        email: firebaseUser.email ?? '',
        createdAt: DateTime.now(),
      );

      await FirebaseService.createUser(user);

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const JoinRoomScreen()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildWelcomePage(),
                  _buildProfilePage(),
                  _buildChoicePage(),
                ],
              ),
            ),
            _buildPageIndicator(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFC8FF00),
                    child: const Center(
                      child: Text(
                        '💕',
                        style: TextStyle(fontSize: 60),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Welcome to Siz',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Split expenses and manage todos\nwith your roommate',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              child: const Text('Get Started'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Text(
            'Create Your Profile',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFC8FF00),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: _customPhotoPath != null
                  ? Image.file(
                      File(_customPhotoPath!),
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                    )
                  : AvatarWidget(
                      avatarId: _selectedAvatar,
                      size: 120,
                      borderRadius: BorderRadius.circular(60),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Choose your avatar',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          AvatarSelector(
            selectedAvatarId: _selectedAvatar,
            onAvatarSelected: (avatarId) {
              if (avatarId == 'custom_photo') {
                _pickPhoto();
              } else {
                setState(() {
                  _selectedAvatar = avatarId;
                  _customPhotoPath = null; // Clear custom photo
                });
              }
            },
            includeCustomPhoto: true,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Your Name',
              hintText: 'Enter your name',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousPage,
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoicePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Text(
            'Choose an Option',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Create a new room or join your\nroommate\'s existing room',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _buildChoiceCard(
            icon: Icons.add_circle_outline,
            title: 'Create New Room',
            description: 'Start fresh and invite your roommate',
            onTap: _createNewRoom,
          ),
          const SizedBox(height: 20),
          _buildChoiceCard(
            icon: Icons.group_add_outlined,
            title: 'Join Existing Room',
            description: 'Enter your roommate\'s invite code',
            onTap: _joinExistingRoom,
          ),
          const SizedBox(height: 40),
          TextButton(
            onPressed: _previousPage,
            child: const Text('Back'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildChoiceCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFC8FF00),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (_isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(Icons.arrow_forward_ios, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => Container(
          width: _currentPage == index ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: _currentPage == index
                ? const Color(0xFFC8FF00)
                : const Color(0xFFE5E5E5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

