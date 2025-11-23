# LeadRight Project Knowledge Base

> **This file serves as the authoritative reference for all development decisions, best practices, and project scope. Always consult this file before making implementation decisions.**

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Flutter UI Best Practices](#flutter-ui-best-practices)
3. [Dart Logic & Algorithm Best Practices](#dart-logic--algorithm-best-practices)
4. [Project Scope & Requirements](#project-scope--requirements)
5. [Architecture & Implementation](#architecture--implementation)
6. [Development Standards](#development-standards)

---

## Project Overview

**LeadRight** is a mobile-first political event management platform replacing an unreliable WordPress site. The MVP serves three user types (Attendees, Organizers, Platform Admins) with core flows for event discovery, ticketing, organizer onboarding, and day-of check-in support.

**Tech Stack:**
- **Frontend:** Flutter (iOS, Android, Web)
- **Backend:** Firebase (Firestore, Auth, Cloud Functions, Cloud Storage, FCM)
- **Payments:** Stripe (UI-only for MVP, Stripe Connect for future)
- **Maps:** Google Maps SDK via `google_maps_flutter`
- **State Management:** BLoC pattern (`flutter_bloc`)
- **Dependency Injection:** `get_it` + `injectable`

---

## Flutter UI Best Practices

### 1. Widget Composition & Reusability

**DO:**
- Break down complex UIs into small, reusable widgets
- Use `const` constructors wherever possible for performance
- Create custom widgets for repeated patterns (e.g., `EventCard`, `TicketCard`)
- Follow single responsibility principle for widgets

**Example:**
```dart
// ✅ Good: Reusable, const widget
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  final Event event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(event.description),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 2. Responsive Design

**DO:**
- Use `LayoutBuilder` or `MediaQuery` for responsive layouts
- Implement breakpoints for web (mobile: <600, tablet: 600-1200, desktop: >1200)
- Use `Flexible` and `Expanded` appropriately
- Test on multiple screen sizes

**Example:**
```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return _buildTabletLayout();
    }
    return _buildMobileLayout();
  },
)
```

### 3. Performance Optimization

**DO:**
- Use `ListView.builder` for long lists (never `ListView` with children)
- Implement `AutomaticKeepAliveClientMixin` for tabs that should preserve state
- Use `RepaintBoundary` to isolate expensive repaints
- Lazy load images with `cached_network_image`
- Use `const` widgets to prevent unnecessary rebuilds

**Example:**
```dart
// ✅ Good: Efficient list rendering
ListView.builder(
  itemCount: events.length,
  itemBuilder: (context, index) {
    return EventCard(event: events[index]);
  },
)
```

### 4. Material Design 3 Guidelines

**DO:**
- Use Material 3 design tokens (colors, typography, spacing)
- Follow Material Design accessibility guidelines
- Use appropriate elevation and shadows
- Implement proper touch targets (minimum 48x48 logical pixels)
- Use semantic colors (primary, secondary, error, surface)

### 5. Loading States & Error Handling

**DO:**
- Always show loading indicators for async operations
- Provide clear error messages with retry options
- Use shimmer effects for skeleton loading
- Implement empty states for lists

**Example:**
```dart
BlocBuilder<EventBloc, EventState>(
  builder: (context, state) {
    if (state is EventLoading) {
      return const ShimmerEventList();
    }
    if (state is EventError) {
      return ErrorView(
        message: state.message,
        onRetry: () => context.read<EventBloc>().add(LoadEvents()),
      );
    }
    if (state is EventLoaded && state.events.isEmpty) {
      return const EmptyEventsView();
    }
    return EventList(events: state.events);
  },
)
```

### 6. Navigation & Routing

**DO:**
- Use named routes for better maintainability
- Implement deep linking support
- Use `Navigator.push` with proper route transitions
- Handle back button behavior appropriately

### 7. Forms & Validation

**DO:**
- Use `Form` widget with `GlobalKey<FormState>`
- Implement real-time validation with `formz` package
- Show validation errors inline
- Disable submit button until form is valid

### 8. Accessibility

**DO:**
- Add semantic labels with `Semantics` widget
- Ensure proper contrast ratios (WCAG AA minimum)
- Support screen readers
- Test with accessibility tools

---

## Dart Logic & Algorithm Best Practices

### 1. Clean Architecture Principles

**DO:**
- Follow Clean Architecture layers: Presentation → Domain → Data
- Use dependency inversion (depend on abstractions, not concretions)
- Separate business logic from UI logic
- Use Use Cases for business operations

**Structure:**
```
lib/
  features/
    events/
      data/
        datasources/
        models/
        repositories/
      domain/
        entities/
        repositories/
        usecases/
      presentation/
        bloc/
        pages/
        widgets/
```

### 2. State Management with BLoC

**DO:**
- Keep BLoCs focused on single responsibilities
- Use `Equatable` for state comparison
- Emit states immutably
- Handle errors in BLoC and emit error states
- Use `BlocProvider` for dependency injection

**Example:**
```dart
// ✅ Good: Clean BLoC pattern
class EventBloc extends Bloc<EventEvent, EventState> {
  EventBloc(this._getEventsUseCase) : super(EventInitial()) {
    on<LoadEvents>(_onLoadEvents);
  }

  final GetEventsUseCase _getEventsUseCase;

  Future<void> _onLoadEvents(
    LoadEvents event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    final result = await _getEventsUseCase();
    result.fold(
      (failure) => emit(EventError(failure.message)),
      (events) => emit(EventLoaded(events)),
    );
  }
}
```

### 3. Error Handling

**DO:**
- Use `Either<Failure, T>` pattern (via `dartz` package) for operations that can fail
- Create specific failure classes extending base `Failure`
- Never swallow errors silently
- Log errors appropriately

**Example:**
```dart
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// In repository
Future<Either<Failure, List<Event>>> getEvents() async {
  try {
    final events = await _remoteDataSource.getEvents();
    return Right(events);
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  }
}
```

### 4. Async Operations

**DO:**
- Use `async`/`await` for readable async code
- Handle `Future` errors with try-catch or `Future.catchError`
- Use `Future.wait` for parallel operations when appropriate
- Cancel operations when widgets are disposed

**Example:**
```dart
// ✅ Good: Proper async handling
Future<List<Event>> loadEvents() async {
  try {
    final events = await _repository.getEvents();
    final userEvents = await _repository.getUserEvents();
    return [...events, ...userEvents];
  } catch (e) {
    throw EventLoadException('Failed to load events: $e');
  }
}
```

### 5. Data Structures & Algorithms

**DO:**
- Use appropriate collections (`List`, `Set`, `Map`) based on use case
- Prefer `Set` for uniqueness checks (O(1) lookup)
- Use `Map` for key-value lookups
- Sort lists efficiently using `List.sort()` with custom comparators

**Example:**
```dart
// ✅ Good: Efficient filtering and sorting
final upcomingEvents = events
    .where((e) => e.startAt.isAfter(DateTime.now()))
    .toList()
    ..sort((a, b) => a.startAt.compareTo(b.startAt));
```

### 6. Memory Management

**DO:**
- Dispose controllers and streams in `dispose()` methods
- Use `StreamSubscription.cancel()` for stream subscriptions
- Avoid memory leaks with proper cleanup
- Use weak references when appropriate

**Example:**
```dart
class EventController {
  StreamSubscription? _subscription;
  
  void listen() {
    _subscription = eventStream.listen((event) {
      // Handle event
    });
  }
  
  void dispose() {
    _subscription?.cancel();
  }
}
```

### 7. Functional Programming Patterns

**DO:**
- Use `map`, `where`, `fold`, `reduce` for list transformations
- Prefer immutable data structures
- Use `freezed` for immutable data classes
- Chain operations for readability

**Example:**
```dart
// ✅ Good: Functional style
final totalRevenue = orders
    .where((o) => o.paymentStatus == PaymentStatus.paid)
    .map((o) => o.amountCents)
    .fold(0, (sum, amount) => sum + amount);
```

### 8. Code Organization

**DO:**
- Keep functions small and focused
- Use meaningful variable and function names
- Extract magic numbers into constants
- Group related functionality together

**Example:**
```dart
// ✅ Good: Well-organized code
class EventValidator {
  static const int minTitleLength = 3;
  static const int maxTitleLength = 100;
  static const int minDescriptionLength = 10;

  static ValidationResult validateTitle(String title) {
    if (title.isEmpty) {
      return ValidationResult.error('Title is required');
    }
    if (title.length < minTitleLength) {
      return ValidationResult.error('Title must be at least $minTitleLength characters');
    }
    if (title.length > maxTitleLength) {
      return ValidationResult.error('Title must be at most $maxTitleLength characters');
    }
    return ValidationResult.success();
  }
}
```

### 9. Testing Considerations

**DO:**
- Write pure functions that are easy to test
- Mock dependencies in tests
- Test edge cases and error scenarios
- Use dependency injection for testability

---

## Project Scope & Requirements

### Background

LeadRight is replacing an unreliable WordPress site with a mobile-first political event management platform (iOS, Android, responsive web). The goal is a lightweight MVP that serves three user types (Attendees, Organizers, Platform Admins) and implements core flows from the provided SOW.

### Key Assumptions

1. **Tech Stack:** Flutter for cross-platform UI and Firebase (Firestore, Auth, Cloud Functions, Cloud Storage, FCM) for backend services
2. **Payments:** Stripe (Stripe Connect) for ticket payments and split payouts
3. **Real-time Features:** Firestore listeners and FCM push notifications
4. **Scale:** Support up to medium event volumes initially (tens of thousands of users overall, thousands of events)
5. **WordPress:** Existing WordPress site will be decommissioned or redirected once web app is live

### Requirements (MoSCoW Prioritization)

#### Must-Have (MVP)

1. **User Types:** Organizer & Attendee primary support
2. **Auth:** Email/Password + OAuth (Google/Apple) via Firebase Auth
3. **Organizer Onboarding:**
   - Create organization
   - Create events
   - Upload images
   - Set ticket types
4. **Attendee Flow:**
   - Event list + detail page
   - Map view for event discovery
   - Ticket purchase via Stripe Checkout
   - Ticket storage
5. **Payments:**
   - Stripe Connect onboarding for organizers (after MVP)
   - MVP uses Platform Stripe for purchasing but holds revenue (no payout yet)
6. **Event Management:**
   - Attendee list
   - QR-based check-in
7. **Admin (Minimal):**
   - Approve events & organizers
   - Basic moderation
8. **Notifications:**
   - FCM push notifications for ticket purchase confirmation & reminders
9. **Data Storage:**
   - Firestore for all structured data
   - Cloud Storage for event images

#### Should-Have

1. Ticket Refund workflow (manual for MVP)
2. Organizer Analytics: Basic metrics (ticket count, revenue placeholder)
3. Search & Filters for events
4. Web Responsive App built from same Flutter codebase

#### Could-Have

1. White Glove CTA form that routes to admin
2. Promo codes
3. Saved Events / Favorites

#### Won't-Have (Now)

1. Automated Stripe Connect payouts
2. Complex admin analytics
3. Multi-role organizer permissions

---

## Architecture & Implementation

### High-Level Architecture

**Client:** Flutter (iOS, Android, Web)
- Packages: `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_messaging`, `google_maps_flutter`, `mobile_scanner`, `flutter_stripe`, `flutter_bloc`, `get_it`, `injectable`

**Backend:** Firebase services
- Firestore: Data storage
- Auth: Authentication
- Cloud Functions: Server-trusted operations
- Cloud Storage: Media storage
- FCM: Push notifications

**Payments:** UI-only Stripe flow for MVP
- App shows Stripe Checkout UI flow and collects confirmation
- Cloud Function simulates webhook to mark orders paid
- Feature flag: `use_live_stripe = false` for MVP

**Maps:** Google Maps SDK via `google_maps_flutter` for event location and map-based discovery

### Firestore Data Model

#### `/users/{userId}`
```dart
{
  uid: string (doc id),
  email: string,
  displayName: string,
  roles: ["attendee" | "organizer" | "admin"],
  organizationId: string? (if organizer),
  createdAt: timestamp
}
```

#### `/organizations/{orgId}`
```dart
{
  id: string,
  name: string,
  ownerId: string,
  stripeAccountId: string? (null for MVP),
  tier: string,
  billingEmail: string,
  createdAt: timestamp
}
```

#### `/events/{eventId}`
```dart
{
  id: string,
  orgId: string,
  title: string,
  description: string,
  startAt: timestamp,
  endAt: timestamp,
  location: {
    lat: number,
    lng: number,
    address: string
  },
  capacity: number,
  ticketTypes: [
    {
      id: string,
      title: string,
      price_cents: number,
      quantity: number,
      salesStart: timestamp,
      salesEnd: timestamp
    }
  ],
  imagePath: string (storage path),
  status: "pending" | "approved" | "published" | "cancelled",
  createdAt: timestamp,
  updatedAt: timestamp
}
```

#### `/orders/{orderId}`
```dart
{
  id: string,
  eventId: string,
  userId: string,
  tickets: [
    {
      ticketTypeId: string,
      qty: number
    }
  ],
  amount_cents: number,
  currency: string,
  paymentStatus: "pending" | "paid" | "refunded",
  paymentMethod: "stripe_ui_placeholder",
  stripeIntent: string? (placeholder),
  createdAt: timestamp
}
```

#### `/tickets/{ticketId}`
```dart
{
  id: string,
  orderId: string,
  eventId: string,
  ownerUserId: string,
  ticketTypeId: string,
  qrCodePayload: string,
  checkedIn: bool,
  checkedInAt: timestamp?
}
```

#### `/checkins/{checkinId}`
```dart
{
  id: string,
  ticketId: string,
  eventId: string,
  checkedBy: userId,
  checkedAt: timestamp
}
```

#### `/adminLogs/{logId}`
```dart
{
  id: string,
  action: string,
  actorId: string,
  targetId: string,
  details: object,
  timestamp: timestamp
}
```

**Indexes:**
- Composite indexes on `events(startAt)`
- Composite indexes on `events(status, startAt)`
- Composite indexes on `orders(userId, createdAt)`

### Key Flows

#### 1. Organizer Onboarding & Create Event

1. Organizer signs up (Firebase Auth)
2. Create organization document → org in `pending` status until admin approval
3. Admin reviews via Admin UI
4. Organizer creates event with ticket types; images uploaded to Cloud Storage
5. Event doc status: `pending`
6. Once admin approves → status: `published`, event appears in attendee discovery

#### 2. Attendee Buys Ticket (UI-only Stripe flow)

1. Attendee chooses ticket(s)
2. App calls Cloud Function `createOrderPreview` which writes an order doc with `paymentStatus: pending`
3. App displays Stripe checkout UI placeholder (or modal that mimics Stripe flow)
4. On confirmation, app calls Cloud Function `simulatePaymentConfirmation(orderId)` which:
   - Sets `paymentStatus: paid`
   - Creates tickets documents
   - Returns ticket QR payloads
5. App stores tickets in local secure storage
6. Shows email/receipt (FCM + email triggered via Cloud Function)

#### 3. Day-of Check-in

1. Event staff uses Organizer app screen with camera to scan QR codes
2. Scanning reads `qrCodePayload` → query tickets collection to validate
3. Set `checkedIn: true` and create checkins log

### Security & Rules

**Firebase Security Rules (High-level):**

```javascript
// Events
match /events/{eventId} {
  allow read: if true;
  allow create: if request.auth != null && 
    request.resource.data.orgId == get(/databases/$(database)/documents/organizations/$(request.auth.uid)).id;
  allow update: if isOrganizerOfOrg(request.auth.uid, resource.data.orgId);
}

// Orders
match /orders/{orderId} {
  allow read: if request.auth != null && 
    (resource.data.userId == request.auth.uid || isOrganizerOfEvent(request.auth.uid, resource.data.eventId));
  allow create: if request.auth != null;
  allow update: if isAdmin();
}

// Tickets
match /tickets/{ticketId} {
  allow read: if request.auth != null && 
    (resource.data.ownerUserId == request.auth.uid || isOrganizerOfEvent(request.auth.uid, resource.data.eventId));
  allow update: if isOrganizerOfEvent(request.auth.uid, resource.data.eventId);
}

function isAdmin() {
  return request.auth != null && 
    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.roles.hasAny(["admin"]);
}

function isOrganizerOfOrg(userId, orgId) {
  return get(/databases/$(database)/documents/organizations/$(orgId)).data.ownerId == userId;
}

function isOrganizerOfEvent(userId, eventId) {
  let event = get(/databases/$(database)/documents/events/$(eventId));
  return isOrganizerOfOrg(userId, event.data.orgId);
}
```

### Offline Considerations

- Firestore offline persistence enables basic browsing and ticket display with spotty connectivity
- Critical writes (check-ins) queue and resolve conflicts via Cloud Function verification

### Storage & Media

- Store images under `/orgs/{orgId}/events/{eventId}/images/{filename}`
- Keep file metadata in event doc for CDN-friendly serving
- Use Firebase Storage rules to allow org owners to write their assets only

### Reporting & Exports

- Cloud Function `generateEventReport(eventId)` exports attendee list and sales (orders) as CSV into Storage
- Returns signed URL for admin download

### Directory Layout (Flutter)

```
lib/
  config/
    env/
    firebase/
    routes/
  core/
    entities/
    errors/
    network/
    repositories/
    usecases/
    utils/
  data/
    datasources/
    models/
    repositories/
  di/
    injection_container.dart
    injection_container.config.dart
  features/
    admin/
    auth/
    events/
    orders/
    organizer/
    profile/
  presentation/
    bloc/
    pages/
    theme/
    widgets/
  main.dart
  firebase_options.dart
```

### Cloud Functions (Recommended Endpoints)

1. **`createOrderPreview(userId, eventId, cart)`**
   - Creates `orders/{orderId}` with `pending` status

2. **`simulatePaymentConfirmation(orderId)`**
   - Mark paid, create tickets, trigger notifications
   - Used for MVP (no real Stripe keys required)

3. **`generateEventReport(eventId)`**
   - CSV export to Storage and return signed URL

4. **`adminApproveEvent(eventId)`**
   - Set event status to `published`

### Testing & QA

- Unit tests for Firestore models and Flutter widgets
- Integration tests for flows using Firebase Emulator Suite
- Manual QA on device for Google Maps, QR scanning, and offline check-in

---

## Development Standards

### Code Style

- Follow Dart style guide: https://dart.dev/guides/language/effective-dart/style
- Use `very_good_analysis` linting rules (already configured)
- Maximum line length: 80 characters (soft limit)
- Use meaningful variable and function names

### Git Workflow

- Use descriptive commit messages
- Create feature branches for new features
- Keep commits atomic and focused

### Documentation

- Document public APIs
- Use inline comments for complex logic
- Keep README updated with setup instructions

### Performance Targets

- App should launch in < 2 seconds
- List scrolling should maintain 60 FPS
- Images should load progressively
- Network requests should have timeout handling

### Security Checklist

- ✅ Never commit API keys or secrets
- ✅ Use environment variables for configuration
- ✅ Validate all user inputs
- ✅ Implement proper authentication checks
- ✅ Use Firebase Security Rules
- ✅ Sanitize data before displaying

---

## Quick Reference

### Common Patterns

**BLoC State Pattern:**
```dart
abstract class EventState extends Equatable {
  const EventState();
  @override
  List<Object> get props => [];
}

class EventInitial extends EventState {}
class EventLoading extends EventState {}
class EventLoaded extends EventState {
  final List<Event> events;
  const EventLoaded(this.events);
  @override
  List<Object> get props => [events];
}
class EventError extends EventState {
  final String message;
  const EventError(this.message);
  @override
  List<Object> get props => [message];
}
```

**Repository Pattern:**
```dart
abstract class EventRepository {
  Future<Either<Failure, List<Event>>> getEvents();
  Future<Either<Failure, Event>> getEventById(String id);
  Future<Either<Failure, void>> createEvent(Event event);
}
```

**Use Case Pattern:**
```dart
@injectable
class GetEventsUseCase {
  final EventRepository _repository;
  
  GetEventsUseCase(this._repository);
  
  Future<Either<Failure, List<Event>>> call() {
    return _repository.getEvents();
  }
}
```

---

**Last Updated:** 2024
**Version:** 1.0.0

---

> **Note:** This knowledge base should be consulted before making any architectural or implementation decisions. When in doubt, refer to this document or update it with new decisions.

