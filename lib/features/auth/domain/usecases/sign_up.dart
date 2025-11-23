import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing up a new user.
@injectable
class SignUp implements UseCase<User, SignUpParams> {
  final AuthRepository repository;

  SignUp(this.repository);

  @override
  Future<Either<Failure, User>> call(SignUpParams params) async {
    return await repository.signUp(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
      role: params.role,
    );
  }
}

/// Parameters for sign up use case.
class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String displayName;
  final String role;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.displayName,
    this.role = 'attendee',
  });

  @override
  List<Object?> get props => [email, password, displayName, role];
}
