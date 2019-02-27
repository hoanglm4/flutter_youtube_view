//
//  YoutubeFactory.swift
//  Runner
//
//  Created by Le Minh Hoang on 2/27/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation
import Flutter
import AVKit

class YoutubeFactory: NSObject, FlutterPlatformViewFactory {
    let registrar: FlutterPluginRegistrar
    init(_registrar: FlutterPluginRegistrar) {
        registrar = _registrar
        super.init()
        configureAudioSession()
    }
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return FlutterYoutubeView(_frame: frame, _viewId: viewId, _registrar: registrar)
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }
}
