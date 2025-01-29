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
            // Número do Cliente
            CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Text(
                (index + 1).toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 16.0),
            // Informações do Usuário
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name ?? 'Nome não disponível',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    user.supabaseUser.email ?? 'E-mail não disponível',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    user.phone ?? 'Telefone não disponível',
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
            // Botão de Opções (Editar/Excluir)
            UserOptionsButton(
              onEdit: onEdit,
              onDelete: onDelete,
              userName: user.name ?? 'Usuário',
            ),
          ],
        ),
      ),
    );
  }
}
