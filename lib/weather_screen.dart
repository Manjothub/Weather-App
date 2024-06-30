import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:http/http.dart' as http;
import 'secrets.dart'; // Import your API key here

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  double temp = 0;
  bool isLoading = true;
  String errorMessage = ''; // Track error message

  @override
  void initState() {
    super.initState();
    getCurrentWeather();
  }

  Future<void> getCurrentWeather() async {
    try {
      String cityName = 'London';
      final res = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$openWeatherAPIKey'));
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        setState(() {
          temp = data['main']['temp'];
          isLoading = false;
          errorMessage = ''; // Clear any previous errors
        });
      } else {
        throw 'Error fetching data: ${data['message']}';
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load data. Please check your connection and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        title: const Text(
          'Weather Forecast',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              print('Refresh');
              getCurrentWeather();
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator.adaptive())
          : errorMessage.isNotEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      )
          : SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCurrentWeather(),
            const SizedBox(height: 20),
            _buildHourlyWeather(),
            const SizedBox(height: 20),
            _buildWeeklyForecast(),
            const SizedBox(height: 20),
            _buildAdditionalInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeather() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'London', // Replace with actual city name
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const BoxedIcon(WeatherIcons.day_sunny, size: 70, color: Colors.yellow),
          const SizedBox(height: 10),
          Text(
            '$temp°C', // Display actual temperature fetched from API
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Text(
            'Sunny', // Replace with actual weather description
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildWeatherInfo(WeatherIcons.strong_wind, 'Wind', '5 km/h'),
              _buildWeatherInfo(WeatherIcons.humidity, 'Humidity', '65%'),
              _buildWeatherInfo(WeatherIcons.barometer, 'Pressure', '1015 hPa'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        BoxedIcon(icon, size: 30, color: Colors.white),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.white70)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildHourlyWeather() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildHourlyWeatherCard('Now', '25°C'),
          _buildHourlyWeatherCard('2 PM', '27°C'),
          _buildHourlyWeatherCard('4 PM', '28°C'),
          _buildHourlyWeatherCard('6 PM', '26°C'),
          _buildHourlyWeatherCard('8 PM', '24°C'),
        ],
      ),
    );
  }

  Widget _buildHourlyWeatherCard(String time, String temperature) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              time,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              temperature,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyForecast() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '7-Day Forecast',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemCount: 7,
            itemBuilder: (context, index) {
              return _buildDayWeatherCard(
                _getDayOfWeek(index),
                _getTemperature(index),
                _getWeatherIcon(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayWeatherCard(String day, String temperature, IconData iconData) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          BoxedIcon(
            iconData,
            size: 30,
            color: Colors.yellow,
          ),
          const SizedBox(height: 8),
          Text(
            temperature,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _getDayOfWeek(int index) {
    return ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'][index % 7];
  }

  String _getTemperature(int index) {
    return ['30°C', '28°C', '29°C', '31°C', '29°C', '27°C', '26°C'][index % 7];
  }

  IconData _getWeatherIcon(int index) {
    return [
      WeatherIcons.day_sunny,
      WeatherIcons.day_cloudy,
      WeatherIcons.day_sunny,
      WeatherIcons.day_rain,
      WeatherIcons.day_lightning,
      WeatherIcons.day_sunny,
      WeatherIcons.day_cloudy,
    ][index % 7];
  }

  Widget _buildAdditionalInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional Information',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          _buildAdditionalInfoItem(Icons.wb_sunny, 'Sunrise', '6:00 AM'),
          _buildAdditionalInfoItem(Icons.wb_twilight, 'Sunset', '7:30 PM'),
          _buildAdditionalInfoItem(Icons.brightness_5, 'UV Index', 'High'),
          _buildAdditionalInfoItem(Icons.visibility, 'Visibility', '10 km'),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
