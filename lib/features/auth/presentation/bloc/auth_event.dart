part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class UpdateProfileRequested extends AuthEvent {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? city;
  final String? state;
  final String? zipCode;

  const UpdateProfileRequested({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.city,
    this.state,
    this.zipCode,
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        phoneNumber,
        city,
        state,
        zipCode,
      ];
}

