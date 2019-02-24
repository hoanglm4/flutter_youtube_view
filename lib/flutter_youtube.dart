import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/YouTubePlayerListener.dart';
import 'src/YoutubeParam.dart';
export 'src/YouTubePlayerListener.dart';
export 'src/YoutubeParam.dart';

typedef void FlutterYoutubeViewCreatedCallback(FlutterYoutubeViewController controller);

class FlutterYoutubeView extends StatefulWidget {
  const FlutterYoutubeView({
    Key key,
    this.onViewCreated,
    this.listener,
    this.params
  }) : super(key: key);

  final FlutterYoutubeViewCreatedCallback onViewCreated;
  final YouTubePlayerListener listener;
  final YoutubeParam params;

  @override
  State<StatefulWidget> createState() => _FlutterYoutubeViewState();
}

class _FlutterYoutubeViewState extends State<FlutterYoutubeView> {
  @override
  Widget build(BuildContext context) {
    var params = widget.params ?? YoutubeParam();
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'plugins.hoanglm.com/youtube',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: <String, dynamic>{
          "videoId": params.videoId,
          "showUI": params.showUI,
          "startSeconds": params.startSeconds
        },
        creationParamsCodec: StandardMessageCodec(),
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the text_view plugin');
  }

  void _onPlatformViewCreated(int id) {
    if (widget.onViewCreated == null) {
      return;
    }
    widget.onViewCreated(
        new FlutterYoutubeViewController._(id, widget.listener)
    );
  }
}

class FlutterYoutubeViewController {
  final MethodChannel _channel;
  final YouTubePlayerListener _listener;

  FlutterYoutubeViewController._(int id, YouTubePlayerListener listener)
      : _channel = new MethodChannel('plugins.hoanglm.com/youtube_$id'),
        _listener = listener {
    if (_listener != null) {
      _channel.setMethodCallHandler(handleEvent);
    }
  }

  Future<void> loadOrCueVideo(String videoId, double startSeconds) async {
    assert(videoId != null);
    var params = <String, dynamic>{
      "videoId": videoId,
      "startSeconds": startSeconds
    };
    await _channel.invokeMethod('loadOrCueVideo', params);
  }

  Future<void> play() async {
    await _channel.invokeMethod('play', null);
  }

  Future<void> pause() async {
    await _channel.invokeMethod('pause', null);
  }

  Future<void> seekTo(double time) async {
    await _channel.invokeMethod('seekTo', time);
  }

  /**
   * @param volumePercent Integer between 0 and 100
   */
  Future<void> setVolume(int volumePercent) async {
    await _channel.invokeMethod('setVolume', volumePercent);
  }

  Future<dynamic> handleEvent(MethodCall call) async {
    switch (call.method) {
      case 'onReady':
        _listener.onReady();
        break;
      case 'onStateChange':
        _listener.onStateChange(call.arguments as String);
        break;
      case 'onError':
        _listener.onError(call.arguments as String);
        break;
      case 'onVideoDuration':
        _listener.onVideoDuration(call.arguments as double);
        break;
      case 'onCurrentSecond':
        _listener.onCurrentSecond(call.arguments as double);
        break;
    }
    return null;
  }
}