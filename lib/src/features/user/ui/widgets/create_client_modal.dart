import 'package:flutter/material.dart';
import 'package:clients_manager/src/features/user/domain/models/user_model.dart';
import 'package:clients_manager/src/features/user/ui/controllers/user_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  late TextEditingController _passwordController;  // Para senha
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
    _passwordController = TextEditingController(); // Adicionando o controlador de senha
    _selectedStatus = Status.active; // Define a status default, pode ser ajustado
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _emailController.dispose();
    _passwordController.dispose(); // Descartando o controlador de senha
    super.dispose();
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
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: _streetController,
              decoration: const InputDecoration(labelText: 'Street'),
            ),
            TextField(
              controller: _postalCodeController,
              decoration: const InputDecoration(labelText: 'Postal Code'),
            ),
            TextField(
              controller: _countryController,
              decoration: const InputDecoration(labelText: 'Country'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
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
            // Criar o usuário no Supabase com email e senha
            final response = await Supabase.instance.client.auth.signUp(
              _emailController.text,
              _passwordController.text,
            );

            if (response.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to create user: ${response.error!.message}')),
              );
              return;
            }

            // Usar o supabaseUser para criar o ExtendedUser
            final newUser = ExtendedUser(
              supabaseUser: response.user!,  // O supabaseUser retornado ao criar o usuário
              name: _nameController.text,
              phone: _phoneController.text,
              street: _streetController.text,
              postalCode: _postalCodeController.text,
              country: _countryController.text,
              status: _selectedStatus,
            );

            final success = await widget.userController.createUser(newUser);
            if (success) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User created successfully')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to create user')),
              );
            }
          },
          child: const Text('Save', style: TextStyle(color: Colors.green)),
        ),
      ],
    );
  }
}
