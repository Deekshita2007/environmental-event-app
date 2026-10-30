import 'package:flutter/material.dart';

import '../services/event_service.dart';
import '../utils/constants.dart';
import '../widgets/event_card.dart';
import 'event_details_page.dart';

class FavoritesPage extends StatefulWidget {
  final EventService eventService;
  final String userId;
  final String userName;

  const FavoritesPage({
    super.key,
    required this.eventService,
    required this.userId,
    required this.userName,
  });

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    final favorites = widget.eventService.getFavoriteEvents(widget.userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: favorites.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No favorites yet',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Save events with the heart button to find them here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final event = favorites[index];

                return EventCard(
                  event: event,
                  isFavorite: true,
                  onFavoriteToggle: () {
                    setState(() {
                      widget.eventService.toggleFavorite(
                        event.id,
                        widget.userId,
                      );
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
                );
              },
            ),
    );
  }
}
