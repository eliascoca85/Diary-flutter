import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  Map<String, dynamic>? weatherData;
  bool loading = false;
  String city = "Cochabamba,BO";
  String? errorMsg;
  bool _hasConnection = true;
  final TextEditingController _controller =
      TextEditingController(text: "Cochabamba,BO");

  Future<void> _fetchWeather([String? newCity]) async {
    if (!mounted) return; // Verificar si el widget sigue montado

    setState(() {
      loading = true;
      errorMsg = null;
    });

    final service = WeatherService();

    // Verificar conexión a internet primero
    final hasConnection = await service.hasInternetConnection();

    if (!hasConnection) {
      if (!mounted) return;
      setState(() {
        loading = false;
        _hasConnection = false;
        errorMsg = "Sin conexión a internet";
      });
      return;
    }

    setState(() {
      _hasConnection = true;
    });

    final queryCity = newCity ?? city;

    try {
      final data = await service.fetchWeatherByCity(queryCity);

      if (!mounted) return; // Verificar nuevamente antes de setState

      if (data == null) {
        setState(() {
          weatherData = null;
          loading = false;
          errorMsg =
              "No se pudo cargar el clima para '$queryCity'. Verifica el nombre.";
        });
      } else {
        setState(() {
          weatherData = data;
          city = queryCity;
          loading = false;
          errorMsg = null;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        if (e.toString().contains('Sin conexión a internet')) {
          _hasConnection = false;
          errorMsg = 'Sin conexión a internet';
        } else if (e.toString().contains('TimeoutException')) {
          errorMsg = 'Tiempo de espera agotado (5 segundos)';
        } else {
          errorMsg = 'Error al cargar el clima';
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    // No mostrar el widget si no hay conexión a internet
    if (!_hasConnection) {
      return const SizedBox.shrink();
    }

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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark
            ? Colors.grey[800]!
                .withOpacity(0.15) // Casi transparente en modo oscuro
            : Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).shadowColor.withOpacity(isDark ? 0.05 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input para ciudad/departamento
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Ciudad o Departamento (,PAÍS)',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.white.withOpacity(0.3)
                            : Colors.grey[400]!,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.white.withOpacity(0.2)
                            : Colors.grey[300]!,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color(0xFF007C91),
                        width: 2,
                      ),
                    ),
                    isDense: true,
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white.withOpacity(0.7) : null,
                    ),
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.white.withOpacity(0.9) : null,
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      _fetchWeather(value.trim());
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () {
                        if (_controller.text.trim().isNotEmpty) {
                          _fetchWeather(_controller.text.trim());
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007C91),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Buscar'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (loading) const Center(child: CircularProgressIndicator()),
          if (errorMsg != null)
            Center(
              child: Column(
                children: [
                  Text(
                    errorMsg!,
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _fetchWeather(_controller.text.trim()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007C91),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (!loading && errorMsg == null && weatherData != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color),
                          ),
                          const SizedBox(height: 2),
                          Text(day,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color)),
                          Text(date,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.water_drop,
                                  size: 14,
                                  color: Theme.of(context).iconTheme.color),
                              const SizedBox(width: 4),
                              Text(
                                weatherData!["main"]?["humidity"] != null
                                    ? "${weatherData!["main"]["humidity"]}%"
                                    : "-",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
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
                            Icon(Icons.arrow_downward,
                                size: 16,
                                color: Theme.of(context).iconTheme.color),
                            Text(
                              weatherData!["main"]?["temp_min"] != null
                                  ? "${weatherData!["main"]["temp_min"].round()}°"
                                  : "-",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.arrow_upward,
                                size: 16,
                                color: Theme.of(context).iconTheme.color),
                            Text(
                              weatherData!["main"]?["temp_max"] != null
                                  ? "${weatherData!["main"]["temp_max"].round()}°"
                                  : "-",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    iconUrl != null
                        ? Image.network(
                            iconUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.cloud,
                                size: 60,
                                color: Theme.of(context).iconTheme.color),
                          )
                        : Icon(Icons.cloud,
                            size: 60, color: Theme.of(context).iconTheme.color),
                    const SizedBox(width: 16),
                    Text(
                      weatherData!["main"]?["temp"] != null
                          ? "${weatherData!["main"]["temp"].round()}°"
                          : "-",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                          color:
                              Theme.of(context).textTheme.headlineLarge?.color),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    (weatherData!["weather"][0]["description"] ?? "-")
                        .toString()
                        .toUpperCase(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).textTheme.titleLarge?.color),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
