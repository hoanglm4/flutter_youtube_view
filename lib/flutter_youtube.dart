import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/YouTubePlayerListener.dart';
export 'src/YouTubePlayerListener.dart';

typedef void FlutterYoutubeViewCreatedCallback(FlutterYoutubeViewController controller);

class FlutterYoutubeView extends StatefulWidget {
  const FlutterYoutubeView({
    Key key,
    this.onViewCreated,
    this.listener
  }) : super(key: key);

  final FlutterYoutubeViewCreatedCallback onViewCreated;
  final YouTubePlayerListener listener;

  @override
  State<StatefulWidget> createState() => _FlutterYoutubeViewState();
}

class _FlutterYoutubeViewState extends State<FlutterYoutubeView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'plugins.hoanglm.com/youtube',
        onPlatformViewCreated: _onPlatformViewCreated,
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

  Future<void> loadOrCueVideo(String videoId) async {
    assert(videoId != null);
    return _channel.invokeMethod('loadOrCueVideo', videoId);
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