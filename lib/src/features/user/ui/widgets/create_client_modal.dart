import 'package:flutter/material.dart';
import 'package:clients_manager/src/features/user/domain/models/user_model.dart';
import 'package:clients_manager/src/features/user/ui/controllers/user_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clients_manager/src/features/user/data/validators/user_validators.dart';
import 'package:another_flushbar/flushbar.dart';

class CreateUserDialog extends StatefulWidget {
  final UserController userController;
  final BuildContext parentContext;
  const CreateUserDialog({
    Key? key,
    required this.userController,
    required this.parentContext,
  }) : super(key: key);

  @override
  _CreateUserDialogState createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<CreateUserDialog> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late Status _selectedStatus;

  String? _nameError;
  String? _phoneError;
  String? _streetError;
  String? _postalCodeError;
  String? _countryError;
  String? _emailError;
  String? _passwordError;
  String? _statusError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _streetController = TextEditingController();
    _postalCodeController = TextEditingController();
    _countryController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _selectedStatus = Status.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    setState(() {
      _nameError = Validators.validateName(_nameController.text);
      _phoneError = Validators.validatePhone(_phoneController.text);
      _streetError = Validators.validateStreet(_streetController.text);
      _postalCodeError =
          Validators.validatePostalCode(_postalCodeController.text);
      _countryError = Validators.validateCountry(_countryController.text);
      _emailError = Validators.validateEmail(_emailController.text);
      _passwordError = Validators.validatePassword(_passwordController.text);
      _statusError = Validators.validateStatus(_selectedStatus);
    });

    if (_nameError != null ||
        _phoneError != null ||
        _streetError != null ||
        _postalCodeError != null ||
        _countryError != null ||
        _emailError != null ||
        _passwordError != null ||
        _statusError != null) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create User'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                errorText: _nameError,
              ),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                errorText: _phoneError,
              ),
            ),
            TextField(
              controller: _streetController,
              decoration: InputDecoration(
                labelText: 'Street',
                errorText: _streetError,
              ),
            ),
            TextField(
              controller: _postalCodeController,
              decoration: InputDecoration(
                labelText: 'Postal Code',
                errorText: _postalCodeError,
              ),
            ),
            TextField(
              controller: _countryController,
              decoration: InputDecoration(
                labelText: 'Country',
                errorText: _countryError,
              ),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: _emailError,
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: _passwordError,
              ),
            ),
            DropdownButton<Status>(
              value: _selectedStatus,
              onChanged: (Status? newStatus) {
                setState(() {
                  _selectedStatus = newStatus!;
                });
              },
              items: Status.values.map((Status status) {
                return DropdownMenuItem<Status>(
                  value: status,
                  child: Text(status.name),
                );
              }).toList(),
              hint: const Text('Select Status'),
            ),
            if (_statusError != null)
              Text(
                _statusError!,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (!_validateForm()) return;
            try {
              final response = await Supabase.instance.client.auth.signUp(
                email: _emailController.text,
                password: _passwordController.text,
              );
              if (response.user == null) {
                _showFlushbar('Failed to create user: Unknown error');
                return;
              }
              final newUser = ExtendedUser(
                id: response.user!.id,
                email: response.user!.email ?? '',
                name: _nameController.text,
                phone: _phoneController.text,
                street: _streetController.text,
                postalCode: _postalCodeController.text,
                country: _countryController.text,
                status: _selectedStatus,
              );
              final success = await widget.userController.createUser(
                newUser,
                _passwordController.text,
              );
              if (success) {
                Navigator.pop(context); // Fecha o diálogo
                await widget.userController.loadUsers();
                _showFlushbar('User created successfully');
              } else {
                _showFlushbar('Failed to save user data');
              }
            } catch (e) {
              _showFlushbar('Error creating user: $e');
            }
          },
          child: const Text('Save', style: TextStyle(color: Colors.green)),
        ),
      ],
    );
  }

  void _showFlushbar(String message) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.BOTTOM,
      backgroundColor: Colors.red,
      borderRadius: BorderRadius.circular(8),
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
    ).show(widget.parentContext);
  }
}
