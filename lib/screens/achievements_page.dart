import 'package:flutter/material.dart';

import '../models/environmental_impact.dart';
import '../services/event_service.dart';
import '../utils/constants.dart';

class AchievementsPage extends StatelessWidget {
  final EventService eventService;
  final String userId;

  const AchievementsPage({
    super.key,
    required this.eventService,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final points = eventService.getEcoPoints(userId);
    final nextBadge = eventService.getNextEcoBadge(userId);
    final pointsToNext = eventService.getPointsToNextBadge(userId);
    final progress = eventService.getEcoBadgeProgress(userId);
    final impact = eventService.getEnvironmentalImpact(userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Achievements',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.darkGreen, AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.white, size: 30),
                    SizedBox(width: 10),
                    Text(
                      'Eco Score',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '$points points',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  eventService.getEcoBadge(userId),
                  style: const TextStyle(color: Colors.white),
                ),
                if (nextBadge != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Next: $nextBadge',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      Text(
                        '$pointsToNext pts to go',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  const Text(
                    'All badges earned. Keep making a difference!',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Badges',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _badge('🌱', 'Eco Beginner', 0, points),
          _badge('🌿', 'Green Volunteer', 100, points),
          _badge('🌳', 'Nature Protector', 250, points),
          _badge('🌎', 'Eco Champion', 500, points),
          const SizedBox(height: 18),
          const Text(
            'Environmental Impact',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _impactPanel(impact),
        ],
      ),
    );
  }

  Widget _badge(String icon, String title, int threshold, int points) {
    final earned = points >= threshold;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Text(icon, style: const TextStyle(fontSize: 24)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(earned ? 'Earned' : '$threshold points required'),
        trailing: Icon(
          earned ? Icons.check_circle : Icons.lock_outline,
          color: earned ? AppColors.primary : AppColors.textGrey,
        ),
      ),
    );
  }

  Widget _impactPanel(EnvironmentalImpact impact) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _impactRow(
            Icons.park_outlined,
            'Tree plantation activities',
            impact.treePlantationActivities,
          ),
          _impactRow(
            Icons.recycling,
            'Recycling activities',
            impact.recyclingActivities,
          ),
          _impactRow(
            Icons.cleaning_services_outlined,
            'Cleanup activities',
            impact.cleanupActivities,
          ),
          _impactRow(
            Icons.water_drop_outlined,
            'Water conservation activities',
            impact.waterConservationActivities,
          ),
          _impactRow(
            Icons.people_outline,
            'People reached',
            impact.peopleReached,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _impactRow(
    IconData icon,
    String label,
    int value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          const SizedBox(width: 8),
          Text(
            '$value',
            style: const TextStyle(
              color: AppColors.darkGreen,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
