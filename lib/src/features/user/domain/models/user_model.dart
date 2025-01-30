enum Status { active, inactive }

class ExtendedUser {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? street;
  final String? locality;
  final String? postalCode;
  final String? country;
  final Status status;

  ExtendedUser({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.street,
    this.locality,
    this.postalCode,
    this.country,
    required this.status,
  });

  /// Converte o objeto para um mapa que será salvo no banco
  Map<String, dynamic> toProfileMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'street': street,
      'locality': locality,
      'postal_code': postalCode,
      'country': country,
      'status': status.name,
    };
  }

  /// Cria um ExtendedUser a partir de um mapa do banco
  factory ExtendedUser.fromMap(Map<String, dynamic> data) {
    // Dados básicos de auth.users
    final String id = data['id'];
    final String email = data['email'];

    // Dados adicionais de user_profiles
    final Map<String, dynamic>? profileData = data['user_profiles'];
    if (profileData == null || profileData.isEmpty) {
      throw Exception('Missing user profile data');
    }

    return ExtendedUser(
      id: id,
      email: email,
      name: profileData['name'],
      phone: profileData['phone'],
      street: profileData['street'],
      locality: profileData['locality'],
      postalCode: profileData['postal_code'],
      country: profileData['country'],
      status: Status.values.firstWhere(
        (e) => e.name == profileData['status'],
        orElse: () => Status.inactive, // Valor padrão
      ),
    );
  }

  /// Retorna uma cópia do objeto com valores modificados
  ExtendedUser copyWith({
    String? email,
    String? name,
    String? phone,
    String? street,
    String? locality,
    String? postalCode,
    String? country,
    Status? status,
  }) {
    return ExtendedUser(
      id: id, // ID não pode mudar
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      locality: locality ?? this.locality,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'ExtendedUser(id: $id, email: $email, name: $name, phone: $phone, street: $street, locality: $locality, postalCode: $postalCode, country: $country, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is ExtendedUser) {
      return id == other.id &&
          email == other.email &&
          name == other.name &&
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
        id,
        email,
        name,
        phone,
        street,
        locality,
        postalCode,
        country,
        status,
      );
}
