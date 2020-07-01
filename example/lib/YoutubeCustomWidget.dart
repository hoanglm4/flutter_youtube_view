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
  YoutubeScaleMode _mode = YoutubeScaleMode.none;
  PlaybackRate _playbackRate = PlaybackRate.RATE_1;
  bool _isMuted = false;

  @override
  void onCurrentSecond(double second) {
   // print("onCurrentSecond second = $second");
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

  void _changeScaleMode(YoutubeScaleMode mode) {
    setState(() {
        _mode = mode;
        _controller.changeScaleMode(mode);
    });
  }

  void _changeVolumeMode(bool isMuted) {
    setState(() {
      _isMuted = isMuted;
      if (isMuted) {
        _controller.setMute();
      } else {
        _controller.setUnMute();
      }
    });
  }

  void _changePlaybackRate(PlaybackRate playbackRate) {
    setState(() {
      _playbackRate = playbackRate;
      _controller.setPlaybackRate(rate: playbackRate);
    });
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
                  scaleMode: _mode,
                  onViewCreated: _onYoutubeCreated,
                  listener: this,
                  params: YoutubeParam(
                      videoId: 'gcj2RUWQZ60',
                      showUI: false,
                      startSeconds: 0.0,
                      autoPlay: false,
                  ),
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
                _buildControl(),
                _buildVolume(),
                _buildScaleModeRadioGroup(),
                _buildPlaybackRate()
              ],
            )
          ],
        ));
  }

  Widget _buildControl() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        RaisedButton(
          onPressed: _play,
          child: Text('Play'),
        ),
        RaisedButton(
          onPressed: _pause,
          child: Text('Pause'),
        ),
        RaisedButton(
          onPressed: () {
            _seekTo(20.0);
          },
          child: Text('seekTo 20s'),
        )
      ],
    );
  }

  Widget _buildScaleModeRadioGroup() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Radio(
          value: YoutubeScaleMode.none,
          groupValue: _mode,
          onChanged: _changeScaleMode,
        ),
        new Text(
          'none',
          style: TextStyle(color: Colors.blue),
        ),
        new Radio(
          value: YoutubeScaleMode.fitWidth,
          groupValue: _mode,
          onChanged: _changeScaleMode,
        ),
        new Text(
          'fitWidth',
          style: TextStyle(color: Colors.blue),
        ),
        new Radio(
          value: YoutubeScaleMode.fitHeight,
          groupValue: _mode,
          onChanged: _changeScaleMode,
        ),
        new Text(
          'fitHeight',
          style: TextStyle(color: Colors.blue),
        ),
      ],
    );
  }

  Widget _buildVolume() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Radio(
          value: false,
          groupValue: _isMuted,
          onChanged: _changeVolumeMode,
        ),
        new Text(
          'unMute',
          style: TextStyle(color: Colors.blue),
        ),
        new Radio(
          value: true,
          groupValue: _isMuted,
          onChanged: _changeVolumeMode,
        ),
        new Text(
          'Mute',
          style: TextStyle(color: Colors.blue),
        )
      ],
    );
  }

  Widget _buildPlaybackRate() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Radio(
          value: PlaybackRate.RATE_0_25,
          groupValue: _playbackRate,
          onChanged: _changePlaybackRate,
        ),
        new Text(
          '0_25',
          style: TextStyle(color: Colors.blue),
        ),
        new Radio(
          value: PlaybackRate.RATE_0_5,
          groupValue: _playbackRate,
          onChanged: _changePlaybackRate,
        ),
        new Text(
          '0_5',
          style: TextStyle(color: Colors.blue),
        ),
        new Radio(
          value: PlaybackRate.RATE_1,
          groupValue: _playbackRate,
          onChanged: _changePlaybackRate,
        ),
        new Text(
          '1',
          style: TextStyle(color: Colors.blue),
        ),
        new Radio(
          value: PlaybackRate.RATE_1_5,
          groupValue: _playbackRate,
          onChanged: _changePlaybackRate,
        ),
        new Text(
          '1_5',
          style: TextStyle(color: Colors.blue),
        ),
        new Radio(
          value: PlaybackRate.RATE_2,
          groupValue: _playbackRate,
          onChanged: _changePlaybackRate,
        ),
        new Text(
          '2',
          style: TextStyle(color: Colors.blue),
        )
      ],
    );
  }
}


