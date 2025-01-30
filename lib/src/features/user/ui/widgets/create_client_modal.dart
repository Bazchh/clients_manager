import 'package:flutter/material.dart';
import 'package:clients_manager/src/features/user/domain/models/user_model.dart';
import 'package:clients_manager/src/features/user/ui/controllers/user_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clients_manager/src/features/user/data/validators/user_validators.dart'; // Importe os validadores

class CreateUserDialog extends StatefulWidget {
  final UserController userController;

  const CreateUserDialog({
    Key? key,
    required this.userController,
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

  // Função para validar o formulário
  bool _validateForm() {
    final nameError = Validators.validateName(_nameController.text);
    final phoneError = Validators.validatePhone(_phoneController.text);
    final streetError = Validators.validateStreet(_streetController.text);
    final postalCodeError = Validators.validatePostalCode(_postalCodeController.text);
    final countryError = Validators.validateCountry(_countryController.text);
    final emailError = Validators.validateEmail(_emailController.text);
    final passwordError = Validators.validatePassword(_passwordController.text);
    final statusError = Validators.validateStatus(_selectedStatus);

    if (nameError != null ||
        phoneError != null ||
        streetError != null ||
        postalCodeError != null ||
        countryError != null ||
        emailError != null ||
        passwordError != null ||
        statusError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(nameError ?? phoneError ?? streetError ?? postalCodeError ?? countryError ?? emailError ?? passwordError ?? statusError!)),
      );
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
                errorText: Validators.validateName(_nameController.text),
              ),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                errorText: Validators.validatePhone(_phoneController.text),
              ),
            ),
            TextField(
              controller: _streetController,
              decoration: InputDecoration(
                labelText: 'Street',
                errorText: Validators.validateStreet(_streetController.text),
              ),
            ),
            TextField(
              controller: _postalCodeController,
              decoration: InputDecoration(
                labelText: 'Postal Code',
                errorText: Validators.validatePostalCode(_postalCodeController.text),
              ),
            ),
            TextField(
              controller: _countryController,
              decoration: InputDecoration(
                labelText: 'Country',
                errorText: Validators.validateCountry(_countryController.text),
              ),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: Validators.validateEmail(_emailController.text),
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: Validators.validatePassword(_passwordController.text),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to create user: Unknown error')),
                );
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
              final success = await widget.userController.createUser(newUser, _passwordController.text);
              if (success) {
                Navigator.pop(context);
                widget.userController.loadUsers();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User created successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to save user data')),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error creating user: $e')),
              );
            }
          },
          child: const Text('Save', style: TextStyle(color: Colors.green)),
        ),
      ],
    );
  }
}