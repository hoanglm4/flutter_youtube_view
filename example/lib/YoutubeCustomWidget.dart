import 'package:flutter/material.dart';
import 'package:flutter_youtube_view/flutter_youtube_view.dart';

class YoutubeCustomWidget extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<YoutubeCustomWidget>
    implements YouTubePlayerListener {
  double _volume = 50;
  double _videoDuration = 0.0;
  double _currentVideoSecond = 0.0;
  String _playerState = "";
  FlutterYoutubeViewController _controller;

  @override
  void onCurrentSecond(double second) {
    print("onCurrentSecond second = $second");
    _currentVideoSecond = second;
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

  void _play() {
    _controller.play();
  }

  void _pause() {
    _controller.pause();
  }

  void _seekTo(double time) {
    _controller.seekTo(time);
  }

  void _setVolume(int volumePercent) {
    _controller.setVolume(volumePercent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Custom UI')
        ),
        body: Stack(
          children: <Widget>[
            Container(
                child: FlutterYoutubeView(
              onViewCreated: _onYoutubeCreated,
              listener: this,
              params: YoutubeParam(
                  videoId: 'gcj2RUWQZ60', showUI: false, startSeconds: 0.0),
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
                RaisedButton(
                  onPressed: _play,
                  child: Text('Play'),
                ),
                RaisedButton(
                  onPressed: _pause,
                  child: Text('Pause'),
                ),
                SliderVolume(
                    volumeValue: _volume,
                    onChanged: (double value) {
                      setState(() {
                        _volume = value;
                        _setVolume(_volume.round());
                      });
                    })
              ],
            )
          ],
        ));
  }
}

typedef void VolumeChangedCallback(double value);

class SliderVolume extends StatelessWidget {
  SliderVolume({this.volumeValue, this.onChanged});

  final double volumeValue;
  final VolumeChangedCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      Text(
        'Volume ${volumeValue.round()}',
        style: TextStyle(color: Colors.blue),
      ),
      Expanded(
          child: Slider(
              value: volumeValue, onChanged: onChanged, min: 0.0, max: 100))
    ]);
  }
}
