import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/event.dart';
import '../../domain/usecases/get_upcoming_events.dart';

part 'events_event.dart';
part 'events_state.dart';

/// BLoC for managing events state.
@injectable
class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final GetUpcomingEvents getUpcomingEvents;

  EventsBloc(this.getUpcomingEvents) : super(const EventsInitial()) {
    on<FetchUpcomingEvents>(_onFetchUpcomingEvents);
    
    // Automatically fetch events when bloc is created
    add(const FetchUpcomingEvents());
  }

  /// Listen to upcoming events stream and emit states accordingly.
  Future<void> _onFetchUpcomingEvents(
    FetchUpcomingEvents event,
    Emitter<EventsState> emit,
  ) async {
    emit(const EventsLoading());

    await emit.forEach<Either<Failure, List<Event>>>(
      getUpcomingEvents(NoParams()),
      onData: (Either<Failure, List<Event>> result) {
        return result.fold(
          (failure) => EventsError(failure.message),
          (events) => EventsLoaded(events),
        );
      },
      onError: (error, stackTrace) {
        return EventsError('An unexpected error occurred: ${error.toString()}');
      },
    );
  }
}
