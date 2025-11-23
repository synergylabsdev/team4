import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case for checking if user profile is complete.
@injectable
class IsProfileComplete implements UseCase<bool, NoParams> {
  final AuthRepository repository;

  IsProfileComplete(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.isProfileComplete();
  }
}

