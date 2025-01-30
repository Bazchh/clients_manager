import 'dart:io';
import 'package:clients_manager/src/features/user/domain/models/user_model.dart';
import 'package:clients_manager/src/features/user/data/repositories/user_repository.dart';

class UserService {
  final UserRepository _userRepository;

  UserService(this._userRepository);

  Future<void> createUser(ExtendedUser user, String password) async {
    try {
      await _userRepository.createUser(user, password);
    } catch (e) {
      throw Exception('error searching user: $e');
    }
  }

  Future<List<ExtendedUser>> getAllUsers() async {
    try {
      return await _userRepository.getAllUsers();
    } catch (e) {
      throw Exception('error searching users: $e');
    }
  }

  Future<ExtendedUser?> getUserById(String id) async {
    try {
      return await _userRepository.getUserById(id);
    } catch (e) {
      throw Exception('error searching user: $e');
    }
  }

  Future<void> updateUser(ExtendedUser updatedUser) async {
    try {
      await _userRepository.updateUser(updatedUser);
    } catch (e) {
      throw Exception('error on updating user: $e');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _userRepository.deleteUser(id);
    } catch (e) {
      throw Exception('error on deleting user: $e');
    }
  }

  Future<File> generateUserPdf(ExtendedUser user) async {
    try {
      return await _userRepository.generateUserPdf(user);
    } catch (e) {
      throw Exception('error generating archive: $e');
    }
  }
}
