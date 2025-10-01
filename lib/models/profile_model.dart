class UserModel {
  final String uid;
  final String name;
  final String email;
  final String profileImageUrl;
  final String? college;
  final String? course;
  final String? address;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.profileImageUrl,
    this.college,
    this.course,
    this.address,
  });

  factory UserModel.fromMap(
    String uid,
    Map<String, dynamic> map,
  ) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      college: map['college'],
      course: map['course'],
      address: map['address'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'college': college,
      'course': course,
      'address': address,
    };
  }

  /// Creates a copy of UserModel with optional new values
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? profileImageUrl,
    String? college,
    String? course,
    String? address,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl:
          profileImageUrl ?? this.profileImageUrl,
      college: college ?? this.college,
      course: course ?? this.course,
      address: address ?? this.address,
    );
  }
}
