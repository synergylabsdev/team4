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
  final String role;

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.displayName,
    this.role = 'attendee',
  });

  @override
  List<Object?> get props => [email, password, displayName, role];
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class UpdateProfileRequested extends AuthEvent {
  final String? displayName;
  final String? photoUrl;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? bio;
  final String? contactEmail;
  final String? website;

  const UpdateProfileRequested({
    this.displayName,
    this.photoUrl,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.city,
    this.state,
    this.zipCode,
    this.bio,
    this.contactEmail,
    this.website,
  });

  @override
  List<Object?> get props => [
        displayName,
        photoUrl,
        firstName,
        lastName,
        phoneNumber,
        city,
        state,
        zipCode,
        bio,
        contactEmail,
        website,
      ];
}

class ConnectStripeAccountRequested extends AuthEvent {
  final String stripeAccountId;

  const ConnectStripeAccountRequested({
    required this.stripeAccountId,
  });

  @override
  List<Object?> get props => [stripeAccountId];
}

