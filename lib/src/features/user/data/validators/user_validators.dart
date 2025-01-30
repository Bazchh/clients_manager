import 'package:clients_manager/src/features/user/domain/models/user_model.dart';

class Validators {
  // Validação de nome
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters long';
    }
    return null; // Sem erro
  }

  // Validação de telefone
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone is required';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  // Validação de rua
  static String? validateStreet(String? value) {
    if (value == null || value.isEmpty) {
      return 'Street is required';
    }
    return null;
  }

  // Validação de código postal
  static String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Postal Code is required';
    }
    final postalCodeRegex = RegExp(r'^[0-9]{5}(-[0-9]{4})?$');
    if (!postalCodeRegex.hasMatch(value)) {
      return 'Enter a valid postal code';
    }
    return null;
  }

  // Validação de país
  static String? validateCountry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Country is required';
    }
    return null;
  }

  // Validação de email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // Validação de senha
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  // Validação de status
  static String? validateStatus(Status? value) {
    if (value == null) {
      return 'Status is required';
    }
    return null;
  }
}