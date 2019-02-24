import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_youtube/flutter_youtube.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterYoutubeViewController _controller;

  @override
  void initState() {
    super.initState();
  }

  void _onYoutubeCreated(FlutterYoutubeViewController controller) {
    this._controller = controller;
  }

  void _playVideo() {
    _controller.loadOrCueVideo('gcj2RUWQZ60');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Stack(
            children: <Widget>[
              Container(
                  child: FlutterYoutubeView(
                    onViewCreated: _onYoutubeCreated,
                  )),
              RaisedButton(
                onPressed: _playVideo,
                child: Text('Click play video'),
              )
            ],
          )),
    );
  }
}
