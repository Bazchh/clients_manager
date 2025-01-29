import 'package:flutter/material.dart';
import 'package:clients_manager/src/features/user/domain/models/user_model.dart';
import 'package:clients_manager/src/features/user/ui/widgets/user_options_button_widget.dart';

class UserCard extends StatelessWidget {
  final int index;
  final ExtendedUser user;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const UserCard({
    Key? key,
    required this.index,
    required this.user,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Client Number
            CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Text(
                (index + 1).toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 16.0),
            // User Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name ?? 'Name not available',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    user.supabaseUser.email ?? 'Email not available',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    user.phone ?? 'Phone not available',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16.0),
            // Status
            Icon(
              user.status == Status.active ? Icons.check_circle : Icons.cancel,
              color: user.status == Status.active ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 16.0),
            // Options Button (Edit/Delete)
            UserOptionsButton(
              onEdit: onEdit,
              onDelete: onDelete,
              userName: user.name ?? 'User',
            ),
          ],
        ),
      ),
    );
  }
}
