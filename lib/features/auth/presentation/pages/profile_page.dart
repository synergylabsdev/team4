import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadright/di/injection_container.dart';
import 'package:leadright/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:leadright/features/events/domain/entities/event.dart';
import 'package:leadright/features/events/domain/repositories/event_repository.dart';
import 'package:leadright/core/utils/constants.dart';

/// Profile page showing user information and settings.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const Text(
                        'Profile',
                        style: TextStyle(
                          color: Color(0xFF0F1728),
                          fontSize: 24,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Profile Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const ShapeDecoration(
                                color: Color(0xFF1E3A8A),
                                shape: CircleBorder(),
                              ),
                              child: Center(
                                child: Text(
                                  state.user.displayName?.isNotEmpty == true
                                      ? state.user.displayName![0].toUpperCase()
                                      : state.user.email[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Name
                            Text(
                              state.user.displayName ?? 'User',
                              style: const TextStyle(
                                color: Color(0xFF0F1728),
                                fontSize: 20,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Email
                            Text(
                              state.user.email,
                              style: const TextStyle(
                                color: Color(0xFF667084),
                                fontSize: 14,
                                fontFamily: 'Quicksand',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Settings Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Settings',
                              style: TextStyle(
                                color: Color(0xFF0F1728),
                                fontSize: 18,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Placeholder settings items
                            _SettingsItem(
                              icon: Icons.person_outline,
                              title: 'Edit Profile',
                              onTap: () {
                                // TODO: Navigate to edit profile page
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Edit Profile - Coming soon'),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            _SettingsItem(
                              icon: Icons.notifications_outlined,
                              title: 'Notifications',
                              onTap: () {
                                // TODO: Navigate to notifications settings
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Notifications - Coming soon'),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            _SettingsItem(
                              icon: Icons.security_outlined,
                              title: 'Privacy & Security',
                              onTap: () {
                                // TODO: Navigate to privacy settings
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Privacy & Security - Coming soon'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Test Button - Add Sample Events
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Developer Tools',
                              style: TextStyle(
                                color: Color(0xFF0F1728),
                                fontSize: 18,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _addSampleEvents(context, state.user.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3A8A),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Add Sample Events',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(const SignOutRequested());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Log Out',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  /// Add sample events to the database for testing purposes.
  static Future<void> _addSampleEvents(BuildContext context, String userId) async {
    try {
      final eventRepository = getIt<EventRepository>();
      final now = DateTime.now();
      
      // Use userId as orgId for test events, or use a test org ID
      final testOrgId = 'test_org_$userId';

      // Sample events with different dates
      final sampleEvents = [
        Event(
          id: '', // Will be generated by Firestore
          orgId: testOrgId,
          title: 'Town Hall Meeting - Community Discussion',
          description: 'Join us for an open town hall meeting where we discuss important community issues and gather feedback from residents. This is your opportunity to voice your concerns and ideas.',
          startAt: now.add(const Duration(days: 7)),
          endAt: now.add(const Duration(days: 7, hours: 2)),
          location: const EventLocation(
            lat: 40.7128,
            lng: -74.0060,
            address: '123 Main Street, New York, NY 10001',
          ),
          capacity: 200,
          ticketTypes: [
            TicketType(
              id: 'general',
              title: 'General Admission',
              priceCents: 0,
              quantity: 200,
              salesStart: now,
              salesEnd: now.add(const Duration(days: 6)),
            ),
          ],
          status: AppConstants.eventStatusPublished,
          createdAt: now,
          updatedAt: null,
        ),
        Event(
          id: '',
          orgId: testOrgId,
          title: 'Political Rally - Support Our Cause',
          description: 'A rally to show support for our political movement. Come together with like-minded individuals to make your voice heard.',
          startAt: now.add(const Duration(days: 14)),
          endAt: now.add(const Duration(days: 14, hours: 3)),
          location: const EventLocation(
            lat: 34.0522,
            lng: -118.2437,
            address: '456 Park Avenue, Los Angeles, CA 90001',
          ),
          capacity: 500,
          ticketTypes: [
            TicketType(
              id: 'standard',
              title: 'Standard Ticket',
              priceCents: 2500, // $25.00
              quantity: 400,
              salesStart: now,
              salesEnd: now.add(const Duration(days: 13)),
            ),
            TicketType(
              id: 'vip',
              title: 'VIP Ticket',
              priceCents: 5000, // $50.00
              quantity: 100,
              salesStart: now,
              salesEnd: now.add(const Duration(days: 13)),
            ),
          ],
          status: AppConstants.eventStatusPublished,
          createdAt: now,
          updatedAt: null,
        ),
        Event(
          id: '',
          orgId: testOrgId,
          title: 'Debate Forum - Policy Discussion',
          description: 'An engaging debate forum where candidates discuss key policy issues. This is a great opportunity to learn about different perspectives on important topics.',
          startAt: now.add(const Duration(days: 21)),
          endAt: now.add(const Duration(days: 21, hours: 2, minutes: 30)),
          location: const EventLocation(
            lat: 41.8781,
            lng: -87.6298,
            address: '789 State Street, Chicago, IL 60601',
          ),
          capacity: 300,
          ticketTypes: [
            TicketType(
              id: 'student',
              title: 'Student Ticket',
              priceCents: 1000, // $10.00
              quantity: 100,
              salesStart: now,
              salesEnd: now.add(const Duration(days: 20)),
            ),
            TicketType(
              id: 'adult',
              title: 'Adult Ticket',
              priceCents: 2000, // $20.00
              quantity: 200,
              salesStart: now,
              salesEnd: now.add(const Duration(days: 20)),
            ),
          ],
          status: AppConstants.eventStatusPublished,
          createdAt: now,
          updatedAt: null,
        ),
        Event(
          id: '',
          orgId: testOrgId,
          title: 'Community Forum - Local Issues',
          description: 'A community forum focused on local issues affecting our neighborhood. We welcome all residents to participate in this important discussion.',
          startAt: now.add(const Duration(days: 30)),
          endAt: now.add(const Duration(days: 30, hours: 2)),
          location: const EventLocation(
            lat: 29.7604,
            lng: -95.3698,
            address: '321 Commerce Street, Houston, TX 77002',
          ),
          capacity: 150,
          ticketTypes: [
            TicketType(
              id: 'free',
              title: 'Free Admission',
              priceCents: 0,
              quantity: 150,
              salesStart: now,
              salesEnd: now.add(const Duration(days: 29)),
            ),
          ],
          status: AppConstants.eventStatusPublished,
          createdAt: now,
          updatedAt: null,
        ),
        Event(
          id: '',
          orgId: testOrgId,
          title: 'Campaign Event - Meet the Candidate',
          description: 'Join us for an exclusive meet and greet with our candidate. This is a great opportunity to ask questions and learn more about our platform.',
          startAt: now.add(const Duration(days: 45)),
          endAt: now.add(const Duration(days: 45, hours: 1, minutes: 30)),
          location: const EventLocation(
            lat: 33.4484,
            lng: -112.0740,
            address: '555 Central Avenue, Phoenix, AZ 85004',
          ),
          capacity: 100,
          ticketTypes: [
            TicketType(
              id: 'early_bird',
              title: 'Early Bird',
              priceCents: 1500, // $15.00
              quantity: 50,
              salesStart: now,
              salesEnd: now.add(const Duration(days: 30)),
            ),
            TicketType(
              id: 'regular',
              title: 'Regular',
              priceCents: 2000, // $20.00
              quantity: 50,
              salesStart: now.add(const Duration(days: 30)),
              salesEnd: now.add(const Duration(days: 44)),
            ),
          ],
          status: AppConstants.eventStatusPublished,
          createdAt: now,
          updatedAt: null,
        ),
      ];

      // Show loading indicator
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      int successCount = 0;
      for (final event in sampleEvents) {
        final result = await eventRepository.createEvent(event);
        result.fold(
          (failure) {
            // Error creating event
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to create event: ${event.title}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          (createdEvent) {
            successCount++;
          },
        );
      }

      // Hide loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully created $successCount sample events!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding sample events: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF667084),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0F1728),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF667084),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

