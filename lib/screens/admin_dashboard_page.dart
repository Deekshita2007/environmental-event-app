import 'package:flutter/material.dart';

import '../models/event.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../utils/constants.dart';
import 'participants_page.dart';

class AdminDashboardPage extends StatefulWidget {
  final AuthService authService;
  final EventService eventService;

  const AdminDashboardPage({
    super.key,
    required this.authService,
    required this.eventService,
  });

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Admin Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.event_note), text: 'Manage Events'),
              Tab(icon: Icon(Icons.people_outline), text: 'Manage Users'),
              Tab(icon: Icon(Icons.bar_chart), text: 'Reports'),
            ],
          ),
        ),
        body: TabBarView(children: [_eventsTab(), _usersTab(), _reportsTab()]),
      ),
    );
  }

  Widget _eventsTab() {
    final events = widget.eventService.getAllEvents();

    if (events.isEmpty) {
      return const Center(child: Text('No events to manage.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) => _eventRow(events[index]),
    );
  }

  Widget _eventRow(EnvironmentalEvent event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _statusLabel(event.isApproved ? 'APPROVED' : 'PENDING'),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${event.category} · ${event.organizer}',
            style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            '${event.date.day}/${event.date.month}/${event.date.year} · ${event.location}',
            style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (!event.isApproved)
                TextButton.icon(
                  onPressed: () {
                    setState(() => widget.eventService.approveEvent(event.id));
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Approve'),
                ),
              TextButton.icon(
                onPressed: () => _openParticipants(event),
                icon: const Icon(Icons.people_outline, size: 18),
                label: Text('${event.participants} Participants'),
              ),
              TextButton.icon(
                onPressed: () => _confirmDelete(event),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                ),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusLabel(String label) {
    final isApproved = label != 'PENDING';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isApproved ? AppColors.lightGreen : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isApproved ? AppColors.darkGreen : const Color(0xFF9A5700),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _openParticipants(EnvironmentalEvent event) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ParticipantsPage(event: event, eventService: widget.eventService),
      ),
    );
  }

  Future<void> _confirmDelete(EnvironmentalEvent event) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete event?'),
        content: Text('“${event.title}” will be removed from the event list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      setState(() => widget.eventService.deleteEvent(event.id));
    }
  }

  Widget _usersTab() {
    final users = widget.authService.getUsers();

    if (users.isEmpty) {
      return const Center(child: Text('No users have registered yet.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _userRow(users[index]),
    );
  }

  Widget _userRow(AppUser user) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.lightGreen,
            foregroundColor: AppColors.primary,
            child: Text(_initials(user.name)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  user.email,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (user.isAdmin) _statusLabel('ADMIN'),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    return parts.take(2).map((part) => part[0].toUpperCase()).join();
  }

  Widget _reportsTab() {
    final events = widget.eventService.getAllEvents();
    final activeEvents = events
        .where(
          (event) => event.isApproved && event.date.isAfter(DateTime.now()),
        )
        .length;
    final participantTotal = events.fold<int>(
      0,
      (total, event) => total + event.participants,
    );
    final pendingEvents = events.where((event) => !event.isApproved).length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Platform Overview',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _statTile('Total Users', '${widget.authService.getUsers().length}'),
            _statTile('Total Events', '${events.length}'),
            _statTile('Active Events', '$activeEvents'),
            _statTile('Participants', '$participantTotal'),
            _statTile('Pending Approval', '$pendingEvents'),
          ],
        ),
      ],
    );
  }

  Widget _statTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.darkGreen,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.textGrey)),
        ],
      ),
    );
  }
}
