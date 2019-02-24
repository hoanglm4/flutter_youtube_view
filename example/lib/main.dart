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
                    listener: PlayerEventListenerImpl(),
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

class PlayerEventListenerImpl extends YouTubePlayerListener {
  @override
  void onCurrentSecond(double second) {
    print("onCurrentSecond second = $second");
  }

  @override
  void onError(String error) {
    print("onError error = $error");
  }

  @override
  void onReady() {
    print("onReady");
  }

  @override
  void onStateChange(String state) {
    print("onStateChange state = $state");
  }

  @override
  void onVideoDuration(double duration) {
    print("onVideoDuration duration = $duration");
  }
}
