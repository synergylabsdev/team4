import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for updating user profile.
@injectable
class UpdateProfile implements UseCase<User, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfile(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      displayName: params.displayName,
      photoUrl: params.photoUrl,
      firstName: params.firstName,
      lastName: params.lastName,
      phoneNumber: params.phoneNumber,
      city: params.city,
      state: params.state,
      zipCode: params.zipCode,
      bio: params.bio,
      contactEmail: params.contactEmail,
      website: params.website,
      stripeAccountId: params.stripeAccountId,
    );
  }
}

/// Parameters for update profile use case.
class UpdateProfileParams extends Equatable {
  final String? displayName;
  final String? photoUrl;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? bio;
  final String? contactEmail;
  final String? website;
  final String? stripeAccountId;

  const UpdateProfileParams({
    this.displayName,
    this.photoUrl,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.city,
    this.state,
    this.zipCode,
    this.bio,
    this.contactEmail,
    this.website,
    this.stripeAccountId,
  });

  @override
  List<Object?> get props => [
        displayName,
        photoUrl,
        firstName,
        lastName,
        phoneNumber,
        city,
        state,
        zipCode,
        bio,
        contactEmail,
        website,
        stripeAccountId,
      ];
}

