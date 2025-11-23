import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/event_model.dart';

/// Remote data source for events operations using Firebase Firestore.
abstract class EventRemoteDataSource {
  /// Get upcoming published events.
  Stream<List<EventModel>> getUpcomingEvents();

  /// Get event by ID.
  Future<EventModel> getEventById(String eventId);

  /// Get events by organization ID.
  Stream<List<EventModel>> getEventsByOrganization(String orgId);

  /// Create a new event.
  Future<EventModel> createEvent(EventModel event);
}

@LazySingleton(as: EventRemoteDataSource)
class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final FirebaseFirestore _firestore;

  EventRemoteDataSourceImpl(this._firestore);

  @override
  Stream<List<EventModel>> getUpcomingEvents() {
    try {
      final now = DateTime.now();
      return _firestore
          .collection(AppConstants.eventsCollection)
          .where('status', isEqualTo: AppConstants.eventStatusPublished)
          .where('startAt', isGreaterThan: Timestamp.fromDate(now))
          .orderBy('startAt', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => EventModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw ServerException('Failed to fetch upcoming events: ${e.toString()}');
    }
  }

  @override
  Future<EventModel> getEventById(String eventId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId)
          .get();

      if (!doc.exists) {
        throw NotFoundException('Event not found: $eventId');
      }

      return EventModel.fromFirestore(doc);
    } catch (e) {
      if (e is NotFoundException) {
        rethrow;
      }
      throw ServerException('Failed to fetch event: ${e.toString()}');
    }
  }

  @override
  Stream<List<EventModel>> getEventsByOrganization(String orgId) {
    try {
      return _firestore
          .collection(AppConstants.eventsCollection)
          .where('orgId', isEqualTo: orgId)
          .orderBy('startAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => EventModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw ServerException(
          'Failed to fetch organization events: ${e.toString()}');
    }
  }

  @override
  Future<EventModel> createEvent(EventModel event) async {
    try {
      final eventJson = event.toJson();
      // Remove id from JSON as Firestore will generate it
      eventJson.remove('id');
      
      final docRef = await _firestore
          .collection(AppConstants.eventsCollection)
          .add(eventJson);

      // Fetch the created document to return with the generated ID
      final doc = await docRef.get();
      return EventModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException('Failed to create event: ${e.toString()}');
    }
  }
}
