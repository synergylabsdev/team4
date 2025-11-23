import 'package:equatable/equatable.dart';

/// User entity representing an authenticated user in the domain layer.
///
/// This is a pure business object with no dependencies on external frameworks.
class User extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final List<String> roles;
  final String? organizationId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.roles = const ['attendee'],
    this.organizationId,
    required this.createdAt,
    this.updatedAt,
  });

  /// Check if user has a specific role.
  bool hasRole(String role) => roles.contains(role);

  /// Check if user is an attendee.
  bool get isAttendee => hasRole('attendee');

  /// Check if user is an organizer.
  bool get isOrganizer => hasRole('organizer');

  /// Check if user is an admin.
  bool get isAdmin => hasRole('admin');

  /// Get user's display name or email if name is not set.
  String get displayNameOrEmail => displayName ?? email;

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        roles,
        organizationId,
        createdAt,
        updatedAt,
      ];
}
