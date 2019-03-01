package com.hoanglm.flutteryoutubeview

enum class PlayerState(val value: String) {
    UNKNOWN("UNKNOWN"),
    UNSTARTED("UNSTARTED"),
    ENDED("ENDED"),
    PLAYING("PLAYING"),
    PAUSED("PAUSED"),
    BUFFERING("BUFFERING"),
    VIDEO_CUED("VIDEO_CUED")
}