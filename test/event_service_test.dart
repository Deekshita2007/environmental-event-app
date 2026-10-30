import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/models/event.dart';
import 'package:flutter_application_1/services/event_service.dart';

void main() {
  test('provided November events show details and consume available slots', () {
    final eventService = EventService();
    final events = eventService.getEvents();

    expect(events, hasLength(7));
    final novemberEvents = events
        .where((event) => event.date.month == 11)
        .toList();
    expect(novemberEvents.map((event) => event.title), [
      'Green Earth Tree Plantation',
      'Clean Our Community',
      'Plastic-Free Campus',
      'Save Every Drop',
    ]);
    final treeEvent = events.singleWhere(
      (event) => event.id == 'green-earth-tree-plantation',
    );
    expect(treeEvent.date, DateTime(2026, 11, 5, 9));
    expect(treeEvent.endTime, DateTime(2026, 11, 5, 12));
    expect(treeEvent.location, 'Community Park');
    expect(treeEvent.organizer, 'Green Earth Volunteers');
    expect(treeEvent.availableSlots, 50);
    final cleanEvent = events.singleWhere(
      (event) => event.id == 'clean-our-community',
    );
    expect(cleanEvent.date, DateTime(2026, 11, 8, 8));
    expect(cleanEvent.endTime, DateTime(2026, 11, 8, 11));
    expect(cleanEvent.location, 'Community Center');
    expect(cleanEvent.organizer, 'EcoConnect Team');
    expect(cleanEvent.availableSlots, 30);
    final campusEvent = events.singleWhere(
      (event) => event.id == 'plastic-free-campus',
    );
    expect(campusEvent.date, DateTime(2026, 11, 12, 10));
    expect(campusEvent.endTime, DateTime(2026, 11, 12, 13));
    expect(campusEvent.location, 'College Campus');
    expect(campusEvent.organizer, 'EcoConnect Student Club');
    expect(campusEvent.availableSlots, 100);
    final waterEvent = events.singleWhere(
      (event) => event.id == 'save-every-drop',
    );
    expect(waterEvent.date, DateTime(2026, 11, 15, 9, 30));
    expect(waterEvent.endTime, DateTime(2026, 11, 15, 11, 30));
    expect(waterEvent.location, 'Community Hall');
    expect(waterEvent.organizer, 'Water Conservation Group');
    expect(waterEvent.availableSlots, 40);

    eventService.joinEvent(treeEvent.id, 'user-1');
    expect(treeEvent.availableSlots, 49);
    expect(treeEvent.participants, 1);
  });

  test('joining an event with no available slots is rejected', () {
    final eventService = EventService();
    final event = eventService.getEvents().singleWhere(
      (event) => event.id == 'green-earth-tree-plantation',
    );
    event.availableSlots = 0;

    eventService.joinEvent(event.id, 'user-1');

    expect(eventService.hasJoinedEvent(event.id, 'user-1'), isFalse);
    expect(event.participants, 0);
    expect(event.availableSlots, 0);
  });

  test('joined events are scoped to the user and counted once', () {
    final eventService = EventService();

    eventService.joinEvent('1', 'user-1');
    eventService.joinEvent('1', 'user-1');

    expect(eventService.getJoinedEvents('user-1').map((event) => event.id), [
      '1',
    ]);
    expect(eventService.getJoinedEvents('user-2'), isEmpty);
    expect(eventService.getEvents().first.participants, 43);
    expect(eventService.getEcoPoints('user-1'), 25);
  });

  test('favorites are scoped to the user and can be toggled off', () {
    final eventService = EventService();

    expect(eventService.toggleFavorite('1', 'user-1'), isTrue);
    expect(eventService.isFavorite('1', 'user-1'), isTrue);
    expect(eventService.isFavorite('1', 'user-2'), isFalse);
    expect(eventService.getFavoriteEvents('user-1').map((event) => event.id), [
      '1',
    ]);

    expect(eventService.toggleFavorite('1', 'user-1'), isFalse);
    expect(eventService.getFavoriteEvents('user-1'), isEmpty);
  });

  test('created events are scoped to their creator', () {
    final eventService = EventService();
    eventService.addEvent(
      EnvironmentalEvent(
        id: 'created-1',
        title: 'Community Garden',
        description: 'Plant a neighborhood garden.',
        location: 'Community Hall',
        date: DateTime(2026, 10, 20),
        category: '🌱 Organic Farming',
        organizer: 'Eco User',
        createdByUserId: 'user-1',
      ),
    );

    expect(eventService.getCreatedEvents('user-1').map((event) => event.id), [
      'created-1',
    ]);
    expect(eventService.getCreatedEvents('user-2'), isEmpty);
  });

  test('joined participants retain their name without duplicates', () {
    final eventService = EventService();

    eventService.joinEvent('1', 'user-1', userName: 'Avery Green');
    eventService.joinEvent('1', 'user-1', userName: 'Avery Green');

    final participants = eventService.getEventParticipants('1');
    expect(participants, hasLength(1));
    expect(participants.single.name, 'Avery Green');
    expect(eventService.getEvents().first.participants, 43);
  });

  test('creation and activity bonuses award eco points once', () {
    final eventService = EventService();
    final recyclingEvent = EnvironmentalEvent(
      id: 'recycling-1',
      title: 'Recycling Drive',
      description: 'Recycle together.',
      location: 'Community Hall',
      date: DateTime(2026, 10, 20),
      category: '♻️ Recycling Drive',
      organizer: 'Eco User',
      createdByUserId: 'user-1',
    );

    eventService.addEvent(recyclingEvent);
    eventService.addEvent(recyclingEvent);
    eventService.joinEvent('2', 'user-1');
    eventService.joinEvent('recycling-1', 'user-1');

    expect(eventService.getEcoPoints('user-1'), 70);
    expect(eventService.getEcoBadge('user-1'), 'Eco Beginner');
    expect(eventService.getNextEcoBadge('user-1'), 'Green Volunteer');
    expect(eventService.getPointsToNextBadge('user-1'), 30);
  });

  test('environmental impact summarizes joined activity categories', () {
    final eventService = EventService();

    eventService.joinEvent('1', 'user-1');
    eventService.joinEvent('2', 'user-1');
    eventService.joinEvent('3', 'user-1');

    final impact = eventService.getEnvironmentalImpact('user-1');
    expect(impact.treePlantationActivities, 1);
    expect(impact.recyclingActivities, 0);
    expect(impact.cleanupActivities, 1);
    expect(impact.waterConservationActivities, 0);
    expect(impact.peopleReached, 108);
    expect(eventService.getEnvironmentalImpact('user-2').peopleReached, 0);
  });

  test('pending events require approval and can be deleted', () {
    final eventService = EventService();
    final pendingEvent = EnvironmentalEvent(
      id: 'pending-1',
      title: 'Community Cleanup',
      description: 'Clean the local park.',
      location: 'City Park',
      date: DateTime(2026, 10, 20),
      category: '🧹 Clean-up Drive',
      organizer: 'Eco User',
      isApproved: false,
    );

    eventService.addEvent(pendingEvent);
    expect(
      eventService.getEvents().any((event) => event.id == 'pending-1'),
      isFalse,
    );
    eventService.joinEvent('pending-1', 'user-1');
    expect(eventService.hasJoinedEvent('pending-1', 'user-1'), isFalse);
    expect(eventService.approveEvent('pending-1'), isTrue);
    expect(
      eventService.getEvents().any((event) => event.id == 'pending-1'),
      isTrue,
    );
    expect(eventService.deleteEvent('pending-1'), isTrue);
    expect(eventService.deleteEvent('missing'), isFalse);
    expect(
      eventService.getAllEvents().any((event) => event.id == 'pending-1'),
      isFalse,
    );
  });
}
