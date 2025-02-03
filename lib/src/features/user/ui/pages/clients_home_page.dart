import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clients_manager/src/features/user/ui/widgets/client_list_widget.dart';
import 'package:clients_manager/src/features/user/ui/controllers/user_controller.dart';

class ClientsHomePage extends StatelessWidget {
  const ClientsHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(
      builder: (context, userController, child) {
        print(
            'ClientsHomePage rebuilt with users count: ${userController.users.length}');
        return Scaffold(
          appBar: AppBar(
            title: const Text("Client Manager"),
            centerTitle: true,
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
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    )
                  : userController.users.isEmpty
                      ? const Center(
                          child: Text(
                              "No clients found. Pull to refresh or add a new client."),
                        )
                      : ClientListWidget(),
        );
      },
    );
  }
}
