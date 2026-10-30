class AppUser {
  final String id;
  final String name;
  final String email;
  final bool isAdmin;
  final String phoneNumber;
  final String location;
  final String? profileImagePath;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.isAdmin = false,
    this.phoneNumber = '',
    this.location = '',
    this.profileImagePath,
  });

  AppUser copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? location,
    String? profileImagePath,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      isAdmin: isAdmin,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}
