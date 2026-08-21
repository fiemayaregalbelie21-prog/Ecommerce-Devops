import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.email,
    required this.name,
    required this.isGuest,
  });

  final String email;
  final String name;
  final bool isGuest;

  @override
  List<Object?> get props => [email, name, isGuest];
}
