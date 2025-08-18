import 'package:flutter/material.dart';
import '../components/weather_card.dart';
import '../components/empty_diary.dart';
import '../components/bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Icon(Icons.phone_iphone, color: Color(0xFF007C91)),
        ),
        title: const Text('Mi Diario',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 18,
            )),
        actions: [
          IconButton(
              icon: const Icon(Icons.search, color: Colors.black87, size: 28),
              onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.nightlight_round,
                  color: Colors.black87, size: 28),
              onPressed: () {
                // Aquí irá la lógica para cambiar a modo oscuro
              }),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: WeatherCard(),
          ),
          const SizedBox(height: 16),
          const EmptyDiary(),
        ],
      ),
      bottomNavigationBar: const BottomNav(),
      backgroundColor: Colors.white,
    );
  }
}
