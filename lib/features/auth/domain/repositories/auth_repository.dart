import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

/// Repository interface for authentication operations.
///
/// This is an abstract contract that defines what authentication
/// operations are available. The actual implementation is in the data layer.
abstract class AuthRepository {
  /// Sign in with email and password.
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign in with Google.
  Future<Either<Failure, User>> signInWithGoogle();

  /// Sign in with Apple.
  Future<Either<Failure, User>> signInWithApple();

  /// Sign up with email and password.
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign out the current user.
  Future<Either<Failure, void>> signOut();

  /// Get the current authenticated user.
  Future<Either<Failure, User>> getCurrentUser();

  /// Stream of authentication state changes.
  Stream<Either<Failure, User?>> get authStateChanges;

  /// Reset password via email.
  Future<Either<Failure, void>> resetPassword({
    required String email,
  });

  /// Update user profile.
  Future<Either<Failure, User>> updateProfile({
    String? displayName,
    String? photoUrl,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? city,
    String? state,
    String? zipCode,
  });

  /// Check if user profile is complete.
  Future<Either<Failure, bool>> isProfileComplete();
}
