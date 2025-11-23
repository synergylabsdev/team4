import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/event.dart';

/// Widget for displaying an event card in the home page list.
class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onViewDetails;

  const EventCard({
    super.key,
    required this.event,
    this.onViewDetails,
  });

  /// Get badge color based on event type.
  Color _getBadgeColor(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'town hall':
        return const Color(0xFFDBEAFE);
      case 'forum':
        return const Color(0xFFFFEDD4);
      case 'debate':
        return const Color(0xFFF3E8FF);
      default:
        return const Color(0xFFDBEAFE);
    }
  }

  /// Get badge border color based on event type.
  Color _getBadgeBorderColor(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'town hall':
        return const Color(0xFFBDDAFF);
      case 'forum':
        return const Color(0xFFFFD6A7);
      case 'debate':
        return const Color(0xFFE9D4FF);
      default:
        return const Color(0xFFBDDAFF);
    }
  }

  /// Get badge text color based on event type.
  Color _getBadgeTextColor(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'town hall':
        return const Color(0xFF193BB8);
      case 'forum':
        return const Color(0xFF9F2D00);
      case 'debate':
        return const Color(0xFF6D10B0);
      default:
        return const Color(0xFF193BB8);
    }
  }

  /// Get image URL for event.
  String _getImageUrl() {
    if (event.imagePath != null && event.imagePath!.isNotEmpty) {
      // TODO: Get from Firebase Storage URL
      // For now, return placeholder
      return 'https://placehold.co/341x192';
    }
    return 'https://placehold.co/341x192';
  }

  @override
  Widget build(BuildContext context) {
    final eventType = event.eventType;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final startTime = timeFormat.format(event.startAt);
    final endTime = timeFormat.format(event.endAt);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFCFD4DC),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image
          Container(
            width: double.infinity,
            height: 192,
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: _getImageUrl(),
                  width: double.infinity,
                  height: 192,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFFF6F6F6),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFFF6F6F6),
                    child: const Icon(Icons.error),
                  ),
                ),
                // Event Type Badge
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: _getBadgeColor(eventType),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: _getBadgeBorderColor(eventType),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      eventType,
                      style: TextStyle(
                        color: _getBadgeTextColor(eventType),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.33,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Event Details
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Title
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Color(0xFF0A0A0A),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.50,
                    letterSpacing: -0.31,
                  ),
                ),
                const SizedBox(height: 12),
                // Event Info
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date
                    _EventInfoRow(
                      icon: const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                      text: dateFormat.format(event.startAt),
                    ),
                    const SizedBox(height: 8),
                    // Time
                    _EventInfoRow(
                      icon: const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                      text: '$startTime - $endTime',
                    ),
                    const SizedBox(height: 8),
                    // Organizer (using orgId for now, can be enhanced later)
                    _EventInfoRow(
                      icon: const Icon(
                        Icons.person,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                      text: 'Organizer',
                    ),
                    const SizedBox(height: 8),
                    // Location
                    _EventInfoRow(
                      icon: const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                      text: event.location.address,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // View Details Button
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: onViewDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'View Details',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        height: 1.43,
                        letterSpacing: -0.15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper widget for event info row with icon and text.
class _EventInfoRow extends StatelessWidget {
  final Widget icon;
  final String text;

  const _EventInfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        icon,
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.43,
              letterSpacing: -0.15,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
