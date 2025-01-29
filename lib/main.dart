import 'package:flutter/material.dart';
import 'package:clients_manager/src/features/weather/ui/controllers/weather_controller.dart';
import 'package:clients_manager/src/features/weather/data/services/weather_service.dart';
import 'package:clients_manager/src/features/weather/ui/widgets/weather_card_widget.dart';
import 'package:clients_manager/src/features/weather/data/repositories/weather_repository.dart';
import 'package:clients_manager/src/features/user/ui/pages/clients_home_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';  // Adicionando o Provider aqui
import 'package:clients_manager/src/features/user/ui/controllers/user_controller.dart';
import 'package:clients_manager/src/features/user/data/services/user_service.dart'; 
import 'package:clients_manager/src/features/user/data/repositories/user_repository.dart';  

// Sua chave e URL do Supabase
Future<void> main() async {
  await Supabase.initialize(
    url: 'https://ttxorfpxadojffxpgbub.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR0eG9yZnB4YWRvamZmeHBnYnViIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc4NTIwOTYsImV4cCI6MjA1MzQyODA5Nn0.bHp-RY0eu_8dbX5iCvWk-_9ylucaJVPN9PzmuN2_Avk',
  );

  // Envolvendo o MaterialApp com o ChangeNotifierProvider para o UserController
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserController(UserService(UserRepository())), // Assumindo que você tenha o UserController pronto
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clients Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const WeatherHomePage(),
    const ClientsHomePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: "Weather",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Clients",
          ),
        ],
      ),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({Key? key}) : super(key: key);

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  late final WeatherController _weatherController;

  @override
  void initState() {
    super.initState();
    _weatherController = WeatherController(
      weatherService: WeatherService(repository: WeatherRepository(apiKey: 'b3d14b11fac0617b3e39b2e1624b03f5')),
    );
    
    _weatherController.fetchDailyWeather(
      latitude: 37.0154,
      longitude: -7.9352,
      lang: 'en',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Weather situation for Faro today",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 16.0),
            WeatherCard(controller: _weatherController),
          ],
        ),
      ),
    );
  }
}
