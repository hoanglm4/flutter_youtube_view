//
//  FlutterYoutubeView.swift
//  Runner
//
//  Created by Le Minh Hoang on 2/27/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation
import Flutter
import XCDYouTubeKit
import AVKit

class FlutterYoutubeView: NSObject, FlutterPlatformView {
    private let frame: CGRect
    private let viewId: Int64
    private let registrar: FlutterPluginRegistrar
    private let playerView: UIView
    private let client = XCDYouTubeClient()
    private let channel: FlutterMethodChannel
    private var player = ZHPlayer()
    
    init(_frame: CGRect, _viewId: Int64, _registrar: FlutterPluginRegistrar) {
        frame = _frame
        viewId = _viewId
        registrar = _registrar
        playerView = UIView(frame: frame)
        channel = FlutterMethodChannel(
            name: "plugins.hoanglm.com/youtube_\(viewId)",
            binaryMessenger: registrar.messenger()
        )
        super.init()
        channel.setMethodCallHandler { [weak self] (call, result) in
            guard let `self` = self else { return }
            `self`.handle(call, result: result)
        }
        self.initPlayer()
    }
    
    func view() -> UIView {
        return playerView
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "loadOrCueVideo":
            print("loadOrCueVideo is called")
            loadOrCueVideo(videoId: "gcj2RUWQZ60")
            result(nil)
        case "play":
            print("play is called")
            self.player.play()
            result(nil)
        case "pause":
            print("pause is called")
            self.player.pause()
            result(nil)
        case "seekTo":
            print("seekTo is called")
            result(nil)
        case "setVolume":
            print("setVolume is called")
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initPlayer() {
        self.player.delegate = self
        self.playerView.addSubview(player.view)
        if #available(iOS 9, *) {
            player.view.fillToSuperview()
        } else {
            // Fallback on earlier versions
        }
        channel.invokeMethod("onReady", arguments: nil)
    }
    
    private func loadOrCueVideo(videoId: String) {
        self.player.stop()
        self.loadUrl(videoId: videoId) {[weak self] (url: URL?, error: Error? ) -> Void in
            guard let `self` = self else { return }
            if (error != nil) {
                self.onError(error: .UNKNOWN)
                return
            }
            guard let url = url else {
                self.onError(error: .VIDEO_NOT_FOUND)
                return
            }
            print("url when loadOrCueVideo called = \(url)")
            self.player.url = url
            self.player.play()
        }
    }
    
    private func loadUrl(videoId: String, completionHandler:@escaping (URL?, Error?) -> Void) {
        self.client.getVideoWithIdentifier(videoId) { (video: XCDYouTubeVideo?, error: Error?) -> Void in
            if let error = error {
                completionHandler(nil, error)
                return
            }
            let streamURLs = video!.streamURLs
            let url: URL = streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming]
                ?? streamURLs[XCDYouTubeVideoQuality.HD720.rawValue]
                ?? streamURLs[XCDYouTubeVideoQuality.medium360.rawValue]
                ?? streamURLs[XCDYouTubeVideoQuality.small240.rawValue]!
            completionHandler(url, nil)
        }
    }
    
    private func onStateChange(state: ZHPlayer.PlaybackState) {
        var customState: PlayerState
        switch state {
        case .pause:
            customState = .PAUSED
        case .playing:
            customState = .PLAYING
        case .stopped:
            customState = .UNSTARTED
        default:
            customState = .UNKNOWN
        }
        print("state = \(state)")
        channel.invokeMethod("onStateChange", arguments: customState.rawValue)
    }
    
    private func onError(error: PlayerError) {
        channel.invokeMethod("onError", arguments: error.rawValue)
    }
}

extension FlutterYoutubeView: ZHPlayerDelegate {
    func playerReady(_ player: ZHPlayer) {
        print("ZHPlayer# playerReady")
    }
    
    func playerPlaybackStateDidChange(_ player: ZHPlayer) {
        if player.playbackState == .fail {
            onError(error: .UNKNOWN)
            print("ZHPlayer \(player.error!)")
            return
        }
        print("ZHPlayer# playerPlaybackStateDidChange# \(player.playbackState)")
        onStateChange(state: player.playbackState)
    }
    
    func playerBufferingStateDidChange(_ player: ZHPlayer) {
        print("ZHPlayer# playerBufferingStateDidChange# \(player.bufferingState)")
        switch player.bufferingState {
        case .playable:
            channel.invokeMethod("onStateChange", arguments: PlayerState.BUFFERING.rawValue)
        case .stalled:
            channel.invokeMethod("onVideoDuration", arguments: player.duration)
        default:
            break
        }
    }
    
    func playerBufferTimeDidChange(_ bufferTime: TimeInterval) {
        print("ZHPlayer# playerBufferTimeDidChange#\(bufferTime)")
    }
    
    func playerCurrentTimeDidChange(_ player: ZHPlayer) {
        channel.invokeMethod("onCurrentSecond", arguments: player.currentTime)
    }
    
    func playerPlaybackDidEnd(_ player: ZHPlayer) {
        print("ZHPlayer# playerPlaybackDidEnd")
        channel.invokeMethod("onStateChange", arguments: PlayerState.ENDED.rawValue)
    }
}
