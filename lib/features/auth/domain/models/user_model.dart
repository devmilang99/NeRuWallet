class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? profilePicUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.profilePicUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      profilePicUrl: map['profilePicUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'profilePicUrl': profilePicUrl,
    };
  }
}
