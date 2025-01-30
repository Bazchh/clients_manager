import 'package:flutter/material.dart';
import 'package:clients_manager/src/features/user/domain/models/user_model.dart';
import 'package:clients_manager/src/features/user/ui/controllers/user_controller.dart';
import 'package:clients_manager/src/features/user/data/validators/user_validators.dart';

class EditUserDialog extends StatefulWidget {
  final ExtendedUser user;
  final UserController userController;

  const EditUserDialog({
    Key? key,
    required this.user,
    required this.userController,
  }) : super(key: key);

  @override
  _EditUserDialogState createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;
  late TextEditingController _emailController;
  late Status _selectedStatus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
    _streetController = TextEditingController(text: widget.user.street);
    _postalCodeController = TextEditingController(text: widget.user.postalCode);
    _countryController = TextEditingController(text: widget.user.country);
    _emailController = TextEditingController(text: widget.user.email);
    _selectedStatus = widget.user.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    final nameError = Validators.validateName(_nameController.text);
    final phoneError = Validators.validatePhone(_phoneController.text);
    final streetError = Validators.validateStreet(_streetController.text);
    final postalCodeError =
        Validators.validatePostalCode(_postalCodeController.text);
    final countryError = Validators.validateCountry(_countryController.text);
    final statusError = Validators.validateStatus(_selectedStatus);

    if (nameError != null ||
        phoneError != null ||
        streetError != null ||
        postalCodeError != null ||
        countryError != null ||
        statusError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(nameError ??
                phoneError ??
                streetError ??
                postalCodeError ??
                countryError ??
                statusError!)),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit User'),
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
                errorText:
                    Validators.validatePostalCode(_postalCodeController.text),
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
              decoration: const InputDecoration(labelText: 'Email'),
              readOnly: true,
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
                  child: Text(status.name.toUpperCase()),
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

            final updatedUser = widget.user.copyWith(
              name: _nameController.text,
              phone: _phoneController.text,
              street: _streetController.text,
              postalCode: _postalCodeController.text,
              country: _countryController.text,
              status: _selectedStatus,
            );

            await widget.userController.editUser(updatedUser);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User updated successfully')),
            );
          },
          child: const Text('Save', style: TextStyle(color: Colors.green)),
        ),
      ],
    );
  }
}
