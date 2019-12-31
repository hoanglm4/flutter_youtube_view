class YoutubeParam {
  final String videoId;
  final bool showUI;
  final double startSeconds;
  final bool autoPlay;
  final bool showYoutube;
  final bool showFullScreen;

  const YoutubeParam(
      {this.videoId,
      this.showUI = true,
      this.startSeconds = 0.0,
      this.autoPlay = true,
      this.showFullScreen = true,
      this.showYoutube = true});
}
