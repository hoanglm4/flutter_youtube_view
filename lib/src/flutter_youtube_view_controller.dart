import 'dart:async';
import 'package:flutter/services.dart';
import '../flutter_youtube_view.dart';

class FlutterYoutubeViewController {
  final MethodChannel _channel;
  final YouTubePlayerListener _listener;

  FlutterYoutubeViewController.of(int id, YouTubePlayerListener listener)
      : _channel = new MethodChannel('plugins.hoanglm.com/youtube_$id'),
        _listener = listener {
    if (_listener != null) {
      _channel.setMethodCallHandler(handleEvent);
    }
  }

  Future<void> initialization() async {
    await _channel.invokeMethod('initialization');
  }

  Future<void> loadOrCueVideo(String videoId,
      double startSeconds,
      { bool autoPlay = true }) async {
    assert(videoId != null);
    var params = <String, dynamic>{
      "videoId": videoId,
      "startSeconds": startSeconds,
      "autoPlay": autoPlay
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

  /// Change player PlaybackRate based on [PlaybackRate] or [rateValue]. If both params, [PlaybackRate] will be used.
  Future<void> setPlaybackRate({PlaybackRate rate, double rateValue = 1.0}) async {
    assert(rate != null || rateValue != null);
    switch (rate) {
      case(PlaybackRate.RATE_0_25):
        rateValue = 0.25;
        break;
      case(PlaybackRate.RATE_0_5):
        rateValue = 0.5;
        break;
      case(PlaybackRate.RATE_1):
        rateValue = 1;
        break;
      case(PlaybackRate.RATE_1_5):
        rateValue = 1.5;
        break;
      case(PlaybackRate.RATE_2):
        rateValue = 2.0;
        break;
      default:
        rateValue = rateValue;
        break;
    }
    await _channel.invokeMethod('setPlaybackRate', rateValue);
  }

  Future<void> setVolume(int volumePercent) async {
    await _channel.invokeMethod('setVolume', volumePercent);
  }

  Future<void> setMute() async {
    await _channel.invokeMethod('mute', null);
  }

  Future<void> setUnMute() async {
    await _channel.invokeMethod('unMute', null);
  }

  Future<void> changeScaleMode(YoutubeScaleMode mode) async {
    await _channel.invokeMethod('scaleMode', mode.index);
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
