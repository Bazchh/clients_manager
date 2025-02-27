import 'package:flutter/material.dart';
import 'package:clients_manager/src/features/user/domain/models/user_model.dart';
import 'package:clients_manager/src/features/user/data/services/user_service.dart';
import 'dart:io';

class UserController extends ChangeNotifier {
  final UserService userService;
  UserController(this.userService);

  List<ExtendedUser> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ExtendedUser> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _users = await userService.getAllUsers();
    } catch (e) {
      _errorMessage = 'Failed to load users: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser(ExtendedUser newUser, String password) async {
    try {
      await userService.createUser(newUser, password);

      _users.add(newUser);

      notifyListeners();
      print('State updated: Users count = ${_users.length}');
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create user: $e';
      notifyListeners(); 
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await userService.deleteUser(userId);
      _users.removeWhere((user) => user.id == userId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete user: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> editUser(ExtendedUser updatedUser) async {
    try {
      print('Attempting to update user: ${updatedUser.id}');
      await userService.updateUser(updatedUser);
      print('User updated successfully: ${updatedUser.id}');
      final index = _users.indexWhere((user) => user.id == updatedUser.id);
      if (index != -1) {
        _users[index] = updatedUser;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating user: $e');
      _errorMessage = 'Failed to edit user: $e';
      notifyListeners();
    }
  }

  Future<File> generateUserPdf(ExtendedUser user) async {
    try {
      return await userService.generateUserPdf(user);
    } catch (e) {
      throw Exception('Error generating PDF: $e');
    }
  }
}
