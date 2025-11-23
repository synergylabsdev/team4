import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
///
/// Failures represent errors that occur during business logic execution.
/// They are used in the Either<Failure, Success> pattern.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Server-side error occurred.
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred'])
      : super(message);
}

/// Network connection error.
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection'])
      : super(message);
}

/// Local cache error.
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred'])
      : super(message);
}

/// Authentication error.
class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}

/// Validation error (e.g., invalid input).
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

/// Permission denied error.
class PermissionFailure extends Failure {
  const PermissionFailure([String message = 'Permission denied'])
      : super(message);
}

/// Resource not found error.
class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Resource not found'])
      : super(message);
}
