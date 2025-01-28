import 'package:flutter/material.dart';
import 'package:clients_manager/src/features/user/domain/models/user_model.dart';
import 'package:clients_manager/src/features/user/data/services/user_service.dart';
import 'package:clients_manager/src/features/user/ui/widgets/user_card_widget.dart';

class ClientListWidget extends StatefulWidget {
  final UserService userService;

  const ClientListWidget({Key? key, required this.userService}) : super(key: key);

  @override
  State<ClientListWidget> createState() => _ClientListWidgetState();
}

class _ClientListWidgetState extends State<ClientListWidget> {
  late Future<List<ExtendedUser>> _clientsFuture;

  @override
  void initState() {
    super.initState();
    _clientsFuture = widget.userService.getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client List'),
      ),
      body: FutureBuilder<List<ExtendedUser>>(
        future: _clientsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No clients found.'));
          }

          final clients = snapshot.data!;

          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) {
              return UserCard(
                index: index,
                user: clients[index],
              );
            },
          );
        },
      ),
    );
  }
}
