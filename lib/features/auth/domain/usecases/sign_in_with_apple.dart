import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with Apple.
@injectable
class SignInWithApple implements UseCase<User, NoParams> {
  final AuthRepository repository;

  SignInWithApple(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.signInWithApple();
  }
}
