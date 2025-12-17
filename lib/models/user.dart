class User {
  String id;
  String name;
  String email;
  String password;
  String role; // buyer or seller

  User({required this.id, required this.name, required this.email, required this.password, required this.role});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      };

  @override
  String toString() => 'User{id: $id, name: $name, email: $email, role: $role}';
}
