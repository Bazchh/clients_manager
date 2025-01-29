import 'package:clients_manager/src/features/user/data/repositories/user_repository.dart';
import 'package:clients_manager/src/features/user/data/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clients_manager/src/features/user/ui/widgets/client_list_widget.dart';
import 'package:clients_manager/src/features/user/ui/controllers/user_controller.dart';

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
        ),
        body: const ClientListWidget(),
      ),
    );
  }
}
