import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hava_tahmini/search_page.dart';
import 'package:hava_tahmini/widgets/daily_weather_cards.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String location ='Ankara';
  double temperature = 0.0;
  int derece = 0;
  final String key = 'f4c6c570b50686646ed3d301c4408827';
  var locationData ;
  Position? devicePosition;
  String? icon ;
  List<String> icons = [];
  List<double> temperatures = [];
  List<String> dates = [];
  String abbr = 'c';
  List<String> abbrs = [];

Future<void> getDataFromAPI() async
{
  locationData = await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$key&units=metric'));
  final parsedLocation = jsonDecode(locationData.body);

  setState(() {
    temperature = parsedLocation['main']['temp'];
    location = parsedLocation['name'];
    //icon = parsedLocation['weather']['icon'];
    icon = parsedLocation['weather'].first['icon'];
    abbr = parsedLocation['weather'].first['main'];
    print(abbr);
  });
}

  Future<void> getDataFromAPIByLatlon() async
  {
    if (devicePosition != null) {
      locationData = await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=${devicePosition!.latitude}&lon=${devicePosition!.longitude}&appid=$key&units=metric'));
      final parsedLocation = jsonDecode(locationData.body);

      setState(() {
        temperature = parsedLocation['main']['temp'];
        location = parsedLocation['name'];
        icon = parsedLocation['weather']['icon'];
        abbr = parsedLocation['weather'].first['main'];
      });
    }
  }

Future<void> getDevicePositionFromAPI() async
{
  devicePosition = await _determinePosition();
}

void getInitialData() async
{
  await getDevicePositionFromAPI();
  await getDataFromAPI();
  //await getDailyForeCastByLatLon();
  await getDailyForeCastByLocation();
}

Future<void> getDailyForeCastByLatLon() async
{
var forecastData = await http.get(
    Uri.parse('https://api.openweathermap.org/data/2.5/forecast?lat=${devicePosition!.latitude}&lon=${devicePosition!.longitude}&appid=$key&units=metric'));
var forecastDataParse = jsonDecode(forecastData.body);
icons.clear();
temperatures.clear();
dates.clear();
abbrs.clear();

setState(() {
for(int i=0;i<40;i = i + 8)
  {
    temperatures.add(forecastDataParse['list'][i]['main']['temp']);
    icons.add(forecastDataParse['list'][i]['weather'][0]['icon']);
    dates.add(forecastDataParse['list'][i]['dt_txt']);
    //abbrs.add(forecastDataParse['consolidated_weather'][i]['weather_state_abbr']);
  }

});
}
  Future<void> getDailyForeCastByLocation() async
  {
    var forecastData = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$location&appid=$key&units=metric'));
    var forecastDataParse = jsonDecode(forecastData.body);
    icons.clear();
    temperatures.clear();
    dates.clear();


    setState(() {

      for(int i=0;i<40;i = i + 8)
      {
        temperatures.add(forecastDataParse['list'][i]['main']['temp']);
        icons.add(forecastDataParse['list'][i]['weather'][0]['icon']);
        dates.add(forecastDataParse['list'][i]['dt_txt']);
      }
    });
  }
@override
  void initState() {
   //getDevicePositionFromAPI();
   //getDataFromAPIByLatlon();
     getInitialData();
   //getDataFromAPI();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
  if(temperature == null) {

  }
  else
    {
      derece = temperature.ceil();
    }
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/$abbr.jpg'),
        fit: BoxFit.cover,
        ),
      ),
      child:
      (temperature == null || devicePosition == null || icons.isEmpty || dates.isEmpty || temperatures.isEmpty)
      ? Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                Text('Yükleniyor...',),

              ],
            ),
        
        ),
      )

      :Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 180,
                child: Image.network('https://openweathermap.org/img/wn/$icon@4x.png'),
              ),
              Text("$derece ° C",style: TextStyle(fontSize: 60,fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(location,
                      style: TextStyle(fontSize: 40)
                  ),
                  IconButton(onPressed: () async{
                    final selectedCity = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=> const SearchPage()));
                    print(selectedCity);
                    location = selectedCity;
                    getDataFromAPI();
                    getDailyForeCastByLocation();
                  }, icon: const Icon(Icons.search))
                ],
              ),
              buildWheatherCard(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget buildWheatherCard(BuildContext context) {

  List<DailyWeatherCard> cards= [];
  
  for(int i=0 ;i<5;i++)
    {
      cards.add(DailyWeatherCard(icon: icons[i], temperature: temperatures[i], date: dates[i]));
    }
    return SizedBox(
              height: MediaQuery.of(context).size.height * 0.20,
              width: MediaQuery.of(context).size.width * 0.90,
              child: ListView(
               scrollDirection: Axis.horizontal,
                children:  cards,
              ),
            );
  }





  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
