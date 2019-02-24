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

  void _loadOrCueVideo() {
    _controller.loadOrCueVideo('gcj2RUWQZ60');
  }

  void _play() {}

  void _pause() {}

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
                params: YoutubeParam(
                    videoId: 'gcj2RUWQZ60', showUI: false, startSeconds: 0.0),
              )),
              Column(
                children: <Widget>[
                  RaisedButton(
                    onPressed: _loadOrCueVideo,
                    child: Text('Click reload video'),
                  ),
                  RaisedButton(
                    onPressed: _play,
                    child: Text('Play'),
                  ),
                  RaisedButton(
                    onPressed: _pause,
                    child: Text('Pause'),
                  )
                ],
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
