import '../../repositories/auth_repository.dart';

class ContinueAsGuestUseCase {
  ContinueAsGuestUseCase(this._repository);

  final AuthRepository _repository;

  Future call() {
    return _repository.continueAsGuest();
  }
}
