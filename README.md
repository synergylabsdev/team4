# LeadRight - Political Event Management Platform

A mobile-first political event management platform built with Flutter and Firebase, serving Attendees, Organizers, and Platform Admins.

## 🏗️ Architecture

This project follows **Clean Architecture** principles with a feature-based modular structure:

```
lib/
├── core/              # Framework-independent business logic
├── data/              # Data sources and repository implementations
├── presentation/      # UI and state management
├── features/          # Feature modules (auth, events, orders, etc.)
├── config/            # App configuration
└── di/                # Dependency injection
```

### Architecture Layers

- **Domain Layer**: Business entities, use cases, and repository interfaces
- **Data Layer**: Models, data sources (Firebase, local storage), repository implementations
- **Presentation Layer**: BLoC state management, pages, and widgets

## 🚀 Features

### MVP Scope

- ✅ **Authentication**: Email/Password, Google, Apple Sign-In
- ✅ **Event Discovery**: List view and interactive map
- ✅ **Ticketing**: Stripe integration with QR codes
- ✅ **Organizer Tools**: Event creation, attendee management, check-in
- ✅ **Admin Panel**: Event/organizer approval, moderation, analytics

## 📦 Tech Stack

- **Framework**: Flutter 3.0+
- **State Management**: BLoC Pattern
- **Backend**: Firebase (Auth, Firestore, Storage, Functions, FCM)
- **Payments**: Stripe
- **Maps**: Google Maps
- **DI**: get_it + injectable

## 🛠️ Setup

### Prerequisites

- Flutter SDK 3.0.0+
- Dart SDK 3.0.0+
- Node.js 18.x (for Cloud Functions)
- Firebase CLI
- Firebase project configured

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd team4project
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with your Firebase and API keys
   ```

4. **Run code generation**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

See [project_structure.md](docs/project_structure.md) for detailed folder organization.

## 🎨 Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `very_good_analysis` linting rules
- Run `flutter analyze` before committing

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test
```

## 📚 Documentation

- [Project Structure](docs/project_structure.md)
- [BLoC Architecture Guide](docs/bloc_architecture_guide.md)
- [Best Practices](docs/best_practices.md)
- [Setup Guide](docs/setup_guide.md)

## 🔐 Security

- Never commit `.env` files with real credentials
- Use Firebase Security Rules for data access control
- Store sensitive data in `flutter_secure_storage`
- Keep Stripe secret keys server-side only

## 📝 License

[Add your license here]

## 👥 Team

[Add team members here]
