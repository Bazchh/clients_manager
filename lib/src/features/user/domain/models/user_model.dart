import 'package:supabase_flutter/supabase_flutter.dart';

enum Status {
  active,
  inactive,
}

class ExtendedUser {
  final User supabaseUser;
  final String? phone;
  final String? street;
  final String? locality;
  final String? postalCode;
  final String? country;
  final Status status;

  ExtendedUser({
    required this.supabaseUser,
    this.phone,
    this.street,
    this.locality,
    this.postalCode,
    this.country,
    required this.status,
  });

  /// Converts the profile-related fields of the user into a map.
  Map<String, dynamic> toProfileMap() {
    return {
      'id': supabaseUser.id,
      'phone': phone,
      'street': street,
      'locality': locality,
      'postal_code': postalCode,
      'country': country,
      'status': status.name,
    };
  }

  /// Factory constructor to create an ExtendedUser from a map and a Supabase user.
  factory ExtendedUser.fromMap(Map<String, dynamic> userMap, User supabaseUser) {
    return ExtendedUser(
      supabaseUser: supabaseUser,
      phone: userMap['phone'],
      street: userMap['street'],
      locality: userMap['locality'],
      postalCode: userMap['postal_code'],
      country: userMap['country'],
      status: Status.values.firstWhere((e) => e.name == userMap['status']),
    );
  }

  /// Converts the full user information (including Supabase user data) into a map.
  Map<String, dynamic> toMap() {
    return {
      'id': supabaseUser.id,
      'email': supabaseUser.email,
      'name': supabaseUser.userMetadata['name'] ?? '',
      'phone': phone,
      'street': street,
      'locality': locality,
      'postal_code': postalCode,
      'country': country,
      'status': status.name,
    };
  }

  /// String representation of the user for debugging purposes.
  @override
  String toString() {
    return 'ExtendedUser(id: ${supabaseUser.id}, email: ${supabaseUser.email}, phone: $phone, street: $street, locality: $locality, postalCode: $postalCode, country: $country, status: $status)';
  }

  /// Equality operator to compare two ExtendedUser objects.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is ExtendedUser) {
      return runtimeType == other.runtimeType &&
          supabaseUser.id == other.supabaseUser.id &&
          phone == other.phone &&
          street == other.street &&
          locality == other.locality &&
          postalCode == other.postalCode &&
          country == other.country &&
          status == other.status;
    }

    return false;
  }

  /// Hash code based on user properties.
  @override
  int get hashCode => Object.hash(
        supabaseUser.id,
        phone,
        street,
        locality,
        postalCode,
        country,
        status,
      );
}