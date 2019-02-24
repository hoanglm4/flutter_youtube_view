import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef void FlutterYoutubeViewCreatedCallback(FlutterYoutubeViewController controller);

class FlutterYoutubeView extends StatefulWidget {
  const FlutterYoutubeView({
    Key key,
    this.onViewCreated,
  }) : super(key: key);

  final FlutterYoutubeViewCreatedCallback onViewCreated;

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
    widget.onViewCreated(new FlutterYoutubeViewController._(id));
  }
}

class FlutterYoutubeViewController {
  FlutterYoutubeViewController._(int id)
      : _channel = new MethodChannel('plugins.hoanglm.com/youtube_$id');

  final MethodChannel _channel;

  Future<void> loadOrCueVideo(String videoId) async {
    assert(videoId != null);
    return _channel.invokeMethod('loadOrCueVideo', videoId);
  }
}