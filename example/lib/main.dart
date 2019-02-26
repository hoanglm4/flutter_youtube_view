import 'package:flutter/material.dart';
import 'YoutubeCustomWidget.dart';
import 'YoutubeDefaultWidget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: <String, WidgetBuilder>{
        '/custom': (BuildContext context) => new YoutubeCustomWidget(),
        '/non_custom': (BuildContext context) => new YoutubeDefaultWidget(),
      },
      home: HomeScreen()
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Youtube player')),
      body: Center(
        child: Column(children: <Widget>[
          RaisedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/custom');
            },
            child: Text('Open non custom player'),
          ),
          RaisedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/non_custom');
            },
            child: Text('Open custom player'),
          ),
        ]),
      ),
    );
  }
}