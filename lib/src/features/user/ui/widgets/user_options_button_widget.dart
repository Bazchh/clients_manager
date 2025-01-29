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
          child: Text('Editar Usuário'),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Excluir Usuário'),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Usuário'),
        content: Text('Tem certeza de que deseja excluir $userName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
