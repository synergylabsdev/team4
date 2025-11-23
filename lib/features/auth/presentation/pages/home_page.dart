import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leadright/di/injection_container.dart';
import 'package:leadright/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:leadright/features/events/domain/entities/event.dart';
import 'package:leadright/features/events/presentation/bloc/events_bloc.dart';
import 'package:leadright/features/events/presentation/widgets/event_card.dart';

/// Home page for attendees displaying upcoming events.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isMapView = false;
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Set<Marker> _buildMarkers(List<Event> events) {
    return events.map((event) {
      return Marker(
        markerId: MarkerId(event.id),
        position: LatLng(event.location.lat, event.location.lng),
        infoWindow: InfoWindow(
          title: event.title,
          snippet: event.location.address,
        ),
      );
    }).toSet();
  }

  void _fitBounds(List<Event> events) {
    if (events.isEmpty || _mapController == null) return;

    double minLat = events.first.location.lat;
    double maxLat = events.first.location.lat;
    double minLng = events.first.location.lng;
    double maxLng = events.first.location.lng;

    for (var event in events) {
      final lat = event.location.lat;
      final lng = event.location.lng;
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<EventsBloc>(),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            return SafeArea(
              child: Column(
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Logo and View Toggle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Logo and App Name
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: const ShapeDecoration(
                                      color: Color(0xFF1E3A8A),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(14380469),
                                        ),
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.event,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'LeadRight',
                                    style: TextStyle(
                                      color: Color(0xFF1E3A8A),
                                      fontSize: 24,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.31,
                                    ),
                                  ),
                                ],
                              ),
                              // View Toggle Switch
                              Container(
                                height: 44,
                                padding: const EdgeInsets.all(4),
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFF6F6F6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(46),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // List View Button
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isMapView = false;
                                        });
                                      },
                                      child: Container(
                                        width: 36,
                                        height: double.infinity,
                                        padding: const EdgeInsets.all(10),
                                        decoration: ShapeDecoration(
                                          color: _isMapView
                                              ? Colors.transparent
                                              : const Color(0xFF1E3A8A),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(40),
                                            ),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.list,
                                          color: _isMapView
                                              ? const Color(0xFF667084)
                                              : Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    // Map View Button
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isMapView = true;
                                        });
                                      },
                                      child: Container(
                                        width: 36,
                                        height: double.infinity,
                                        padding: const EdgeInsets.all(10),
                                        decoration: ShapeDecoration(
                                          color: _isMapView
                                              ? const Color(0xFF1E3A8A)
                                              : Colors.transparent,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(40),
                                            ),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.map,
                                          color: _isMapView
                                              ? Colors.white
                                              : const Color(0xFF667084),
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Search Bar
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: ShapeDecoration(
                              color: const Color(0xFFF6F6F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search,
                                  size: 16,
                                  color: Color(0xFF667084),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Search',
                                    style: TextStyle(
                                      color: Color(0xFF667084),
                                      fontSize: 14,
                                      fontFamily: 'Quicksand',
                                      fontWeight: FontWeight.w400,
                                      height: 1.43,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Filter Buttons
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FilterChip(label: 'Location'),
                              const SizedBox(width: 4),
                              _FilterChip(label: 'Event Theme'),
                              const SizedBox(width: 4),
                              _FilterChip(label: 'Sort By'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Events List or Map Section
                    Expanded(
                      child: BlocBuilder<EventsBloc, EventsState>(
                        builder: (context, eventsState) {
                          if (eventsState is EventsLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (eventsState is EventsError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    eventsState.message,
                                    style: const TextStyle(
                                      color: Color(0xFF0F1728),
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      context
                                          .read<EventsBloc>()
                                          .add(const FetchUpcomingEvents());
                                    },
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            );
                          } else if (eventsState is EventsLoaded) {
                            if (eventsState.events.isEmpty) {
                              return Center(
                                child: Text(
                                  _isMapView
                                      ? 'No events to display on map'
                                      : 'No upcoming events',
                                  style: const TextStyle(
                                    color: Color(0xFF0F1728),
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }

                            // Show Map View
                            if (_isMapView) {
                              // Filter events with valid coordinates
                              final validEvents = eventsState.events
                                  .where((e) =>
                                      e.location.lat != 0.0 &&
                                      e.location.lng != 0.0)
                                  .toList();

                              if (validEvents.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No events with valid locations',
                                    style: TextStyle(
                                      color: Color(0xFF0F1728),
                                      fontSize: 16,
                                    ),
                                  ),
                                );
                              }

                              // Calculate center point
                              double centerLat = validEvents
                                  .map((e) => e.location.lat)
                                  .reduce((a, b) => a + b) /
                                  validEvents.length;
                              double centerLng = validEvents
                                  .map((e) => e.location.lng)
                                  .reduce((a, b) => a + b) /
                                  validEvents.length;

                              return GoogleMap(
                                onMapCreated: (controller) {
                                  _onMapCreated(controller);
                                  // Fit bounds after map is created
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    _fitBounds(validEvents);
                                  });
                                },
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(centerLat, centerLng),
                                  zoom: 12,
                                ),
                                markers: _buildMarkers(validEvents),
                                mapType: MapType.normal,
                                myLocationButtonEnabled: false,
                                zoomControlsEnabled: false,
                              );
                            }

                            // Show List View
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 16,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Upcoming Events',
                                    style: TextStyle(
                                      color: Color(0xFF0F1728),
                                      fontSize: 20,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      height: 1.50,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: ListView.separated(
                                      itemCount: eventsState.events.length,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        final event = eventsState.events[index];
                                        return EventCard(
                                          event: event,
                                          onViewDetails: () {
                                            // TODO: Navigate to event details page
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content:
                                                    Text('Viewing ${event.title}'),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      );
  }
}

/// Filter chip widget for search filters.
class _FilterChip extends StatelessWidget {
  final String label;

  const _FilterChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: const Color(0xFFF6F6F6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF667084),
              fontSize: 12,
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w500,
              height: 1.50,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: Color(0xFF667084),
          ),
        ],
      ),
    );
  }
}