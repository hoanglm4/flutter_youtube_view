import 'package:flutter/material.dart';
import 'package:flutter_youtube/flutter_youtube.dart';

class YoutubeDefaultWidget extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<YoutubeDefaultWidget>
    implements YouTubePlayerListener {
  double _currentVideoSecond = 0.0;
  String _playerState = "";
  FlutterYoutubeViewController _controller;

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
    setState(() {
      _playerState = state;
    });
  }

  @override
  void onVideoDuration(double duration) {
    print("onVideoDuration duration = $duration");
  }

  void _onYoutubeCreated(FlutterYoutubeViewController controller) {
    this._controller = controller;
  }

  void _loadOrCueVideo() {
    _controller.loadOrCueVideo('gcj2RUWQZ60', _currentVideoSecond);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Default UI')
        ),
        body: Stack(
          children: <Widget>[
            Container(
                child: FlutterYoutubeView(
              onViewCreated: _onYoutubeCreated,
              listener: this,
              params: YoutubeParam(
                  videoId: 'gcj2RUWQZ60', showUI: true, startSeconds: 0.0),
            )),
            Column(
              children: <Widget>[
                Text(
                  'Current state: $_playerState',
                  style: TextStyle(color: Colors.blue),
                ),
                RaisedButton(
                  onPressed: _loadOrCueVideo,
                  child: Text('Click reload video'),
                ),
              ],
            )
          ],
        ));
  }
}
