part of 'events_bloc.dart';

/// Base class for all events-related states.
abstract class EventsState extends Equatable {
  const EventsState();

  @override
  List<Object?> get props => [];
}

/// Initial state when events haven't been loaded yet.
class EventsInitial extends EventsState {
  const EventsInitial();
}

/// State when events are being loaded.
class EventsLoading extends EventsState {
  const EventsLoading();
}

/// State when events have been loaded successfully.
class EventsLoaded extends EventsState {
  final List<Event> events;

  const EventsLoaded(this.events);

  @override
  List<Object?> get props => [events];
}

/// State when an error occurred while loading events.
class EventsError extends EventsState {
  final String message;

  const EventsError(this.message);

  @override
  List<Object?> get props => [message];
}
