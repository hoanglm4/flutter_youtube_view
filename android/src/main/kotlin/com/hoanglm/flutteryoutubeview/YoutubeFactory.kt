package com.hoanglm.flutteryoutubeview

import android.content.Context
import androidx.lifecycle.Lifecycle
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import kotlinx.coroutines.channels.Channel

class YoutubeFactory(
        private val binaryMessenger: BinaryMessenger,
        private val lifecycleChannel: Channel<Lifecycle.Event>
) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        return FlutterYoutubeView(context!!, viewId, args as HashMap<String, *>, binaryMessenger, lifecycleChannel)
    }
}