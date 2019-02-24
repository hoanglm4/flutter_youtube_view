package com.hoanglm.flutteryoutube

import android.app.Activity
import android.app.Application
import android.content.Context
import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleObserver
import com.pierfrancescosoffritti.androidyoutubeplayer.core.player.views.YouTubePlayerView
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.platform.PlatformView
import com.pierfrancescosoffritti.androidyoutubeplayer.core.player.PlayerConstants
import com.pierfrancescosoffritti.androidyoutubeplayer.core.player.YouTubePlayer
import com.pierfrancescosoffritti.androidyoutubeplayer.core.player.listeners.AbstractYouTubePlayerListener
import com.pierfrancescosoffritti.androidyoutubeplayer.core.player.utils.loadOrCueVideo
import java.util.concurrent.atomic.AtomicReference

class FlutterYoutubeView(
    context: Context,
    id: Int,
    private val state: AtomicReference<State>,
    private val registrar: PluginRegistry.Registrar
) :
    PlatformView,
    MethodChannel.MethodCallHandler,
    Application.ActivityLifecycleCallbacks,
    Lifecycle() {

    private val TAG = "FlutterYoutubeView"

    private val youtubePlayerView: YouTubePlayerView
    private var youtubePlayer: YouTubePlayer? = null
    private val methodChannel: MethodChannel
    private val registrarActivityHashCode: Int
    private var disposed = false

    init {
        youtubePlayerView = YouTubePlayerView(context)
        methodChannel = MethodChannel(registrar.messenger(), "plugins.hoanglm.com/youtube_$id")
        methodChannel.setMethodCallHandler(this)
        registrarActivityHashCode = registrar.activity().hashCode()
        registrar.activity().application.registerActivityLifecycleCallbacks(this)
        initYouTubePlayerView()
    }

    private fun initYouTubePlayerView() {
        youtubePlayerView.addYouTubePlayerListener(object : AbstractYouTubePlayerListener() {
            override fun onReady(youTubePlayer: YouTubePlayer) {
                youtubePlayer = youTubePlayer
            }

            override fun onStateChange(
                youTubePlayer: YouTubePlayer,
                state: PlayerConstants.PlayerState
            ) {
                Log.d(TAG, "state = $state")
            }

            override fun onError(youTubePlayer: YouTubePlayer, error: PlayerConstants.PlayerError) {
                Log.d(TAG, "error = ${error.name}")
            }
        })
    }

    override fun getView(): View {
        return youtubePlayerView
    }

    override fun dispose() {
        disposed = true
        registrar.activity().application.unregisterActivityLifecycleCallbacks(this)
    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {
            "loadOrCueVideo" -> loadOrCueVideo(methodCall, result)
            else -> result.notImplemented()
        }
    }

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
        if (activity.hashCode() != registrarActivityHashCode || disposed) {
            return
        }
    }

    override fun onActivityStarted(activity: Activity) {
        if (activity.hashCode() != registrarActivityHashCode || disposed) {
            return
        }
    }

    override fun onActivityResumed(activity: Activity) {
        if (activity.hashCode() != registrarActivityHashCode || disposed) {
            return
        }
    }

    override fun onActivityPaused(activity: Activity) {
        if (activity.hashCode() != registrarActivityHashCode || disposed) {
            return
        }
    }


    override fun onActivityStopped(activity: Activity) {
        if (activity.hashCode() != registrarActivityHashCode || disposed) {
            return
        }
    }

    override fun onActivityDestroyed(activity: Activity) {
        if (activity.hashCode() != registrarActivityHashCode || disposed) {
            return
        }
    }

    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle?) {
    }

    override fun addObserver(observer: LifecycleObserver) {
    }

    override fun removeObserver(observer: LifecycleObserver) {
    }

    override fun getCurrentState(): State {
        return state.get()
    }

    private fun loadOrCueVideo(methodCall: MethodCall, result: MethodChannel.Result) {
        val youtubeId = methodCall.arguments as String
        youtubePlayer?.loadOrCueVideo(this@FlutterYoutubeView, youtubeId, 0f)
        result.success(null)
    }
}