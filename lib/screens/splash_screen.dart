import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/todo_provider.dart';
import '../providers/theme_provider.dart';
import '../services/firebase_service.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      await themeProvider.loadTheme();
      
      // Check if user is authenticated
      final firebaseUser = await FirebaseService.getCurrentUser();
      
      Widget nextScreen;
      if (firebaseUser == null) {
        // No user, show onboarding
        nextScreen = const OnboardingScreen();
      } else {
        // User exists, check if they have a room
        final user = await FirebaseService.getUser(firebaseUser.uid);
        if (user == null || user.roomIds.isEmpty) {
          // User exists but no room, show onboarding
          nextScreen = const OnboardingScreen();
        } else {
          // User has room, initialize and go to home
          final appProvider = Provider.of<AppProvider>(context, listen: false);
          await appProvider.initializeApp();
          nextScreen = const HomeScreen();
        }
      }
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => nextScreen),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Image - Circular
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
                            print('❌ Logo not found: $error');
                            // Fallback if logo not found
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
                    ).animate()
                      .scale(duration: 600.ms, curve: Curves.easeOut)
                      .fadeIn(duration: 400.ms),

            const SizedBox(height: 32),

            Text(
              'Siz',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 12),

            Text(
              'Math is overrated. Trust the app.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ).animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 48),

            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC8FF00)),
              ),
            ).animate()
              .fadeIn(duration: 400.ms, delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
