import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clients_manager/src/features/user/ui/widgets/user_card_widget.dart';
import 'package:clients_manager/src/features/user/ui/controllers/user_controller.dart';
import 'package:clients_manager/src/features/user/ui/widgets/edit_client_modal.dart';
import 'package:clients_manager/src/features/user/ui/widgets/create_client_modal.dart';
import 'package:another_flushbar/flushbar.dart';

class ClientListWidget extends StatelessWidget {
  const ClientListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);
    print(
        'Rebuilding ClientListWidget with users count: ${userController.users.length}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client List', style: TextStyle(fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await userController.loadUsers();
              if (userController.errorMessage == null) {
                _showFlushbar(context, 'Clients refreshed successfully!');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return CreateUserDialog(
                    userController:
                        Provider.of<UserController>(context, listen: false),
                    parentContext: context,
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          return userController.isLoading
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
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    )
                  : userController.users.isEmpty
                      ? const Center(child: Text('No clients found.'))
                      : ListView.builder(
                          itemCount: userController.users.length,
                          itemBuilder: (listContext, index) {
                            final user = userController.users[index];
                            return UserCard(
                              index: index,
                              user: user,
                              onEdit: () => showDialog(
                                context: context,
                                builder: (dialogContext) => EditUserDialog(
                                  user: user,
                                  userController: userController,
                                  parentContext: context,
                                ),
                              ),
                              onDelete: () async {
                                bool success =
                                    await userController.deleteUser(user.id);
                                if (success) {
                                  _showFlushbar(
                                      context, 'Deleted user: ${user.name}');
                                } else {
                                  _showFlushbar(
                                      context, 'Failed to delete user.');
                                }
                              },
                            );
                          },
                        );
        },
      ),
    );
  }

  void _showFlushbar(BuildContext context, String message) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.BOTTOM,
      backgroundColor: Colors.red,
      borderRadius: BorderRadius.circular(8),
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
    ).show(context);
  }
}
