import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clients_manager/src/features/weather/ui/pages/weather_home_page.dart';
import 'package:clients_manager/src/features/user/ui/pages/clients_home_page.dart';
import 'package:clients_manager/src/features/user/ui/controllers/user_controller.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(
      builder: (context, userController, child) {
        print('MainScreen rebuilt with users count: ${userController.users.length}');
        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              WeatherHomePage(),
              ClientsHomePage(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: [
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
      },
    );
  }
}