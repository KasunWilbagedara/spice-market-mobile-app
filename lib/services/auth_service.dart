import 'package:uuid/uuid.dart';
import '../models/user.dart';

class AuthService {
  final Map<String, User> _users = {};
  final uuid = Uuid();

  Future<User> register(String name, String email, String password, String role) async {
    final id = uuid.v4();
    final user = User(id: id, name: name, email: email, password: password, role: role);
    _users[email] = user;
    await Future.delayed(Duration(milliseconds: 300));
    return user;
  }

  Future<User?> login(String email, String password) async {
    await Future.delayed(Duration(milliseconds: 300));
    final user = _users[email];
    if (user != null && user.password == password) return user;
    return null;
  }
}
