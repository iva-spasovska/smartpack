class AppUser {
  final int id;
  final String username;
  final String email;
  final String? gender;
  final String? dateOfBirth;
  final int? age;
  final String? profilePhotoUrl;

  AppUser({
    required this.id,
    required this.username,
    required this.email,
    this.gender,
    this.dateOfBirth,
    this.age,
    this.profilePhotoUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
      age: json['age'],
      profilePhotoUrl: json['profile_photo_url'],
    );
  }
}
