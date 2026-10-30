import 'package:flutter/material.dart';

import '../models/event.dart';
import '../services/event_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import 'participants_page.dart';

class EventDetailsPage extends StatefulWidget {
  final EnvironmentalEvent event;
  final EventService eventService;
  final String userId;
  final String userName;

  const EventDetailsPage({
    super.key,
    required this.event,
    required this.eventService,
    required this.userId,
    required this.userName,
  });

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  late bool _joined = widget.eventService.hasJoinedEvent(
    widget.event.id,
    widget.userId,
  );
  late bool _favorite = widget.eventService.isFavorite(
    widget.event.id,
    widget.userId,
  );

  void _joinEvent() {
    if (_joined || widget.event.availableSlots == 0) return;

    widget.eventService.joinEvent(
      widget.event.id,
      widget.userId,
      userName: widget.userName,
    );

    setState(() {
      _joined = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You have successfully joined this event! 🌱'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          IconButton(
            tooltip: _favorite ? 'Remove from favorites' : 'Save to favorites',
            onPressed: () {
              setState(() {
                _favorite = widget.eventService.toggleFavorite(
                  event.id,
                  widget.userId,
                );
              });
            },
            icon: Icon(
              _favorite ? Icons.favorite : Icons.favorite_border,
              color: _favorite ? Colors.red : Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 190,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.darkGreen, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Icon(Icons.eco, color: Colors.white, size: 90),
              ),
            ),

            const SizedBox(height: 25),

            Text(
              event.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                event.category,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 25),

            _infoRow(
              Icons.calendar_month_outlined,
              'Date',
              '${event.date.day}/${event.date.month}/${event.date.year}',
            ),

            _infoRow(
              Icons.access_time,
              'Time',
              _formatTimeRange(event.date, event.endTime),
            ),

            _infoRow(Icons.location_on_outlined, 'Location', event.location),

            _infoRow(Icons.person_outline, 'Organizer', event.organizer),

            if (event.availableSlots != null)
              _infoRow(
                Icons.event_seat_outlined,
                'Available slots',
                '${event.availableSlots}',
              ),

            _participantsSummary(context, event),

            const SizedBox(height: 20),

            const Text(
              'About this event',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              event.description,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 30),

            CustomButton(
              text: !event.isApproved
                  ? 'AWAITING APPROVAL'
                  : _joined
                  ? 'JOINED ✓'
                  : event.availableSlots == 0
                  ? 'EVENT FULL'
                  : 'JOIN EVENT',
              icon: !event.isApproved
                  ? Icons.hourglass_top
                  : _joined
                  ? Icons.check_circle
                  : event.availableSlots == 0
                  ? Icons.event_busy
                  : Icons.volunteer_activism,
              onPressed:
                  !event.isApproved || _joined || event.availableSlots == 0
                  ? () {}
                  : _joinEvent,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatTimeRange(DateTime start, DateTime? end) {
    String formatTime(DateTime time) {
      final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.hour < 12 ? 'AM' : 'PM';
      return '$hour:$minute $period';
    }

    return end == null
        ? formatTime(start)
        : '${formatTime(start)} - ${formatTime(end)}';
  }

  Widget _participantsSummary(BuildContext context, EnvironmentalEvent event) {
    final participants = widget.eventService.getEventParticipants(event.id);
    final avatarCount = event.participants < 5 ? event.participants : 5;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ParticipantsPage(
                event: event,
                eventService: widget.eventService,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.people_outline, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Participants',
                      style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 30,
                      child: Stack(
                        children: List.generate(avatarCount, (index) {
                          final participantName = index < participants.length
                              ? participants[index].name
                              : null;

                          return Positioned(
                            left: index * 22,
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: AppColors.lightGreen,
                              foregroundColor: AppColors.primary,
                              child: participantName == null
                                  ? const Icon(Icons.person, size: 17)
                                  : Text(
                                      participantName[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${event.participants} ${event.participants == 1 ? 'person' : 'people'} joined',
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textGrey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
