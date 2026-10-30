import 'package:flutter/material.dart';

import '../models/event.dart';
import '../services/event_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';

class CreateEventPage extends StatefulWidget {
  final EventService eventService;
  final String userId;

  const CreateEventPage({
    super.key,
    required this.eventService,
    required this.userId,
  });

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _organizerController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _category = '🌳 Tree Plantation';

  final List<String> _categories = [
    '🌳 Tree Plantation',
    '♻️ Recycling Drive',
    '🧹 Clean-up Drive',
    '💧 Water Conservation',
    '🌎 Climate Awareness',
    '🐦 Wildlife Protection',
    '🌱 Organic Farming',
    '🚲 Cycling / Green Transport',
    '🏖️ Beach Cleanup',
    '🌿 Biodiversity',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _organizerController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _createEvent() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      _showMessage('Please select an event date');
      return;
    }

    if (_selectedTime == null) {
      _showMessage('Please select an event time');
      return;
    }

    final eventDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final event = EnvironmentalEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
      date: eventDateTime,
      category: _category,
      organizer: _organizerController.text.trim(),
      createdByUserId: widget.userId,
      isApproved: false,
      participants: 0,
    );

    widget.eventService.addEvent(event);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event created successfully! 🌱')),
    );

    Navigator.pop(context);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Event',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.eco, color: AppColors.primary, size: 40),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      'Create an event and inspire others to protect our planet.',
                      style: TextStyle(
                        color: AppColors.darkGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            _label('Event Title'),

            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Example: Tree Plantation Drive',
                prefixIcon: Icon(Icons.event),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter event title';
                }
                return null;
              },
            ),

            const SizedBox(height: 18),

            _label('Description'),

            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe your environmental event',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 55),
                  child: Icon(Icons.description_outlined),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),

            const SizedBox(height: 18),

            _label('Location'),

            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: 'Example: City Park',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter location';
                }
                return null;
              },
            ),

            const SizedBox(height: 18),

            _label('Organizer'),

            TextFormField(
              controller: _organizerController,
              decoration: const InputDecoration(
                hintText: 'Organizer name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter organizer name';
                }
                return null;
              },
            ),

            const SizedBox(height: 18),

            _label('Category'),

            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _categories
                  .map(
                    (category) => DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _category = value;
                  });
                }
              },
            ),

            const SizedBox(height: 18),

            _label('Date'),

            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate == null
                          ? 'Select event date'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            _label('Time'),

            InkWell(
              onTap: _selectTime,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      _selectedTime == null
                          ? 'Select event time'
                          : _selectedTime!.format(context),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            CustomButton(
              text: 'CREATE EVENT',
              icon: Icons.add_circle_outline,
              onPressed: _createEvent,
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
