//
//  PlayerError.swift
//  Runner
//
//  Created by Le Minh Hoang on 2/27/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

enum PlayerError: String {
    case UNKNOWN = "UNKNOWN"
    case INVALID_PARAMETER_IN_REQUEST = "INVALID_PARAMETER_IN_REQUEST"
    case HTML_5_PLAYER = "HTML_5_PLAYER"
    case VIDEO_NOT_FOUND = "VIDEO_NOT_FOUND"
    case VIDEO_NOT_PLAYABLE_IN_EMBEDDED_PLAYER = "VIDEO_NOT_PLAYABLE_IN_EMBEDDED_PLAYER"
}
