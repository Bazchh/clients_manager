import 'package:clients_manager/src/features/user/data/repositories/user_repository.dart';
import 'package:clients_manager/src/features/user/data/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clients_manager/src/features/user/ui/widgets/client_list_widget.dart';
import 'package:clients_manager/src/features/user/ui/controllers/user_controller.dart';
import 'package:clients_manager/src/features/user/ui/widgets/create_client_modal.dart'; // Importando o dialog

class ClientsHomePage extends StatelessWidget {
  const ClientsHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserController(UserService(UserRepository()))..loadUsers(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Clients List"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return CreateUserDialog(
                      userController: Provider.of<UserController>(context, listen: false),
                    );
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                Provider.of<UserController>(context, listen: false).loadUsers();
              },
            ),
          ],
        ),
        body: Consumer<UserController>(
          builder: (context, controller, child) {
            if (controller.users.isEmpty) {
              return const Center(
                child: Text("No clients found. Pull to refresh or add a new client."),
              );
            }
            return const ClientListWidget();
          },
        ),
      ),
    );
  }
}