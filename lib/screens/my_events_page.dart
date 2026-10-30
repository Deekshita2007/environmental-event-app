import 'package:flutter/material.dart';

import '../models/event.dart';
import '../services/event_service.dart';
import '../utils/constants.dart';
import 'event_details_page.dart';

class MyEventsPage extends StatelessWidget {
  final EventService eventService;
  final String userId;
  final String userName;

  const MyEventsPage({
    super.key,
    required this.eventService,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final allJoinedEvents = eventService.getJoinedEvents(userId);
    final createdEvents = eventService.getCreatedEvents(userId);
    final attendingEvents = allJoinedEvents
        .where((event) => !event.date.isBefore(startOfToday))
        .toList();
    final pastEvents = <String, EnvironmentalEvent>{
      for (final event in [...allJoinedEvents, ...createdEvents])
        if (event.date.isBefore(startOfToday)) event.id: event,
    }.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Events',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _section(
            context,
            title: 'Events I’m attending',
            events: attendingEvents,
            status: 'JOINED',
            emptyMessage: 'Events you join will appear here.',
          ),
          const SizedBox(height: 28),
          _section(
            context,
            title: 'Events I Created',
            events: createdEvents,
            status: 'CREATED',
            emptyMessage: 'Events you create will appear here.',
          ),
          const SizedBox(height: 28),
          _section(
            context,
            title: 'Past Events',
            events: pastEvents,
            status: 'PAST',
            emptyMessage: 'Your completed event activities will appear here.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required List<EnvironmentalEvent> events,
    required String status,
    required String emptyMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (events.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              emptyMessage,
              style: const TextStyle(color: AppColors.textGrey),
            ),
          )
        else
          ...events.map((event) => _eventTile(context, event, status)),
      ],
    );
  }

  Widget _eventTile(
    BuildContext context,
    EnvironmentalEvent event,
    String status,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailsPage(
                event: event,
                eventService: eventService,
                userId: userId,
                userName: userName,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.eco, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${event.date.day} ${_monthName(event.date.month)}',
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      event.location,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                status,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }
}
