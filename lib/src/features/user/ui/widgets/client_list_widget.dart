import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clients_manager/src/features/user/ui/widgets/user_card_widget.dart';
import 'package:clients_manager/src/features/user/ui/controllers/user_controller.dart';
import 'package:clients_manager/src/features/user/ui/widgets/edit_client_modal.dart';

class ClientListWidget extends StatelessWidget {
  const ClientListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await userController.loadUsers();
              if (userController.errorMessage == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Clients refreshed successfully!')),
                );
              }
            },
          ),
        ],
      ),
      body: userController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userController.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(userController.errorMessage!),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => userController.loadUsers(),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : userController.users.isEmpty
                  ? const Center(child: Text('No clients found.'))
                  : ListView.builder(
                      itemCount: userController.users.length,
                      itemBuilder: (context, index) {
                        final user = userController.users[index];
                        return UserCard(
                          index: index,
                          user: user,
                          onEdit: () => showDialog(
                            context: context,
                            builder: (context) => EditUserDialog(
                              user: user,
                              userController: userController,
                            ),
                          ),
                          onDelete: () async {
                            bool success = await userController.deleteUser(user.supabaseUser.id);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Deleted user: ${user.name}'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to delete user.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
    );
  }
}
