# flutter_youtube

This plugin provides YoutubeView widget.

Supported
* Android: https://github.com/PierfrancescoSoffritti/android-youtube-player
* iOS: https://github.com/0xced/XCDYouTubeKit

## Status Develop
* Android: DONE
* iOS: DONE

## How to Use

#### 1\. Depend

Add this to you package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_youtube_view: '0.0.1'
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

#### 4\. Using Youtube View
         
```dart
 Container(
          child: FlutterYoutubeView(
                onViewCreated: _onYoutubeCreated,
                listener: this,
                params: YoutubeParam(
                      videoId: 'gcj2RUWQZ60', 
                      showUI: false, 
                      startSeconds: 0.0),
                )
            ),
```
## Salient Features
- play()
- pause()
- loadOrCueVideo()
- seekTo()
- setVolume()
- Player listener
* State: UNKNOWN, UNSTARTED, ENDED, PLAYING, PAUSED, BUFFERING, VIDEO_CUED
* Status: ready, error
* Duration
* CurrentTime
