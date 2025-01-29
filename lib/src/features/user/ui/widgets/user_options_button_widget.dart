import 'package:flutter/material.dart';

class UserOptionsButton extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String userName;

  const UserOptionsButton({
    Key? key,
    required this.onEdit,
    required this.onDelete,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.edit, color: Colors.blue),
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'delete') {
          _confirmDelete(context);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Text('Edit User'),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete User'),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete $userName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
