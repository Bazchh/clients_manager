import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:clients_manager/src/features/user/ui/controllers/user_controller.dart';
import 'package:clients_manager/src/features/user/data/services/user_service.dart';
import 'package:clients_manager/src/features/user/data/repositories/user_repository.dart';
import 'package:clients_manager/src/home/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Garante que o Flutter esteja inicializado
  await _initializeSupabase();
  runApp(const MyApp());
}

/// Função auxiliar para inicializar o Supabase
Future<void> _initializeSupabase() async {
  try {
    await Supabase.initialize(
      url: 'https://ttxorfpxadojffxpgbub.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR0eG9yZnB4YWRvamZmeHBnYnViIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczNzg1MjA5NiwiZXhwIjoyMDUzNDI4MDk2fQ.kD2_ADwhNPbSyPdB81gOljbnlMq4N7XAXA79GrxCqyM',
    );

    // Autentica o usuário de serviço
    final supabase = Supabase.instance.client;
    await supabase.auth.signInWithPassword(
      email: 'service_user@gmail.com',
      password: '123456789',
    );
    print('Usuário de serviço autenticado com sucesso.');
  } catch (e) {
    print('Erro ao inicializar o Supabase ou autenticar usuário: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeSupabase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child:
                    Text('Erro ao inicializar o Supabase: ${snapshot.error}'),
              ),
            ),
          );
        } else {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) {
                  final userController =
                      UserController(UserService(UserRepository()));
                  userController
                      .loadUsers(); // Carrega os usuários automaticamente
                  return userController;
                },
              ),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Clients Manager',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: MainScreen(),
            ),
          );
        }
      },
    );
  }
}
