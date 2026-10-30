import 'package:flutter/material.dart';

import '../utils/constants.dart';

class NotificationsPage extends StatelessWidget {
  final bool enabled;

  const NotificationsPage({super.key, this.enabled = true});

  static const _notifications = [
    _NotificationItem(
      icon: Icons.park_outlined,
      color: Color(0xFF2E7D32),
      message: 'Tree Plantation starts tomorrow.',
      time: 'Today',
    ),
    _NotificationItem(
      icon: Icons.recycling,
      color: Color(0xFF00897B),
      message: 'Recycling Drive has 10 new participants.',
      time: 'Yesterday',
    ),
    _NotificationItem(
      icon: Icons.calendar_month_outlined,
      color: Color(0xFFEF6C00),
      message: 'Your event is scheduled for Sunday.',
      time: '2 days ago',
    ),
    _NotificationItem(
      icon: Icons.eco_outlined,
      color: Color(0xFF558B2F),
      message: 'You successfully joined an event.',
      time: '3 days ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: !enabled
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Notifications are turned off',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notification = _notifications[index];

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: notification.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          notification.icon,
                          color: notification.color,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.message,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notification.time,
                              style: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.circle,
                        size: 8,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _NotificationItem {
  final IconData icon;
  final Color color;
  final String message;
  final String time;

  const _NotificationItem({
    required this.icon,
    required this.color,
    required this.message,
    required this.time,
  });
}
