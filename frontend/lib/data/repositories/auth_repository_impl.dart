import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this.dataSource);

  final AuthLocalDataSource dataSource;

  @override
  User? getCurrentUser() => dataSource.getCurrentUser();

  @override
  bool get isLoggedIn => dataSource.isLoggedIn;

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
    await dataSource.saveUser(user);
    return user;
  }

  @override
  Future<User> continueAsGuest() async {
    const user = User(
      email: 'guest@feva.com',
      name: 'Guest',
      isGuest: true,
    );
    await dataSource.saveUser(user);
    return user;
  }

  @override
  Future<void> logout() async {
    await dataSource.deleteUser();
  }
}