import '../../core/storage/hive_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthLocalDataSource implements AuthRepository {
  static const _emailKey = 'email';
  static const _nameKey = 'name';
  static const _guestKey = 'isGuest';
  static const _loggedInKey = 'isLoggedIn';

  @override
  User? getCurrentUser() {
    if (!isLoggedIn) return null;
    return User(
      email: HiveService.authBox.get(_emailKey, defaultValue: '') as String,
      name: HiveService.authBox.get(_nameKey, defaultValue: 'Guest') as String,
      isGuest: HiveService.authBox.get(_guestKey, defaultValue: false) as bool,
    );
  }

  @override
  bool get isLoggedIn =>
      HiveService.authBox.get(_loggedInKey, defaultValue: false) as bool;

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.length < 4) {
      throw AuthException('Enter a valid email and password (min 4 chars).');
    }

    final user = User(
      email: email,
      name: email.split('@').first,
      isGuest: false,
    );
    await saveUser(user);
    return user;
  }

  @override
  Future<User> continueAsGuest() async {
    const user = User(
      email: 'guest@feva.com',
      name: 'Guest',
      isGuest: true,
    );
    await saveUser(user);
    return user;
  }

  @override
  Future<void> logout() async {
    await deleteUser();
  }

  Future<void> saveUser(User user) async {
    await HiveService.authBox.putAll({
      _loggedInKey: true,
      _emailKey: user.email,
      _nameKey: user.name,
      _guestKey: user.isGuest,
    });
  }

  Future<void> deleteUser() async {
    await HiveService.authBox.put(_loggedInKey, false);
  }
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
