import 'package:flutter/material.dart';
class DailyWeatherCard extends StatelessWidget {
  const DailyWeatherCard({Key? key, required this.icon, required this.temperature, required this.date}) : super(key : key);
    final String icon ;
    final double temperature ;
    final String date;
  @override
  Widget build(BuildContext context) {

  DateTime parsedTime = DateTime.parse(date);
  parsedTime.weekday;
  List<String> weekdays = ["Pazartesi","Salı","Çarşamba","Perşembe","Cuma","Cumartesi","Pazartesi"];
  int derece = 0;
  if(temperature == null) {

  }
  else
  {
    derece = temperature.ceil();
  }
    return Card(
      color: Colors.transparent,
      child: SizedBox(
        height: 120,
        width: 70,
        child: Column(
          children: [
            Image.network('https://openweathermap.org/img/wn/$icon.png'),
            Text(
                "$derece ° C",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold)
            ),
            Text(weekdays[parsedTime.weekday- 1]),
          ],
        ),
      ),
    );
  }
}
