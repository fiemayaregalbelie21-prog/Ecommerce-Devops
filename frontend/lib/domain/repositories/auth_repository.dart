import '../entities/user.dart';

abstract class AuthRepository {
  User? getCurrentUser();
  Future<User> login({required String email, required String password});
  Future<User> continueAsGuest();
  Future<void> logout();
  bool get isLoggedIn;
}
