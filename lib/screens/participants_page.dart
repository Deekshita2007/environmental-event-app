import 'package:flutter/material.dart';

import '../models/event.dart';
import '../models/event_participant.dart';
import '../services/event_service.dart';
import '../utils/constants.dart';

class ParticipantsPage extends StatelessWidget {
  final EnvironmentalEvent event;
  final EventService eventService;

  const ParticipantsPage({
    super.key,
    required this.event,
    required this.eventService,
  });

  @override
  Widget build(BuildContext context) {
    final participants = eventService.getEventParticipants(event.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Participants',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            event.title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${event.participants} ${event.participants == 1 ? 'person' : 'people'} joined',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          if (participants.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Participant names will appear here when people join through the app. The total may include attendees whose details are not available.',
                style: TextStyle(color: AppColors.textGrey, height: 1.4),
              ),
            )
          else
            ...participants.map(_participantRow),
        ],
      ),
    );
  }

  Widget _participantRow(EventParticipant participant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.lightGreen,
            foregroundColor: AppColors.primary,
            child: Text(_initials(participant.name)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              participant.name,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';

    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }
}
