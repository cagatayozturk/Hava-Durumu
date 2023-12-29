import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  String selectedCity = '';
  var response;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/search.jpg'),
        fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:  [
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 60),
                child: TextField(
                  onChanged: (value){
                    selectedCity = value ;
                  },
                  decoration: InputDecoration(
                      hintText: 'Şehir Seçiniz',
                      border: OutlineInputBorder(borderSide: BorderSide.none)
                  ),
                  style: TextStyle(fontSize: 30, color: Colors.white,fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(onPressed: () async{
                final String key = 'f4c6c570b50686646ed3d301c4408827';
                response = await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$selectedCity&appid=$key&units=metric'));
              if(response.statusCode == 200)
              {
                Navigator.pop(context,selectedCity);
              }
              else
                {
                  _showMyDialog();
                }
                //Navigator.pop(context,selectedCity);
              },
                  style: ElevatedButton.styleFrom(primary: Colors.blueGrey),
                  child: const Text(
                    'Şehir Seç',
                     style: TextStyle(color : Colors.black)))
            ],

          ),
        ),
      ),
    );
  }
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Şehir Bulunamadı!'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Lütfen Geçerli Bir Şehir Giriniz.')

              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
