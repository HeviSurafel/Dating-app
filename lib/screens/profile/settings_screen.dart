// lib/screens/profile/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dating_app/services/user_service.dart';
import 'package:dating_app/themes/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotifications = true;
  bool _matchEmails = true;
  bool _marketingEmails = false;
  bool _showAge = true;
  bool _showDistance = true;
  bool _showOnlineStatus = true;
  String _language = 'en';
  String _theme = 'system';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final userService = UserService();
      final result = await userService.getSettings();

      if (result['success'] == true) {
        final settings = result['data'] as Map<String, dynamic>?;
        if (settings != null) {
          setState(() {
            _pushNotifications = settings['receive_push_notifications'] ?? true;
            _matchEmails = settings['receive_match_emails'] ?? true;
            _marketingEmails = settings['receive_marketing_emails'] ?? false;
            _showAge = settings['show_age'] ?? true;
            _showDistance = settings['show_distance'] ?? true;
            _showOnlineStatus = settings['show_online_status'] ?? true;
            _language = settings['language'] ?? 'en';
            _theme = settings['theme'] ?? 'system';
          });
        }
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    try {
      final userService = UserService();
      await userService.updateSettings({
        'receive_push_notifications': _pushNotifications,
        'receive_match_emails': _matchEmails,
        'receive_marketing_emails': _marketingEmails,
        'show_age': _showAge,
        'show_distance': _showDistance,
        'show_online_status': _showOnlineStatus,
        'language': _language,
        'theme': _theme,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully! ✅'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save settings'),
            backgroundColor: Colors.red,
          ),
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
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primaryColor,
              ),
            )
                : TextButton(
              onPressed: _saveSettings,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildSection(
            title: 'Account',
            icon: Icons.person_outline,
            children: [
              _buildSettingItem(
                icon: Icons.person,
                title: 'Edit Profile',
                subtitle: 'Update your personal information',
                onTap: () => context.go('/home/profile/edit'),
              ),
              _buildSettingItem(
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your password',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.email_outlined,
                title: 'Change Email',
                subtitle: 'Update your email address',
                onTap: () {},
              ),
            ],
          ),
          _buildSection(
            title: 'Privacy',
            icon: Icons.privacy_tip_outlined,
            children: [
              _buildSwitchItem(
                icon: Icons.visibility,
                title: 'Show Age',
                subtitle: 'Display your age on your profile',
                value: _showAge,
                onChanged: (value) {
                  setState(() => _showAge = value);
                },
              ),
              _buildSwitchItem(
                icon: Icons.location_on,
                title: 'Show Distance',
                subtitle: 'Display distance on your profile',
                value: _showDistance,
                onChanged: (value) {
                  setState(() => _showDistance = value);
                },
              ),
              _buildSwitchItem(
                icon: Icons.circle,
                title: 'Show Online Status',
                subtitle: 'Show when you\'re active',
                value: _showOnlineStatus,
                onChanged: (value) {
                  setState(() => _showOnlineStatus = value);
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Notifications',
            icon: Icons.notifications_outlined,
            children: [
              _buildSwitchItem(
                icon: Icons.notifications_active,
                title: 'Push Notifications',
                subtitle: 'Receive push notifications',
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() => _pushNotifications = value);
                },
              ),
              _buildSwitchItem(
                icon: Icons.email,
                title: 'Match Emails',
                subtitle: 'Receive match notifications via email',
                value: _matchEmails,
                onChanged: (value) {
                  setState(() => _matchEmails = value);
                },
              ),
              _buildSwitchItem(
                icon: Icons.mark_email_read,
                title: 'Marketing Emails',
                subtitle: 'Receive promotional emails',
                value: _marketingEmails,
                onChanged: (value) {
                  setState(() => _marketingEmails = value);
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Preferences',
            icon: Icons.settings_outlined,
            children: [
              _buildDropdownItem(
                icon: Icons.language,
                title: 'Language',
                subtitle: 'Choose your preferred language',
                value: _language,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('🇬🇧 English')),
                  DropdownMenuItem(value: 'es', child: Text('🇪🇸 Spanish')),
                  DropdownMenuItem(value: 'fr', child: Text('🇫🇷 French')),
                  DropdownMenuItem(value: 'de', child: Text('🇩🇪 German')),
                  DropdownMenuItem(value: 'am', child: Text('🇪🇹 Amharic')),
                ],
                onChanged: (value) {
                  setState(() => _language = value!);
                },
              ),
              _buildDropdownItem(
                icon: Icons.palette,
                title: 'Theme',
                subtitle: 'Choose your theme preference',
                value: _theme,
                items: const [
                  DropdownMenuItem(value: 'light', child: Text('☀️ Light')),
                  DropdownMenuItem(value: 'dark', child: Text('🌙 Dark')),
                  DropdownMenuItem(value: 'system', child: Text('📱 System')),
                ],
                onChanged: (value) {
                  setState(() => _theme = value!);
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Support',
            icon: Icons.help_outline,
            children: [
              _buildSettingItem(
                icon: Icons.help,
                title: 'Help Center',
                subtitle: 'Get help and support',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.feedback,
                title: 'Send Feedback',
                subtitle: 'Help us improve',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.info,
                title: 'About',
                subtitle: 'Version 1.0.0',
                onTap: () => _showAboutDialog(),
              ),
            ],
          ),
          _buildSection(
            title: 'Danger Zone',
            icon: Icons.warning_amber_outlined,
            children: [
              _buildSettingItem(
                icon: Icons.delete_forever,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                color: Colors.red,
                onTap: _showDeleteAccountDialog,
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 16, 8),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.primaryColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 12,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
      onTap: () => onChanged(!value),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDropdownItem<T>({
    required IconData icon,
    required String title,
    required String subtitle,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[500],
          fontSize: 12,
        ),
      ),
      trailing: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        underline: const SizedBox(),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.favorite, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            const Text('About'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite,
                color: AppTheme.primaryColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Dating App',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Find your perfect match with our smart matching algorithm.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '© 2024 Dating App Inc.',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Delete Account'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to delete your account?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone. All your data, including matches and messages, will be permanently deleted.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text(
              'Delete Account',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      final userService = UserService();
      final result = await userService.deleteAccount();

      if (result['success'] == true && mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
              (route) => false,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to delete account'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete account'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}