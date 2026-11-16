class ProfileModel {
  final String name;
  final String email;
  final String? photoBase64;

  const ProfileModel({
    required this.name,
    required this.email,
    this.photoBase64,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      photoBase64: map['photoBase64'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'photoBase64': photoBase64};
  }

  ProfileModel copyWith({String? name, String? email, String? photoBase64}) {
    return ProfileModel(
      name: name ?? this.name,
      email: email ?? this.email,
      photoBase64: photoBase64 ?? this.photoBase64,
    );
  }
}
