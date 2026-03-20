class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? profilePicUrl;
  final bool isNewUser;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.profilePicUrl,
    this.isNewUser = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      profilePicUrl: map['profilePicUrl'],
      isNewUser: map['isNewUser'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'profilePicUrl': profilePicUrl,
      'isNewUser': isNewUser,
    };
  }
}
