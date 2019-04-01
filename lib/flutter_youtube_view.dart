import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/you_tube_player_listener.dart';
import 'src/youtube_param.dart';
import 'src/flutter_youtube_view_controller.dart';
export 'src/you_tube_player_listener.dart';
export 'src/youtube_param.dart';
export 'src/flutter_youtube_view_controller.dart';

typedef void FlutterYoutubeViewCreatedCallback(FlutterYoutubeViewController controller);

enum YoutubeScaleMode { none, fitWidth, fitHeight }

class FlutterYoutubeView extends StatefulWidget {
  const FlutterYoutubeView({
    Key key,
    this.onViewCreated,
    this.listener,
    this.scaleMode = YoutubeScaleMode.none,
    this.params = const YoutubeParam()
  }) : super(key: key);

  final FlutterYoutubeViewCreatedCallback onViewCreated;
  final YouTubePlayerListener listener;
  final YoutubeParam params;
  final YoutubeScaleMode scaleMode;

  @override
  State<StatefulWidget> createState() => _FlutterYoutubeViewState();
}

class _FlutterYoutubeViewState extends State<FlutterYoutubeView> {
  FlutterYoutubeViewController _controller;

  @override
  Widget build(BuildContext context) {
    return _buildVideo();
  }

  void _onPlatformViewCreated(int id) {
    _controller = new FlutterYoutubeViewController.of(id, widget.listener);
    if (widget.onViewCreated != null) {
      widget.onViewCreated(_controller);
    }
    _initialization();
  }

  void _initialization() async {
    _controller.initialization();
  }

  Widget _buildVideo() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'plugins.hoanglm.com/youtube',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: <String, dynamic>{
          "scale_mode": widget.scaleMode.index,
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
}