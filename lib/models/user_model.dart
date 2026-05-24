class User {
  final int id;
  final String name;
  final String email;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      token: token ?? json['token'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'token': token,
      };
}
