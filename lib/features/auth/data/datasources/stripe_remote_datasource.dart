import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'dart:convert';

import '../../../../core/errors/exceptions.dart';

/// Remote data source for Stripe operations.
abstract class StripeRemoteDataSource {
  /// Create a Stripe Connect account and return onboarding URL.
  /// This should call a Cloud Function that creates the account.
  Future<String> createStripeConnectAccount();

  /// Get the Stripe account ID after onboarding is complete.
  /// This should be called after the user completes onboarding.
  Future<String?> getStripeAccountId();
}

@LazySingleton(as: StripeRemoteDataSource)
class StripeRemoteDataSourceImpl implements StripeRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final http.Client _httpClient;

  StripeRemoteDataSourceImpl(
    this._firebaseAuth,
    this._firestore,
    this._httpClient,
  );

  @override
  Future<String> createStripeConnectAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthException('No user is currently signed in');
      }

      // Get the ID token for authentication
      final idToken = await user.getIdToken();

      // TODO: Replace with your actual Cloud Function URL
      // This should be a Cloud Function that:
      // 1. Creates a Stripe Connect account
      // 2. Creates an account link for onboarding
      // 3. Returns the onboarding URL
      const cloudFunctionUrl =
          'https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/createStripeConnectAccount';

      final response = await _httpClient.post(
        Uri.parse(cloudFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'userId': user.uid,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw ServerException('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final onboardingUrl = data['onboardingUrl'] as String?;
        if (onboardingUrl == null || onboardingUrl.isEmpty) {
          throw ServerException('No onboarding URL returned');
        }
        return onboardingUrl;
      } else {
        throw ServerException(
          'Failed to create Stripe account: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is AuthException) {
        rethrow;
      }
      throw ServerException('Failed to create Stripe account: ${e.toString()}');
    }
  }

  @override
  Future<String?> getStripeAccountId() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthException('No user is currently signed in');
      }

      // Get the ID token for authentication
      final idToken = await user.getIdToken();

      // TODO: Replace with your actual Cloud Function URL
      // This should be a Cloud Function that:
      // 1. Checks the Stripe Connect account status
      // 2. Returns the account ID if onboarding is complete
      const cloudFunctionUrl =
          'https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/getStripeAccountId';

      final response = await _httpClient.get(
        Uri.parse(cloudFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw ServerException('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['accountId'] as String?;
      } else if (response.statusCode == 404) {
        // Account not found or not yet created
        return null;
      } else {
        throw ServerException(
          'Failed to get Stripe account ID: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is AuthException) {
        rethrow;
      }
      throw ServerException('Failed to get Stripe account ID: ${e.toString()}');
    }
  }
}

