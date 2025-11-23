part of 'events_bloc.dart';

/// Base class for all events-related events.
abstract class EventsEvent extends Equatable {
  const EventsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch upcoming events.
class FetchUpcomingEvents extends EventsEvent {
  const FetchUpcomingEvents();
}
