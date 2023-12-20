import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'additional_info_item.dart';
import 'hourly_forcast_item.dart';
import 'secrets.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  TextEditingController cityNameController = TextEditingController();

  bool isFirstLoad = true;

  late Future<Map<String, dynamic>> weatherData;

  Future<Map<String, dynamic>> getCurrentWeather(String cityName) async {
    try {
      // String cityName = 'Dhaka';
      final result = await http.get(
        Uri.parse(
            'http://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey'),
      );
      final data = jsonDecode(result.body);

      if (data['cod'] != '200') {
        throw 'An unexpected eroor occured.';
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstLoad) {
      // Initial request, set default city name or use your logic
      weatherData = getCurrentWeather('Dhaka');
      isFirstLoad = false;
    }
    return Scaffold(
      // appbar
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              'Weather App',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            // const SizedBox(height: 4),
            // TextField(
            //   controller: cityNameController,
            //   decoration: InputDecoration(
            //     hintText: 'Enter city name',
            //   ),
            // ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                // Use the entered city name
                final cityName = cityNameController.text;
                // Call the API with the dynamic city name
                getCurrentWeather(cityName);
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      //body
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: cityNameController,
              decoration: const InputDecoration(
                hintText: 'Enter city name',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 30, vertical: 5),
              ),
            ),
            FutureBuilder(
              future: getCurrentWeather(cityNameController.text),
              builder: (context, snapshot) {
                // print(snapshot);
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }

                //all weather data from weather api

                final data = snapshot.data!;
                final cureentweatherdata = data['list'][0];
                final currentTemp =
                    ((cureentweatherdata['main']['temp']) - 273.15).round();
                final currentSky = cureentweatherdata["weather"][0]['main'];
                final currentPressure = cureentweatherdata['main']['pressure'];
                final currentWindSpeed = cureentweatherdata['wind']['speed'];
                final currentHumidity = cureentweatherdata['main']['humidity'];

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //main card
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text(
                                      '$currentTemp °C',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    Icon(
                                      currentSky == 'Clouds' ||
                                              currentSky == 'Rain'
                                          ? Icons.cloud
                                          : Icons.sunny,
                                      size: 64,
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    Text(
                                      currentSky,
                                      style: const TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      //wetaher forcast card
                      const Text(
                        'Hourly forcast',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          itemCount: 5,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final hourlyForecast = data['list'][index + 1];
                            final hourlySky =
                                data['list'][index + 1]['weather'][0]['main'];
                            final hourlyTemp =
                                hourlyForecast['main']['temp'].toString();
                            final time =
                                DateTime.parse(hourlyForecast['dt_txt']);
                            return HourlyForcastItem(
                              //00:30
                              time: DateFormat.j().format(time),
                              temperature: hourlyTemp,
                              icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                                  ? Icons.cloud
                                  : Icons.sunny,
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 26,
                      ),
                      //additional information  card
                      const Text(
                        'Additional Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          AdditionalInfoItem(
                            icon: Icons.water_drop,
                            label: 'Humidity',
                            value: currentHumidity.toString(),
                          ),
                          AdditionalInfoItem(
                            icon: Icons.air,
                            label: 'Wind Speed',
                            value: currentWindSpeed.toString(),
                          ),
                          AdditionalInfoItem(
                            icon: Icons.beach_access,
                            label: 'Pressure',
                            value: currentPressure.toString(),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
