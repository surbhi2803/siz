import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/theme_provider.dart';
import '../providers/app_provider.dart';
import '../widgets/settings_tile.dart';
import '../widgets/avatar_picker.dart';
import 'invite_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(context),
            const SizedBox(height: 32),
            _buildRoommateSection(context),
            const SizedBox(height: 32),
            _buildAppearanceSection(context),
            const SizedBox(height: 32),
            _buildDataSection(context),
            const SizedBox(height: 32),
            _buildAboutSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate()
              .fadeIn(duration: 600.ms)
              .slideX(begin: -0.3, end: 0),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: AvatarWidget(
                        avatarId: appProvider.currentUser?.avatar ?? 'avatar_1',
                        size: 64,
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appProvider.currentUser?.name ?? 'You',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Primary User',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Icon(
                    Icons.edit_rounded,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ).animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideY(begin: 0.3, end: 0),
          ],
        );
      },
    );
  }

  Widget _buildRoommateSection(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Roommate',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E5E5)),
              ),
              child: Column(
                children: [
                  if (appProvider.roommate != null)
                    ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFC8FF00),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: AvatarWidget(
                            avatarId: appProvider.roommate!.avatar,
                            size: 48,
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                      title: Text(appProvider.roommate!.name),
                      subtitle: const Text('Your roommate'),
                    ),
                  if (appProvider.roommate != null)
                    const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC8FF00),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.group_add, size: 24),
                    ),
                    title: const Text('Invite Roommate'),
                    subtitle: const Text('Share your room code'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const InviteScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Appearance',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ).animate()
          .fadeIn(duration: 600.ms)
          .slideX(begin: -0.3, end: 0),
        
        const SizedBox(height: 16),
        
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.palette_rounded,
                    title: 'Theme',
                    subtitle: _getThemeName(themeProvider.themeMode),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showThemeSelector(context, themeProvider),
                  ),
                  
                  const Divider(height: 1),
                  
                  SettingsTile(
                    icon: Icons.color_lens_rounded,
                    title: 'Accent Color',
                    subtitle: 'Customize app colors',
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      // TODO: Implement color picker
                    },
                  ),
                ],
              ),
            ).animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideY(begin: 0.3, end: 0);
          },
        ),
      ],
    );
  }

  Widget _buildDataSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data & Privacy',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ).animate()
          .fadeIn(duration: 600.ms)
          .slideX(begin: -0.3, end: 0),
        
        const SizedBox(height: 16),
        
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              SettingsTile(
                icon: Icons.download_rounded,
                title: 'Export Data',
                subtitle: 'Download your data',
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  // TODO: Implement data export
                },
              ),
              
              const Divider(height: 1),
              
              SettingsTile(
                icon: Icons.upload_rounded,
                title: 'Import Data',
                subtitle: 'Restore from backup',
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  // TODO: Implement data import
                },
              ),
              
              const Divider(height: 1),
              
              SettingsTile(
                icon: Icons.delete_forever_rounded,
                title: 'Clear All Data',
                subtitle: 'Reset the app',
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showClearDataDialog(context),
                textColor: Colors.red,
              ),
            ],
          ),
        ).animate()
          .fadeIn(duration: 600.ms, delay: 200.ms)
          .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ).animate()
          .fadeIn(duration: 600.ms)
          .slideX(begin: -0.3, end: 0),
        
        const SizedBox(height: 16),
        
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              SettingsTile(
                icon: Icons.info_rounded,
                title: 'App Version',
                subtitle: '1.0.0',
                trailing: const SizedBox.shrink(),
              ),
              
              const Divider(height: 1),
              
              SettingsTile(
                icon: Icons.star_rounded,
                title: 'Rate App',
                subtitle: 'Love BFF Split? Rate us!',
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  // TODO: Implement app rating
                },
              ),
              
              const Divider(height: 1),
              
              SettingsTile(
                icon: Icons.share_rounded,
                title: 'Share App',
                subtitle: 'Tell your friends!',
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  // TODO: Implement app sharing
                },
              ),
            ],
          ),
        ).animate()
          .fadeIn(duration: 600.ms, delay: 200.ms)
          .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  String _getThemeName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showThemeSelector(BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Choose Theme',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...ThemeMode.values.map((mode) {
                    final isSelected = themeProvider.themeMode == mode;
                    return ListTile(
                      title: Text(_getThemeName(mode)),
                      leading: Radio<ThemeMode>(
                        value: mode,
                        groupValue: themeProvider.themeMode,
                        onChanged: (value) {
                          themeProvider.setThemeMode(value!);
                          Navigator.pop(context);
                        },
                      ),
                      onTap: () {
                        themeProvider.setThemeMode(mode);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your expenses and todos. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement clear data
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data cleared!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

