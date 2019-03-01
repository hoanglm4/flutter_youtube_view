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
    this.params = const YoutubeParam()
  }) : super(key: key);

  final FlutterYoutubeViewCreatedCallback onViewCreated;
  final YouTubePlayerListener listener;
  final YoutubeParam params;

  @override
  State<StatefulWidget> createState() => _FlutterYoutubeViewState();
}

class _FlutterYoutubeViewState extends State<FlutterYoutubeView> {
  final Completer<FlutterYoutubeViewController> _controller =
  Completer<FlutterYoutubeViewController>();

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'plugins.hoanglm.com/youtube',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: <String, dynamic>{
          "videoId": widget.params.videoId,
          "showUI": widget.params.showUI,
          "startSeconds": widget.params.startSeconds
        },
        creationParamsCodec: StandardMessageCodec(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'plugins.hoanglm.com/youtube',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: <String, dynamic>{
          "videoId": widget.params.videoId,
          "showUI": widget.params.showUI,
          "startSeconds": widget.params.startSeconds
        },
        creationParamsCodec: StandardMessageCodec(),
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the text_view plugin');
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onPlatformViewCreated(int id) {
    final controller = new FlutterYoutubeViewController._(id, widget.listener);
    _controller.complete(controller);
    if (widget.onViewCreated != null) {
      widget.onViewCreated(controller);
    }
    _initialization();
  }

  void _initialization() async {
    final controller = await _controller.future;
    controller.initialization();
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

  Future<void> initialization() async {
    await _channel.invokeMethod('initialization');
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