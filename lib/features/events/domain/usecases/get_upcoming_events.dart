import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/event.dart';
import '../repositories/event_repository.dart';

/// Base interface for stream use cases.
abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

/// Use case for getting upcoming published events.
@injectable
class GetUpcomingEvents implements StreamUseCase<List<Event>, NoParams> {
  final EventRepository repository;

  GetUpcomingEvents(this.repository);

  @override
  Stream<Either<Failure, List<Event>>> call(NoParams params) {
    return repository.getUpcomingEvents();
  }
}
