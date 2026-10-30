import 'package:flutter/material.dart';

import '../services/app_preferences.dart';

class SettingsPage extends StatelessWidget {
  final AppPreferences preferences;

  const SettingsPage({super.key, required this.preferences});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: AnimatedBuilder(
        animation: preferences,
        builder: (context, child) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            _settingTile(
              context,
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              subtitle: 'Use a darker app appearance',
              value: preferences.darkModeEnabled,
              onChanged: preferences.setDarkModeEnabled,
            ),
            _settingTile(
              context,
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Show event updates and reminders',
              value: preferences.notificationsEnabled,
              onChanged: preferences.setNotificationsEnabled,
            ),
            _settingTile(
              context,
              icon: Icons.eco_outlined,
              title: 'Eco Tips',
              subtitle: 'Show environmental tips on Home',
              value: preferences.ecoTipsEnabled,
              onChanged: preferences.setEcoTipsEnabled,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Settings apply immediately and are kept for this app session.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeTrackColor: Theme.of(context).colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
