import '../models/event.dart';
import '../models/event_participant.dart';
import '../models/environmental_impact.dart';

class EventService {
  static const Map<int, String> _ecoBadges = {
    0: 'Eco Beginner',
    100: 'Green Volunteer',
    250: 'Nature Protector',
    500: 'Eco Champion',
  };

  final Map<String, Set<String>> _joinedEventIdsByUser = {};
  final Map<String, Set<String>> _favoriteEventIdsByUser = {};
  final Map<String, Map<String, EventParticipant>> _participantsByEvent = {};
  final Map<String, int> _ecoPointsByUser = {};

  final List<EnvironmentalEvent> _events = [
    EnvironmentalEvent(
      id: '1',
      title: 'Beach Cleanup Drive',
      description: 'Join us to clean the beach and help protect marine life from plastic pollution.',
      location: 'RK Beach',
      date: DateTime(2026, 10, 5, 8, 0),
      category: '🏖️ Beach Cleanup',
      organizer: 'Eco Warriors',
      participants: 42,
    ),
    EnvironmentalEvent(
      id: '2',
      title: 'Tree Plantation Drive',
      description: 'Plant trees in our local community and contribute to a greener future.',
      location: 'City Park',
      date: DateTime(2026, 10, 12, 9, 0),
      category: '🌳 Tree Plantation',
      organizer: 'Green Earth',
      participants: 28,
    ),
    EnvironmentalEvent(
      id: '3',
      title: 'Plastic-Free Awareness',
      description: 'Learn how reducing single-use plastics can make a difference to our environment.',
      location: 'Community Hall',
      date: DateTime(2026, 10, 18, 10, 0),
      category: '🌎 Climate Awareness',
      organizer: 'EcoConnect',
      participants: 35,
    ),
    EnvironmentalEvent(
      id: 'green-earth-tree-plantation',
      title: 'Green Earth Tree Plantation',
      description:
          'Join us to plant saplings and help create a greener environment.',
      location: 'Community Park',
      date: DateTime(2026, 11, 5, 9),
      endTime: DateTime(2026, 11, 5, 12),
      category: '🌳 Tree Plantation',
      organizer: 'Green Earth Volunteers',
      availableSlots: 50,
    ),
    EnvironmentalEvent(
      id: 'clean-our-community',
      title: 'Clean Our Community',
      description: 'Help clean public spaces and spread awareness about waste management.',
      location: 'Community Center',
      date: DateTime(2026, 11, 8, 8),
      endTime: DateTime(2026, 11, 8, 11),
      category: '🧹 Clean-up Drive',
      organizer: 'EcoConnect Team',
      availableSlots: 30,
    ),
    EnvironmentalEvent(
      id: 'plastic-free-campus',
      title: 'Plastic-Free Campus',
      description: 'Join our campaign to reduce single-use plastics and promote reusable alternatives.',
      location: 'College Campus',
      date: DateTime(2026, 11, 12, 10),
      endTime: DateTime(2026, 11, 12, 13),
      category: '🌎 Climate Awareness',
      organizer: 'EcoConnect Student Club',
      availableSlots: 100,
    ),
    EnvironmentalEvent(
      id: 'save-every-drop',
      title: 'Save Every Drop',
      description:
          'Discover simple ways to conserve water at home, college, and work.',
      location: 'Community Hall',
      date: DateTime(2026, 11, 15, 9, 30),
      endTime: DateTime(2026, 11, 15, 11, 30),
      category: '💧 Water Conservation',
      organizer: 'Water Conservation Group',
      availableSlots: 40,
    ),
  ];

  List<EnvironmentalEvent> getEvents() {
    return List.unmodifiable(_events.where((event) => event.isApproved));
  }

  List<EnvironmentalEvent> getAllEvents() {
    return List.unmodifiable(_events);
  }

  bool approveEvent(String eventId) {
    final index = _events.indexWhere((event) => event.id == eventId);
    if (index == -1) return false;

    _events[index].isApproved = true;
    return true;
  }

  bool deleteEvent(String eventId) {
    final exists = _events.any((event) => event.id == eventId);
    if (!exists) return false;

    _events.removeWhere((event) => event.id == eventId);

    _participantsByEvent.remove(eventId);
    for (final joinedIds in _joinedEventIdsByUser.values) {
      joinedIds.remove(eventId);
    }
    for (final favoriteIds in _favoriteEventIdsByUser.values) {
      favoriteIds.remove(eventId);
    }
    return true;
  }

  void addEvent(EnvironmentalEvent event) {
    if (_events.any((existingEvent) => existingEvent.id == event.id)) return;

    _events.add(event);
    final creatorId = event.createdByUserId;
    if (creatorId != null) {
      _awardPoints(creatorId, 20);
    }
  }

  List<EnvironmentalEvent> getJoinedEvents(String userId) {
    final joinedEventIds = _joinedEventIdsByUser[userId] ?? <String>{};

    return List.unmodifiable(
      _events.where((event) => joinedEventIds.contains(event.id)),
    );
  }

  EnvironmentalImpact getEnvironmentalImpact(String userId) {
    final joinedEvents = getJoinedEvents(userId);

    return EnvironmentalImpact(
      treePlantationActivities: _countCategory(joinedEvents, 'tree plantation'),
      recyclingActivities: _countCategory(joinedEvents, 'recycling'),
      cleanupActivities: joinedEvents.where((event) {
        final category = event.category.toLowerCase();
        return category.contains('clean-up') || category.contains('cleanup');
      }).length,
      waterConservationActivities: _countCategory(
        joinedEvents,
        'water conservation',
      ),
      peopleReached: joinedEvents.fold<int>(
        0,
        (total, event) => total + event.participants,
      ),
    );
  }

  int _countCategory(List<EnvironmentalEvent> events, String category) {
    return events
        .where((event) => event.category.toLowerCase().contains(category))
        .length;
  }

  List<EnvironmentalEvent> getCreatedEvents(String userId) {
    return List.unmodifiable(
      _events.where((event) => event.createdByUserId == userId),
    );
  }

  bool hasJoinedEvent(String eventId, String userId) {
    return _joinedEventIdsByUser[userId]?.contains(eventId) ?? false;
  }

  List<EventParticipant> getEventParticipants(String eventId) {
    final participants =
        _participantsByEvent[eventId]?.values ??
        const Iterable<EventParticipant>.empty();

    return List.unmodifiable(participants);
  }

  void joinEvent(
    String eventId,
    String userId, {
    String userName = 'Eco User',
  }) {
    final index = _events.indexWhere((event) => event.id == eventId);

    if (index == -1 ||
        !_events[index].isApproved ||
        hasJoinedEvent(eventId, userId) ||
        _events[index].availableSlots == 0) {
      return;
    }

    _joinedEventIdsByUser.putIfAbsent(userId, () => <String>{}).add(eventId);
    _participantsByEvent.putIfAbsent(
      eventId,
      () => <String, EventParticipant>{},
    )[userId] = EventParticipant(
      userId: userId,
      name: userName,
    );
    _events[index].participants++;
    if (_events[index].availableSlots != null) {
      _events[index].availableSlots = _events[index].availableSlots! - 1;
    }
    _awardPoints(userId, _activityPoints(_events[index].category));
  }

  int getEcoPoints(String userId) => _ecoPointsByUser[userId] ?? 0;

  String getEcoBadge(String userId) {
    final points = getEcoPoints(userId);
    final threshold = _ecoBadges.keys.lastWhere((value) => points >= value);
    return _ecoBadges[threshold]!;
  }

  String? getNextEcoBadge(String userId) {
    final points = getEcoPoints(userId);
    for (final entry in _ecoBadges.entries) {
      if (entry.key > points) return entry.value;
    }
    return null;
  }

  int getPointsToNextBadge(String userId) {
    final points = getEcoPoints(userId);
    for (final threshold in _ecoBadges.keys) {
      if (threshold > points) return threshold - points;
    }
    return 0;
  }

  double getEcoBadgeProgress(String userId) {
    final points = getEcoPoints(userId);
    final currentThreshold = _ecoBadges.keys.lastWhere(
      (value) => points >= value,
    );
    final nextThreshold = _ecoBadges.keys.cast<int?>().firstWhere(
      (value) => value != null && value > points,
      orElse: () => null,
    );

    if (nextThreshold == null) return 1;

    return (points - currentThreshold) / (nextThreshold - currentThreshold);
  }

  void _awardPoints(String userId, int points) {
    _ecoPointsByUser.update(
      userId,
      (currentPoints) => currentPoints + points,
      ifAbsent: () => points,
    );
  }

  int _activityPoints(String category) {
    final normalizedCategory = category.toLowerCase();
    if (normalizedCategory.contains('tree plantation')) return 30;
    if (normalizedCategory.contains('recycling')) return 20;
    if (normalizedCategory.contains('clean-up') ||
        normalizedCategory.contains('cleanup')) {
      return 25;
    }
    return 10;
  }

  List<EnvironmentalEvent> getFavoriteEvents(String userId) {
    final favoriteEventIds = _favoriteEventIdsByUser[userId] ?? <String>{};

    return List.unmodifiable(
      _events.where((event) => favoriteEventIds.contains(event.id)),
    );
  }

  bool isFavorite(String eventId, String userId) {
    return _favoriteEventIdsByUser[userId]?.contains(eventId) ?? false;
  }

  bool toggleFavorite(String eventId, String userId) {
    if (!_events.any((event) => event.id == eventId)) return false;

    final favoriteEventIds = _favoriteEventIdsByUser.putIfAbsent(
      userId,
      () => <String>{},
    );

    if (!favoriteEventIds.add(eventId)) {
      favoriteEventIds.remove(eventId);
      return false;
    }

    return true;
  }
}
