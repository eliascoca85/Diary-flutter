import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({Key? key}) : super(key: key);

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  Map<String, dynamic>? weatherData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    final service = WeatherService();
    final data = await service.fetchWeatherByCity('La Paz,BO');
    setState(() {
      weatherData = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekDays = [
      'DOMINGO',
      'LUNES',
      'MARTES',
      'MIÉRCOLES',
      'JUEVES',
      'VIERNES',
      'SÁBADO'
    ];
    String day = weekDays[now.weekday % 7];
    String date =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";

    String? iconCode =
        weatherData != null ? weatherData!["weather"][0]["icon"] : null;
    String? iconUrl = iconCode != null
        ? "https://openweathermap.org/img/wn/$iconCode@4x.png"
        : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFc6e6f7), Color(0xFFeaf6fa)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : weatherData == null
              ? const Text('No se pudo cargar el clima',
                  style: TextStyle(color: Colors.red))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top: city, day, date, min/max temp
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (weatherData!["name"] ?? "CITY NAME")
                                    .toString()
                                    .toUpperCase(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black),
                              ),
                              const SizedBox(height: 2),
                              Text(day,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              Text(date,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.water_drop,
                                      size: 18, color: Colors.black),
                                  const SizedBox(width: 4),
                                  Text(
                                    weatherData!["main"]?["humidity"] != null
                                        ? "${weatherData!["main"]["humidity"]}%"
                                        : "-",
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.arrow_downward,
                                    size: 16, color: Colors.black),
                                Text(
                                  weatherData!["main"]?["temp_min"] != null
                                      ? "${weatherData!["main"]["temp_min"].round()}°"
                                      : "-",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_upward,
                                    size: 16, color: Colors.black),
                                Text(
                                  weatherData!["main"]?["temp_max"] != null
                                      ? "${weatherData!["main"]["temp_max"].round()}°"
                                      : "-",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Middle: icon and temperature centered
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        iconUrl != null
                            ? Image.network(
                                iconUrl,
                                width: 90,
                                height: 90,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.cloud,
                                        size: 90, color: Colors.black),
                              )
                            : const Icon(Icons.cloud,
                                size: 90, color: Colors.black),
                        const SizedBox(width: 24),
                        Text(
                          weatherData!["main"]?["temp"] != null
                              ? "${weatherData!["main"]["temp"].round()}°"
                              : "-",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 56,
                              color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Description centered and bold
                    Center(
                      child: Text(
                        (weatherData!["weather"][0]["description"] ?? "-")
                            .toString()
                            .toUpperCase(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                            color: Colors.black),
                      ),
                    ),
                  ],
                ),
    );
  }
}
