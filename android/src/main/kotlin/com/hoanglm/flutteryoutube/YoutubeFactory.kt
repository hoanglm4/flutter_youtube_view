package com.hoanglm.flutteryoutube

import android.content.Context
import androidx.lifecycle.Lifecycle
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import java.util.concurrent.atomic.AtomicReference

class YoutubeFactory(
    private val registrar: PluginRegistry.Registrar,
    private val state: AtomicReference<Lifecycle.State>
) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        return FlutterYoutubeView(context!!, viewId, state, registrar)
    }
}