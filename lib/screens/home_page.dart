import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/app_preferences.dart';
import '../services/event_service.dart';
import '../utils/constants.dart';
import 'create_event_page.dart';
import 'events_page.dart';
import 'event_details_page.dart';
import 'environmental_awareness_page.dart';
import 'my_events_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';
import 'achievements_page.dart';
import 'favorites_page.dart';
import 'settings_page.dart';
import 'statistics_page.dart';

class HomePage extends StatefulWidget {
  final AuthService authService;
  final AppPreferences preferences;

  const HomePage({
    super.key,
    required this.authService,
    required this.preferences,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final EventService _eventService = EventService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    widget.preferences.addListener(_onPreferencesChanged);
  }

  @override
  void dispose() {
    widget.preferences.removeListener(_onPreferencesChanged);
    super.dispose();
  }

  void _onPreferencesChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: _getSelectedPage(),
      endDrawer: _buildHomeMenu(),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Events',
          ),
          const NavigationDestination(
            icon: Icon(Icons.event_available_outlined),
            selectedIcon: Icon(Icons.event_available),
            label: 'My Events',
          ),
          const NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),

      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Create Event'),
              onPressed: _openCreateEvent,
            )
          : null,
    );
  }

  Widget _buildHomeMenu() {
    final user = widget.authService.currentUser;
    final userName = user?.name ?? 'Eco User';

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              accountName: Text(userName),
              accountEmail: Text(user?.email ?? ''),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Account & Full Profile'),
              subtitle: const Text('Profile details and account options'),
              onTap: () => _selectDrawerDestination(4),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.event_available_outlined),
              title: const Text('Activities'),
              subtitle: const Text('My events'),
              onTap: () => _selectDrawerDestination(2),
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text('Favorites'),
              onTap: () => _openDrawerPage(
                FavoritesPage(
                  eventService: _eventService,
                  userId: user?.id ?? '',
                  userName: userName,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events_outlined),
              title: const Text('Achievements'),
              onTap: () => _openDrawerPage(
                AchievementsPage(
                  eventService: _eventService,
                  userId: user?.id ?? '',
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart_outlined),
              title: const Text('Statistics'),
              onTap: () => _openDrawerPage(
                StatisticsPage(
                  eventService: _eventService,
                  userId: user?.id ?? '',
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              onTap: () => _selectDrawerDestination(3),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () => _openDrawerPage(
                SettingsPage(preferences: widget.preferences),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDrawerDestination(int index) {
    Navigator.of(context).pop();
    setState(() => _selectedIndex = index);
  }

  void _openDrawerPage(Widget page) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  Future<void> _openCreateEvent() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEventPage(
          eventService: _eventService,
          userId: widget.authService.currentUser?.id ?? '',
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 1:
        return EventsPage(
          eventService: _eventService,
          userId: widget.authService.currentUser?.id ?? '',
          userName: widget.authService.currentUser?.name ?? 'Eco User',
        );

      case 2:
        return MyEventsPage(
          eventService: _eventService,
          userId: widget.authService.currentUser?.id ?? '',
          userName: widget.authService.currentUser?.name ?? 'Eco User',
        );

      case 3:
        return NotificationsPage(
          enabled: widget.preferences.notificationsEnabled,
        );

      case 4:
        return ProfilePage(
          authService: widget.authService,
          preferences: widget.preferences,
          eventService: _eventService,
        );

      case 0:
      default:
        return _homeContent();
    }
  }

  Widget _homeContent() {
    final userName = widget.authService.currentUser?.name ?? 'Eco User';
    final userId = widget.authService.currentUser?.id ?? '';

    final events = _eventService.getEvents();
    final joinedEvents = _eventService.getJoinedEvents(userId);
    final totalParticipants = events.fold<int>(
      0,
      (total, event) => total + event.participants,
    );
    final upcomingEvents =
        events.where((event) => event.date.isAfter(DateTime.now())).toList()
          ..sort((first, second) => first.date.compareTo(second.date));

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            // ------------------------------------------------
            // HEADER
            // ------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello 👋',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userName,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  tooltip: 'Open menu',
                  onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                  icon: const Icon(Icons.menu),
                  color: Theme.of(context).colorScheme.primary,
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.lightGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: AppColors.primary),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ------------------------------------------------
            // IMPACT BANNER
            // ------------------------------------------------
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.darkGreen, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.public, color: Colors.white, size: 42),
                  SizedBox(height: 15),
                  Text(
                    'Make a difference today',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Join environmental events and help build a cleaner, greener planet.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _quickAction(
                    icon: Icons.search,
                    label: 'Find Events',
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _quickAction(
                    icon: Icons.add_circle_outline,
                    label: 'Create Event',
                    onTap: _openCreateEvent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _quickAction(
                    icon: Icons.event_available_outlined,
                    label: 'My Events',
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ------------------------------------------------
            // YOUR IMPACT
            // ------------------------------------------------
            Text(
              'Your Impact',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            LayoutBuilder(
              builder: (context, constraints) {
                return GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: constraints.maxWidth > 900 ? 4.5 : 2.25,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _statCard(
                      icon: Icons.event,
                      value: '${events.length}',
                      title: 'Total Events',
                    ),
                    _statCard(
                      icon: Icons.event_available,
                      value: '${joinedEvents.length}',
                      title: 'Events Joined',
                    ),
                    _statCard(
                      icon: Icons.people_outline,
                      value: '$totalParticipants',
                      title: 'Participants',
                    ),
                    _statCard(
                      icon: Icons.eco,
                      value: '🌱',
                      title: 'Environmental Impact',
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),

            // ------------------------------------------------
            // UPCOMING EVENTS HEADER
            // ------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Events',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ------------------------------------------------
            // EVENTS
            // ------------------------------------------------
            if (upcomingEvents.isEmpty)
              _emptyEventsCard()
            else
              ...upcomingEvents.take(3).map((event) {
                return _homeEventCard(event);
              }),

            if (widget.preferences.ecoTipsEnabled) ...[
              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Environmental Tips 🌿',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EnvironmentalAwarenessPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.menu_book_outlined, size: 18),
                    label: const Text('Explore topics'),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _tipCard(
                imagePath: 'assets/environmental_tips/reduce_plastic.jpg',
                title: 'Reduce Plastic',
                description: 'Use reusable bags and bottles instead of single-use plastic.',
              ),

              _tipCard(
                imagePath: 'assets/environmental_tips/green_transport.jpg',
                title: 'Choose Green Transport',
                description:
                    'Walk, cycle or use public transport whenever possible.',
              ),

              _tipCard(
                imagePath: 'assets/environmental_tips/save_water.jpg',
                title: 'Save Water',
                description: 'Turn off taps when water is not needed.',
              ),

              _tipCard(
                imagePath: 'assets/environmental_tips/save_energy.jpg',
                title: 'Save Energy',
                description: 'Switch off lights and electrical appliances when not in use.',
              ),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------
  // STAT CARD
  // ------------------------------------------------
  Widget _quickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 76,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 23),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 21),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------
  // EVENT CARD FOR HOME PAGE
  // ------------------------------------------------
  Widget _homeEventCard(dynamic event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return EventDetailsPage(
                  event: event,
                  eventService: _eventService,
                  userId: widget.authService.currentUser?.id ?? '',
                  userName: widget.authService.currentUser?.name ?? 'Eco User',
                );
              },
            ),
          ).then((_) {
            if (mounted) {
              setState(() {});
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  AppAssets.eventCard,
                  width: 58,
                  height: 58,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: AppColors.textGrey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${event.date.day}/${event.date.month}/${event.date.year}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------
  // EMPTY EVENTS
  // ------------------------------------------------
  Widget _emptyEventsCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(Icons.event_busy, size: 50, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            'No upcoming events',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            'Create an environmental event to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------
  // ENVIRONMENTAL TIP CARD
  // ------------------------------------------------
  Widget _tipCard({
    required String imagePath,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              width: 82,
              height: 82,
              fit: BoxFit.cover,
              semanticLabel: title,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                    height: 1.4,
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
