/// Application-wide constants.
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // App Info
  static const String appName = 'LeadRight';
  static const String appVersion = '1.0.0';

  // API & Network
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache
  static const Duration cacheExpiration = Duration(hours: 24);

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String eventsCollection = 'events';
  static const String ordersCollection = 'orders';
  static const String ticketsCollection = 'tickets';
  static const String organizationsCollection = 'organizations';
  static const String checkinsCollection = 'checkins';
  static const String adminLogsCollection = 'adminLogs';

  // Storage Paths
  static const String eventImagesPath = 'events/images';
  static const String organizationImagesPath = 'organizations/images';
  static const String userAvatarsPath = 'users/avatars';

  // Event Status
  static const String eventStatusPending = 'pending';
  static const String eventStatusApproved = 'approved';
  static const String eventStatusPublished = 'published';
  static const String eventStatusCancelled = 'cancelled';

  // Order Status
  static const String orderStatusPending = 'pending';
  static const String orderStatusPaid = 'paid';
  static const String orderStatusRefunded = 'refunded';

  // User Roles
  static const String roleAttendee = 'attendee';
  static const String roleOrganizer = 'organizer';
  static const String roleAdmin = 'admin';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minEventTitleLength = 3;
  static const int maxEventTitleLength = 100;
  static const int maxEventDescriptionLength = 5000;

  // QR Code
  static const String qrCodePrefix = 'TKT:';

  // Stripe Configuration
  static const String stripePublishableKey =
      'pk_test_51RqG4uET4NAZpFjDiN1M0IeJ2oR2wt5HBnVJLXYfVCSzNwOzqHyWjZTASu1FoF4yAXFNmllkByIPbnoW6cm2JoKw00M8Vpat67';
  // Note: Secret key should only be used server-side in Cloud Functions

  // Date Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'MMM dd, yyyy hh:mm a';
}
