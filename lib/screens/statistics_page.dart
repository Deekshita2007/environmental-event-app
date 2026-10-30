import 'package:flutter/material.dart';

import '../models/environmental_impact.dart';
import '../services/event_service.dart';
import '../utils/constants.dart';

class StatisticsPage extends StatelessWidget {
  final EventService eventService;
  final String userId;

  const StatisticsPage({
    super.key,
    required this.eventService,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final events = eventService.getEvents();
    final joinedEvents = eventService.getJoinedEvents(userId);
    final createdEvents = eventService.getCreatedEvents(userId);
    final impact = eventService.getEnvironmentalImpact(userId);
    final totalParticipants = events.fold<int>(
      0,
      (total, event) => total + event.participants,
    );
    final upcomingEvents = events
        .where((event) => event.date.isAfter(DateTime.now()))
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Your contribution',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  context,
                  icon: Icons.event_available_outlined,
                  label: 'Events joined',
                  value: '${joinedEvents.length}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  context,
                  icon: Icons.event_note_outlined,
                  label: 'Events created',
                  value: '${createdEvents.length}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  context,
                  icon: Icons.stars_outlined,
                  label: 'Eco points',
                  value: '${eventService.getEcoPoints(userId)}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  context,
                  icon: Icons.people_outline,
                  label: 'People reached',
                  value: '${impact.peopleReached}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Your environmental activities',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _activityBreakdown(context, impact),
          const SizedBox(height: 24),
          Text(
            'Community overview',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  context,
                  icon: Icons.event_outlined,
                  label: 'Approved events',
                  value: '${events.length}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  context,
                  icon: Icons.groups_outlined,
                  label: 'Event participants',
                  value: '$totalParticipants',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _statCard(
            context,
            icon: Icons.upcoming_outlined,
            label: 'Upcoming events',
            value: '$upcomingEvents',
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 104),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityBreakdown(BuildContext context, EnvironmentalImpact impact) {
    final activities = [
      (Icons.park_outlined, 'Tree plantation', impact.treePlantationActivities),
      (Icons.recycling, 'Recycling', impact.recyclingActivities),
      (Icons.cleaning_services_outlined, 'Cleanup', impact.cleanupActivities),
      (
        Icons.water_drop_outlined,
        'Water conservation',
        impact.waterConservationActivities,
      ),
    ];
    final maxActivities = activities.fold<int>(
      0,
      (maximum, activity) => activity.$3 > maximum ? activity.$3 : maximum,
    );
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          for (var index = 0; index < activities.length; index++) ...[
            if (index > 0) const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  activities[index].$1,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(activities[index].$2)),
                Text(
                  '${activities[index].$3}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: maxActivities == 0
                  ? 0
                  : activities[index].$3 / maxActivities,
              minHeight: 7,
              borderRadius: BorderRadius.circular(8),
              color: AppColors.primary,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ],
        ],
      ),
    );
  }
}
