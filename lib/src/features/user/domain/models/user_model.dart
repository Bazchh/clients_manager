import 'package:supabase_flutter/supabase_flutter.dart';

enum Status {
  active,
  inactive,
}

class ExtendedUser {
  final User supabaseUser;
  final String? name;
  final String? phone;
  final String? street;
  final String? locality;
  final String? postalCode;
  final String? country;
  final Status status;

  ExtendedUser({
    required this.supabaseUser,
    this.name,
    this.phone,
    this.street,
    this.locality,
    this.postalCode,
    this.country,
    required this.status,
  });

  Map<String, dynamic> toProfileMap() {
    return {
      'id': supabaseUser.id,
      'name': name,
      'phone': phone,
      'street': street,
      'locality': locality,
      'postal_code': postalCode,
      'country': country,
      'status': status.name,
    };
  }

  factory ExtendedUser.fromMap(Map<String, dynamic> userMap, User supabaseUser) {
    return ExtendedUser(
      name: userMap['name'],
      phone: userMap['phone'],
      supabaseUser: supabaseUser,
      street: userMap['street'],
      locality: userMap['locality'],
      postalCode: userMap['postal_code'],
      country: userMap['country'],
      status: Status.values.firstWhere((e) => e.name == userMap['status']),
    );
  }

  ExtendedUser copyWith({
    String? name,
    String? phone,
    String? street,
    String? locality,
    String? postalCode,
    String? country,
    Status? status,
  }) {
    return ExtendedUser(
      supabaseUser: this.supabaseUser, // Não pode mudar o usuário do Supabase, então não inclui aqui
      name: name ?? this.name,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      locality: locality ?? this.locality,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': supabaseUser.id,
      'email': supabaseUser.email,
      'name': name,
      'phone': phone,
      'street': street,
      'locality': locality,
      'postal_code': postalCode,
      'country': country,
      'status': status.name,
    };
  }

  @override
  String toString() {
    return 'ExtendedUser(id: ${supabaseUser.id}, email: ${supabaseUser.email}, phone: $phone, street: $street, locality: $locality, postalCode: $postalCode, country: $country, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is ExtendedUser) {
      return runtimeType == other.runtimeType &&
          name == other.name &&
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

  @override
  int get hashCode => Object.hash(
        supabaseUser.id,
        name,
        phone,
        street,
        locality,
        postalCode,
        country,
        status,
      );
}