# flutter_youtube_view

This plugin provides Inlining YouTube player. To interact with YouTube the library uses the [Frame Player API](https://developers.google.com/youtube/iframe_api_reference), inside of a WebView (Android), WKWebview (iOS). Therefore the YouTube app is not required on the user's device and there are no issues with YouTube Terms of Service.

This plugin using:
* Android: https://github.com/PierfrancescoSoffritti/android-youtube-player 
* iOS: https://github.com/rinov/YoutubeKit

APK sample: https://github.com/hoanglm4/flutter_youtube_view/tree/master/example/android/APK

## How to Use

#### 1\. Depend

Add this to you package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_youtube_view: ^1.1.9
```

#### 2\. Install

Run command:

```bash
$ flutter packages get
```

#### 3\. Import

Import in Dart code:

```dart
import 'package:flutter_youtube_view/flutter_youtube_view.dart';
```
Currently apps need to opt-in for the UIViews embedding preview on iOS by adding a boolean property to the Info.plist (key=io.flutter.embedded_views_preview value=YES).

#### 4\. Using Youtube View
         
```dart
 Container(
          child: FlutterYoutubeView(
                onViewCreated: _onYoutubeCreated,
                listener: this,
                scaleMode: YoutubeScaleMode.none, // <option> fitWidth, fitHeight
                params: YoutubeParam(
                      videoId: 'gcj2RUWQZ60', 
                      showUI: false, 
                      startSeconds: 0.0, // <option>
                      autoPlay: false) // <option>
                )
            ),
```
## Features

### Call IFrame API during playback
- play()
- pause()
- loadOrCueVideo()
- seekTo()
- setVolume() only Android
- mute()
- unMute()
- setPlaybackRate(rate: PlaybackRate.RATE_1) or setPlaybackRate(rateValue: 1.0) 
### PLAYER callback
```dart
  void onReady();

  void onStateChange(String state); // UNKNOWN, UNSTARTED, ENDED, PLAYING, PAUSED, BUFFERING, VIDEO_CUED

  void onError(String error); // INVALID_PARAMETER_IN_REQUEST, HTML_5_PLAYER, VIDEO_NOT_FOUND, VIDEO_NOT_PLAYABLE_IN_EMBEDDED_PLAYER

  void onVideoDuration(double duration);

  void onCurrentSecond(double second);
```
