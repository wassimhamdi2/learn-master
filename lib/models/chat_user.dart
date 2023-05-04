class ChatUser {
  ChatUser({
    required this.photoUrl,
    required this.role,
    required this.username,
    // required this.createdAt,
    required this.isOnline,
    required this.uid,
    required this.lastActive,
    required this.email,
    required this.pushToken,
    required this.bio,
  });
  late String photoUrl;
  late String role;
  late String username;
  // late String createdAt;
  late bool isOnline;
  late String uid;
  late String lastActive;
  late String email;
  late String pushToken;
  late String bio;

  ChatUser.fromJson(Map<String, dynamic> json) {
    photoUrl = json['photoUrl'] ?? '';
    role = json['role'] ?? '';
    username = json['username'] ?? '';
    // createdAt = json['created_at'] ?? '';
    isOnline = json['is_online'] ?? '';
    uid = json['uid'] ?? '';
    lastActive = json['last_active'] ?? '';
    email = json['email'] ?? '';
    pushToken = json['push_token'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = photoUrl;
    data['about'] = role;
    data['name'] = username;
    // data['created_at'] = createdAt;
    data['is_online'] = isOnline;
    data['uid'] = uid;
    data['last_active'] = lastActive;
    data['email'] = email;
    data['push_token'] = pushToken;
    return data;
  }
}
