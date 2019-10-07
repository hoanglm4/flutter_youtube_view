//
//  FlutterYoutubeView.swift
//  Runner
//
//  Created by Le Minh Hoang on 2/27/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation
import Flutter
import YoutubeKit
import AVKit

enum VideoScaleMode: Int {
    case NONE = 0
    case FIT_WIDTH = 1
    case FIT_HEIGHT = 2
}
class FlutterYoutubeView: NSObject, FlutterPlatformView {
    private let frame: CGRect
    private let viewId: Int64
    private let registrar: FlutterPluginRegistrar
    private let params: [String: Any]
    private let playerView: UIView
    private let channel: FlutterMethodChannel
    private var player: YTSwiftyPlayer!
    private var isPlayerReady = false
    
    init(_frame: CGRect,
         _viewId: Int64,
         _params: [String: Any]?,
         _registrar: FlutterPluginRegistrar) {
        frame = _frame
        viewId = _viewId
        registrar = _registrar
        params = _params!
        playerView = UIView(frame: frame)
        channel = FlutterMethodChannel(
            name: "plugins.hoanglm.com/youtube_\(viewId)",
            binaryMessenger: registrar.messenger()
        )
        super.init()
        self.initPlayer()
        channel.setMethodCallHandler { [weak self] (call, result) in
            guard let `self` = self else { return }
            `self`.handle(call, result: result)
        }
    }
    
    func view() -> UIView {
        return playerView
    }
    
    private func dispose() {
        self.player.stopVideo()
        self.player.clearVideo()
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialization":
            result(nil)
        case "loadOrCueVideo":
            print("loadOrCueVideo is called")
            let params = call.arguments as! Dictionary<String, Any>
            let videoId = params["videoId"] as! String
            let startSeconds = params["startSeconds"] as? Double ?? 0.0
            let autoPlay = params["autoPlay"] as? Bool ?? true
            loadOrCueVideo(videoId: videoId, startSeconds: startSeconds, autoPlay: autoPlay)
            result(nil)
        case "play":
            print("play is called")
            if (self.isPlayerReady) {
                self.player.playVideo()
            }
            result(nil)
        case "pause":
            print("pause is called")
            if (self.isPlayerReady) {
                self.player.pauseVideo()
            }
            result(nil)
        case "seekTo":
            print("seekTo is called")
            if (self.isPlayerReady) {
                let second = call.arguments as! Double
                self.player.seek(to: Int(second), allowSeekAhead: true)
            }
            result(nil)
        case "setPlaybackRate":
            print("setPlaybackRate is called")
            if (self.isPlayerReady) {
                let rate = call.arguments as! Double
                self.player.setPlaybackRate(rate)
            }
            result(nil)
        case "mute":
            print("mute is called")
            self.player.mute()
            result(nil)
        case "unMute":
            print("mute is called")
            self.player.unMute()
            result(nil)
        case "setVolume":
            print("setVolume is called")
            result(nil)
        case "scaleMode":
            let scaleMode = call.arguments as! Int
            self.changeScaleMode(scaleMode: scaleMode)
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let `self` = self else { return }
                self.playerView.layoutIfNeeded()
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initPlayer() {
        print("params = \(params)")
        let videoId = params["videoId"] as? String ?? ""
        let showUI = params["showUI"] as! Bool
        let scaleMode = params["scale_mode"] as? Int ?? 0
        let autoPlay = params["autoPlay"] as? Bool ?? true
        let startSeconds = params["startSeconds"] as? Double ?? 0.0
        var playerVars: [VideoEmbedParameter]
        if (showUI) {
            playerVars = [
                VideoEmbedParameter.playsInline(true),
                VideoEmbedParameter.videoID(videoId),
                VideoEmbedParameter.loopVideo(false),
                VideoEmbedParameter.showRelatedVideo(false),
                VideoEmbedParameter.showInfo(true),
                VideoEmbedParameter.autoplay(autoPlay),
                VideoEmbedParameter.registerStartTimeAt(Int(startSeconds))
            ]
        } else {
            playerVars = [
                VideoEmbedParameter.playsInline(true),
                VideoEmbedParameter.videoID(videoId),
                VideoEmbedParameter.loopVideo(false),
                VideoEmbedParameter.showRelatedVideo(false),
                VideoEmbedParameter.showInfo(false),
                VideoEmbedParameter.showControls(VideoControlAppearance.hidden),
                VideoEmbedParameter.autoplay(autoPlay),
                VideoEmbedParameter.registerStartTimeAt(Int(startSeconds))
            ]
        }
        self.player = YTSwiftyPlayer(playerVars: playerVars)
        self.player.autoplay = autoPlay
        self.playerView.addSubview(self.player)
        switch scaleMode {
        case VideoScaleMode.FIT_WIDTH.rawValue:
            self.player.fillWidthToSuperview(ratio: 9.0 / 16.0)
        case VideoScaleMode.FIT_HEIGHT.rawValue:
            self.player.fillHeightToSuperview(ratio: 16.0 / 9.0)
        default:
            self.player.fillToSuperview()
        }
        self.player.delegate = self
        self.player.loadPlayer()
    }
    
    private func changeScaleMode(scaleMode: Int) {
        self.player.removeAllAutoLayout()
        switch scaleMode {
        case VideoScaleMode.FIT_WIDTH.rawValue:
            self.player.fillWidthToSuperview(ratio: 9.0 / 16.0)
        case VideoScaleMode.FIT_HEIGHT.rawValue:
            self.player.fillHeightToSuperview(ratio: 16.0 / 9.0)
        default:
            self.player.fillToSuperview()
        }
    }
    
    private func loadOrCueVideo(videoId: String, startSeconds: Double = 0.0, autoPlay: Bool = true) {
        if (!self.isPlayerReady) {
            return
        }
        if (autoPlay) {
            self.player.loadVideo(videoID: videoId, startSeconds: Int(startSeconds))
        } else {
            self.player.cueVideo(videoID: videoId, startSeconds: Int(startSeconds))
        }
    }

    private func onStateChange(state: YTSwiftyPlayerState) {
        var customState: PlayerState
        switch state {
        case .cued:
            customState = .VIDEO_CUED
        case .ended:
            customState = .ENDED
        case .playing:
            customState = .PLAYING
        case .paused:
            customState = .PAUSED
        case .buffering:
            customState = .BUFFERING
        case .unstarted:
            customState = .UNSTARTED
        }
        print("state = \(state)")
        channel.invokeMethod("onStateChange", arguments: customState.rawValue)
    }
    
    private func onError(error: YTSwiftyPlayerError) {
        var playerError: PlayerError
        switch error {
        case .invalidURLRequest:
            playerError = .INVALID_PARAMETER_IN_REQUEST
        case .html5PlayerError:
            playerError = .HTML_5_PLAYER
        case .videoNotFound:
            playerError = .VIDEO_NOT_FOUND
        case .videoNotPermited:
            playerError = .VIDEO_NOT_PLAYABLE_IN_EMBEDDED_PLAYER
        case .videoLicenseError:
            playerError = .VIDEO_NOT_PLAYABLE_IN_EMBEDDED_PLAYER
        }
        channel.invokeMethod("onError", arguments: playerError.rawValue)
    }
    
    deinit {
        dispose()
        print("FlutterYoutubeView is deninit")
    }
}

extension FlutterYoutubeView: YTSwiftyPlayerDelegate {
    func playerReady(_ player: YTSwiftyPlayer) {
        print(#function)
        self.isPlayerReady = true
        channel.invokeMethod("onReady", arguments: nil)
    }
    
    func player(_ player: YTSwiftyPlayer, didUpdateCurrentTime currentTime: Double) {
        print("\(#function):\(currentTime)")
        channel.invokeMethod("onCurrentSecond", arguments: currentTime)
    }
    
    func player(_ player: YTSwiftyPlayer, didChangeState state: YTSwiftyPlayerState) {
        print("\(#function):\(state)")
        if (state == YTSwiftyPlayerState.playing) {
            channel.invokeMethod("onVideoDuration", arguments: player.duration)
        }
        self.onStateChange(state: state)
    }
    
    func player(_ player: YTSwiftyPlayer, didChangePlaybackRate playbackRate: Double) {
        print("\(#function):\(playbackRate)")
    }
    
    func player(_ player: YTSwiftyPlayer, didReceiveError error: YTSwiftyPlayerError) {
        print("\(#function):\(error)")
        self.onError(error: error)
    }
    
    func player(_ player: YTSwiftyPlayer, didChangeQuality quality: YTSwiftyVideoQuality) {
        print("\(#function):\(quality)")
    }
    
    func apiDidChange(_ player: YTSwiftyPlayer) {
        print(#function)
    }
    
    func youtubeIframeAPIReady(_ player: YTSwiftyPlayer) {
        print(#function)
    }
    
    func youtubeIframeAPIFailedToLoad(_ player: YTSwiftyPlayer) {
        print(#function)
    }
}
