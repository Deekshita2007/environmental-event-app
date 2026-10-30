import 'package:flutter/material.dart';

import '../models/event.dart';
import '../services/event_service.dart';
import '../utils/constants.dart';
import '../widgets/event_card.dart';
import 'event_details_page.dart';

class EventsPage extends StatefulWidget {
  final EventService eventService;
  final String userId;
  final String userName;

  const EventsPage({
    super.key,
    required this.eventService,
    required this.userId,
    required this.userName,
  });

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  static const _categories = [
    'All',
    'Trees',
    'Recycling',
    'Cleanup',
    'Water',
    'Climate',
    'Wildlife',
    'Organic Farming',
    'Green Transport',
    'Beach',
    'Biodiversity',
  ];

  String _search = '';
  String _selectedCategory = 'All';
  String _locationQuery = '';
  String? _nearbyArea;
  String _sortOrder = 'Upcoming';
  _DateFilter _dateFilter = _DateFilter.all;
  final TextEditingController _locationController = TextEditingController();

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _chooseNearbyArea() async {
    final controller = TextEditingController(text: _nearbyArea ?? '');
    final area = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Find events near an area'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            hintText: 'Enter a neighborhood or place',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (area == null) return;

    setState(() {
      _nearbyArea = area.isEmpty ? null : area;
      _locationQuery = area;
      _locationController.text = area;
    });
  }

  bool _matchesCategory(String category) {
    final value = category.toLowerCase();
    return switch (_selectedCategory) {
      'Trees' => value.contains('tree plantation'),
      'Recycling' => value.contains('recycling'),
      'Cleanup' => value.contains('cleanup') || value.contains('clean-up'),
      'Water' => value.contains('water conservation'),
      'Climate' => value.contains('climate') || value.contains('awareness'),
      'Wildlife' => value.contains('wildlife'),
      'Organic Farming' => value.contains('organic farming'),
      'Green Transport' =>
        value.contains('green transport') || value.contains('cycling'),
      'Beach' => value.contains('beach'),
      'Biodiversity' => value.contains('biodiversity'),
      _ => true,
    };
  }

  bool _matchesDate(DateTime date) {
    final eventDay = DateTime(date.year, date.month, date.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_dateFilter) {
      case _DateFilter.all:
        return true;
      case _DateFilter.today:
        return eventDay == today;
      case _DateFilter.thisWeek:
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        return !eventDay.isBefore(weekStart) &&
            eventDay.isBefore(weekStart.add(const Duration(days: 7)));
      case _DateFilter.thisMonth:
        return eventDay.year == today.year && eventDay.month == today.month;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allEvents = widget.eventService.getEvents();
    final filteredEvents = allEvents.where((event) {
      final search = _search.toLowerCase();
      final location = _locationQuery.toLowerCase();
      final matchesSearch =
          event.title.toLowerCase().contains(search) ||
          event.location.toLowerCase().contains(search) ||
          event.category.toLowerCase().contains(search) ||
          event.organizer.toLowerCase().contains(search);
      final matchesLocation =
          location.isEmpty || event.location.toLowerCase().contains(location);

      return matchesSearch &&
          matchesLocation &&
          _matchesCategory(event.category) &&
          _matchesDate(event.date);
    }).toList();

    switch (_sortOrder) {
      case 'Most participants':
        filteredEvents.sort(
          (first, second) => second.participants.compareTo(first.participants),
        );
      case 'Title A-Z':
        filteredEvents.sort(
          (first, second) => first.title.compareTo(second.title),
        );
      case 'Upcoming':
        filteredEvents.sort(
          (first, second) => first.date.compareTo(second.date),
        );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Environmental Events',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _search = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search events...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          _categoryFilters(),
          _dateFilters(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    onChanged: (value) {
                      setState(() {
                        _locationQuery = value.trim();
                        _nearbyArea = null;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Filter by location',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      suffixIcon: _locationQuery.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear location filter',
                              onPressed: () {
                                setState(() {
                                  _locationQuery = '';
                                  _nearbyArea = null;
                                  _locationController.clear();
                                });
                              },
                              icon: const Icon(Icons.close),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _chooseNearbyArea,
                  icon: Icon(
                    Icons.near_me_outlined,
                    color: _nearbyArea == null
                        ? null
                        : Theme.of(context).colorScheme.primary,
                  ),
                  label: const Text('Nearby'),
                ),
              ],
            ),
          ),
          if (_nearbyArea != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
              child: Text(
                'Matching place name: $_nearbyArea',
                style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Text(
                  'Sort',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _sortOrder,
                  items: const [
                    DropdownMenuItem(
                      value: 'Upcoming',
                      child: Text('Upcoming'),
                    ),
                    DropdownMenuItem(
                      value: 'Most participants',
                      child: Text('Most participants'),
                    ),
                    DropdownMenuItem(
                      value: 'Title A-Z',
                      child: Text('Title A-Z'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _sortOrder = value);
                  },
                ),
                const Spacer(),
                Text(
                  '${filteredEvents.length} events',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (filteredEvents.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 48),
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 56, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No events match these filters',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Try changing your search or filter selections.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else
            ...filteredEvents.map(_eventCard),
        ],
      ),
    );
  }

  Widget _categoryFilters() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final selected = category == _selectedCategory;

          return ChoiceChip(
            label: Text(category),
            selected: selected,
            selectedColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(
              color: selected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            onSelected: (_) => setState(() => _selectedCategory = category),
          );
        },
      ),
    );
  }

  Widget _dateFilters() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _DateFilter.values.map((filter) {
          final selected = _dateFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter.label),
              selected: selected,
              selectedColor: AppColors.lightGreen,
              labelStyle: TextStyle(
                color: selected
                    ? AppColors.darkGreen
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              onSelected: (_) => setState(() => _dateFilter = filter),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _eventCard(EnvironmentalEvent event) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: EventCard(
        event: event,
        isFavorite: widget.eventService.isFavorite(event.id, widget.userId),
        onFavoriteToggle: () {
          setState(() {
            widget.eventService.toggleFavorite(event.id, widget.userId);
          });
        },
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailsPage(
                event: event,
                eventService: widget.eventService,
                userId: widget.userId,
                userName: widget.userName,
              ),
            ),
          ).then((_) {
            if (mounted) setState(() {});
          });
        },
      ),
    );
  }
}

enum _DateFilter { all, today, thisWeek, thisMonth }

extension on _DateFilter {
  String get label => switch (this) {
    _DateFilter.all => 'Any date',
    _DateFilter.today => 'Today',
    _DateFilter.thisWeek => 'This Week',
    _DateFilter.thisMonth => 'This Month',
  };
}
