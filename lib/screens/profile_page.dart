import 'package:flutter/material.dart';

import '../models/user.dart';

import 'dart:io';

import '../services/app_preferences.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../utils/constants.dart';
import 'achievements_page.dart';
import 'admin_dashboard_page.dart';
import 'edit_profile_page.dart';
import 'favorites_page.dart';
import 'my_events_page.dart';
import 'splash_screen.dart';
import 'statistics_page.dart';

class ProfilePage extends StatefulWidget {
  final AuthService authService;
  final AppPreferences preferences;
  final EventService eventService;

  const ProfilePage({
    super.key,
    required this.authService,
    required this.preferences,
    required this.eventService,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = widget.authService.currentUser;
    final userId = user?.id ?? '';
    final userName = user?.name ?? 'Eco User';
    final joinedEvents = widget.eventService.getJoinedEvents(userId);
    final createdEvents = widget.eventService.getCreatedEvents(userId);
    final peopleReached = widget.eventService
        .getEnvironmentalImpact(userId)
        .peopleReached;
    final ecoPoints = widget.eventService.getEcoPoints(userId);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                Semantics(
                  button: true,
                  label: 'Edit profile photo',
                  child: InkWell(
                    onTap: user == null ? null : () => _editProfile(user),
                    customBorder: const CircleBorder(),
                    child: Stack(
                      children: [
                        _profileAvatar(user?.profileImagePath, userName),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: CircleAvatar(
                            radius: 15,
                            backgroundColor: colorScheme.primary,
                            child: const Icon(
                              Icons.edit,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  userName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Environmental Enthusiast 🌱',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                if (user?.location.isNotEmpty == true) ...[
                  const SizedBox(height: 6),
                  Text(
                    user!.location,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: user == null ? null : () => _editProfile(user),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Profile'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle(context, '🌱 Your Impact'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _summaryStat(
                  context,
                  value: '${joinedEvents.length}',
                  label: 'Events Joined',
                  icon: Icons.event_available_outlined,
                ),
              ),
              Expanded(
                child: _summaryStat(
                  context,
                  value: '${createdEvents.length}',
                  label: 'Events Created',
                  icon: Icons.event_note_outlined,
                ),
              ),
              Expanded(
                child: _summaryStat(
                  context,
                  value: '$peopleReached',
                  label: 'People Reached',
                  icon: Icons.people_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$ecoPoints eco points earned',
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _sectionTitle(context, 'Achievements')),
              TextButton(
                onPressed: () => _push(
                  AchievementsPage(
                    eventService: widget.eventService,
                    userId: userId,
                  ),
                ),
                child: const Text('See all'),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _badge(context, '🌱', 'Eco Beginner', ecoPoints >= 0),
              _badge(context, '🌿', 'Green Volunteer', ecoPoints >= 100),
              _badge(context, '🌳', 'Nature Protector', ecoPoints >= 250),
              _badge(context, '🌎', 'Eco Champion', ecoPoints >= 500),
            ],
          ),
          const SizedBox(height: 24),
          _sectionTitle(context, 'My Activities'),
          _menuItem(
            context,
            icon: Icons.event_available_outlined,
            title: 'My Events',
            onTap: () => _push(
              MyEventsPage(
                eventService: widget.eventService,
                userId: userId,
                userName: userName,
              ),
            ),
          ),
          _menuItem(
            context,
            icon: Icons.favorite_border,
            title: 'Favorites',
            onTap: () => _push(
              FavoritesPage(
                eventService: widget.eventService,
                userId: userId,
                userName: userName,
              ),
            ),
          ),
          _menuItem(
            context,
            icon: Icons.bar_chart_outlined,
            title: 'Statistics',
            onTap: () => _push(
              StatisticsPage(
                eventService: widget.eventService,
                userId: userId,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Icon(Icons.eco_outlined, color: colorScheme.primary, size: 28),
                const SizedBox(height: 8),
                Text(
                  'About Environmental Event App',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Version 1.0.0\nMade for a greener future 🌍',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (user?.isAdmin == true) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _push(
                AdminDashboardPage(
                  authService: widget.authService,
                  eventService: widget.eventService,
                ),
              ),
              icon: const Icon(Icons.admin_panel_settings_outlined),
              label: const Text('Open Admin Dashboard'),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () async {
                await widget.authService.logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SplashScreen(
                      preferences: widget.preferences,
                      authService: widget.authService,
                    ),
                  ),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text(
                'LOGOUT',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileAvatar(String? imagePath, String name) {
    final fallback = CircleAvatar(
      radius: 44,
      backgroundColor: AppColors.lightGreen,
      child: Text(
        name.isEmpty ? '🌱' : name.characters.first.toUpperCase(),
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    if (imagePath == null || imagePath.isEmpty) return fallback;
    return CircleAvatar(
      radius: 44,
      backgroundColor: AppColors.lightGreen,
      child: ClipOval(
        child: Image.file(
          File(imagePath),
          width: 88,
          height: 88,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => fallback,
        ),
      ),
    );
  }

  Future<void> _editProfile(AppUser user) async {
    final updated = await _push<bool>(
      EditProfilePage(authService: widget.authService, user: user),
    );
    if (updated == true && mounted) setState(() {});
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 19,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _summaryStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 21),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _badge(BuildContext context, String icon, String title, bool earned) {
    final colorScheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: Text(icon),
      label: Text(title),
      backgroundColor: earned
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
      labelStyle: TextStyle(
        color: earned ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
        fontSize: 12,
      ),
      side: BorderSide.none,
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Future<T?> _push<T>(Widget page) {
    return Navigator.push<T>(context, MaterialPageRoute(builder: (_) => page));
  }
}
