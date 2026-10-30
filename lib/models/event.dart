class EnvironmentalEvent {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime date;
  final DateTime? endTime;
  final String category;
  final String organizer;
  final String? createdByUserId;
  int? availableSlots;
  bool isApproved;
  int participants;

  EnvironmentalEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    this.endTime,
    required this.category,
    required this.organizer,
    this.createdByUserId,
    this.availableSlots,
    this.isApproved = true,
    this.participants = 0,
  });
}
