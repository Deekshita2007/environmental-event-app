import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

class EditProfilePage extends StatefulWidget {
  final AuthService authService;
  final AppUser user;

  const EditProfilePage({
    super.key,
    required this.authService,
    required this.user,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;
  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _locationController = TextEditingController(text: widget.user.location);
    _selectedImagePath = widget.user.profileImagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _choosePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    try {
      final image = await _imagePicker.pickImage(source: source);
      if (image == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final extension = image.path.contains('.')
          ? image.path.substring(image.path.lastIndexOf('.'))
          : '.jpg';
      final destination = File(
        '${directory.path}${Platform.pathSeparator}'
        'profile_${widget.user.id.hashCode}_${DateTime.now().microsecondsSinceEpoch}$extension',
      );
      final savedImage = await File(image.path).copy(destination.path);
      if (!mounted) return;
      setState(() {
        _selectedImagePath = savedImage.path;
      });
    } on PlatformException catch (error) {
      if (mounted) {
        _showMessage(error.message ?? 'Could not select a profile photo');
      }
    } on FileSystemException {
      if (mounted) {
        _showMessage('Could not save the selected profile photo');
      }
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      _showMessage('Please enter your name');
      return;
    }
    if (!RegExp(
      r'^[A-Z0-9._%+-]+@gmail\.com$',
      caseSensitive: false,
    ).hasMatch(email)) {
      _showMessage('Please enter a valid Gmail address ending in @gmail.com');
      return;
    }

    try {
      final updated = await widget.authService.updateCurrentUser(
        name: name,
        email: email,
        phoneNumber: _phoneController.text,
        location: _locationController.text,
        profileImagePath: _selectedImagePath ?? '',
      );
      if (updated == ProfileUpdateResult.emailAlreadyInUse) {
        _showMessage('This email address is already in use');
        return;
      }
      if (updated == ProfileUpdateResult.invalidInput) {
        _showMessage('Please enter a valid name and email address');
        return;
      }
      if (!mounted) return;
      if (updated == ProfileUpdateResult.emailVerificationSent) {
        _emailController.text = widget.authService.currentUser!.email;
        _showMessage(
          'A verification email was sent. Confirm it before signing in with the new address.',
        );
        return;
      }
      Navigator.pop(context, true);
    } on FirebaseException catch (error) {
      _showMessage(
        error.code == 'email-already-in-use'
            ? 'This email address is already in use'
            : error.message ?? 'Could not save your profile',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                Semantics(
                  button: true,
                  label: 'Change profile photo',
                  child: InkWell(
                    onTap: _choosePhoto,
                    customBorder: const CircleBorder(),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          child: _selectedImagePath == null
                              ? Icon(
                                  Icons.eco,
                                  size: 44,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : ClipOval(
                                  child: Image.file(
                                    File(_selectedImagePath!),
                                    width: 96,
                                    height: 96,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                          Icons.eco,
                                          size: 44,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                  ),
                                ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary,
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 17,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap photo to change',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _field(_nameController, 'Name', Icons.person_outline),
          _field(
            _emailController,
            'Email',
            Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          _field(
            _phoneController,
            'Phone number',
            Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          _field(_locationController, 'Location', Icons.location_on_outlined),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _saveProfile,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save Profile'),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
