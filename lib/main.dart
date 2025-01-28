import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clients_manager/src/features/home/home_page.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://ttxorfpxadojffxpgbub.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR0eG9yZnB4YWRvamZmeHBnYnViIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc4NTIwOTYsImV4cCI6MjA1MzQyODA5Nn0.bHp-RY0eu_8dbX5iCvWk-_9ylucaJVPN9PzmuN2_Avk',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Supabase App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}
