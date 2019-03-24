package com.hoanglm.flutteryoutubeview

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
    private val params: HashMap<String, *>,
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
        Log.d(TAG, "params = $params")
        val videoId = params["videoId"] as? String
        val startSeconds = (params["startSeconds"] as Double).toFloat()
        val showUI = params["showUI"] as Boolean
        val controller = youtubePlayerView.getPlayerUiController()
        if (!showUI) {
            controller.showUi(false)
            controller.showVideoTitle(false)
            controller.showYouTubeButton(false)
        }
        addObserver(youtubePlayerView)
        youtubePlayerView.addYouTubePlayerListener(object : AbstractYouTubePlayerListener() {
            override fun onReady(youTubePlayer: YouTubePlayer) {
                youtubePlayer = youTubePlayer
                methodChannel.invokeMethod("onReady", null)
                if (videoId != null) {
                    youtubePlayer?.loadOrCueVideo(this@FlutterYoutubeView, videoId, startSeconds)
                }
            }

            override fun onStateChange(
                youTubePlayer: YouTubePlayer,
                state: PlayerConstants.PlayerState
            ) {
                onStateChange(state)
            }

            override fun onError(youTubePlayer: YouTubePlayer, error: PlayerConstants.PlayerError) {
                onError(error)
            }

            override fun onVideoDuration(youTubePlayer: YouTubePlayer, duration: Float) {
                methodChannel.invokeMethod("onVideoDuration", duration)
            }

            override fun onCurrentSecond(youTubePlayer: YouTubePlayer, second: Float) {
                methodChannel.invokeMethod("onCurrentSecond", second)
            }
        })
    }

    override fun getView(): View {
        return youtubePlayerView
    }

    override fun dispose() {
        disposed = true
        registrar.activity().application.unregisterActivityLifecycleCallbacks(this)
        removeObserver(youtubePlayerView)
        youtubePlayerView.release()
    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {
            "loadOrCueVideo" -> loadOrCueVideo(methodCall, result)
            "play" -> play(result)
            "pause" -> pause(result)
            "seekTo" -> seekTo(methodCall, result)
            "setVolume" -> setVolume(methodCall, result)
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
        val params = methodCall.arguments as HashMap<String, *>
        val videoId = params["videoId"] as String
        val startSeconds = (params["startSeconds"] as? Double ?: 0.0).toFloat()
        youtubePlayer?.loadOrCueVideo(this@FlutterYoutubeView, videoId, startSeconds)
        result.success(null)
    }

    private fun pause(result: MethodChannel.Result) {
        youtubePlayer?.pause()
        result.success(null)
    }

    private fun play(result: MethodChannel.Result) {
        youtubePlayer?.play()
        result.success(null)
    }

    private fun seekTo(methodCall: MethodCall, result: MethodChannel.Result) {
        val time = (methodCall.arguments as Double).toFloat()
        youtubePlayer?.seekTo(time)
        result.success(null)
    }

    /**
     * @param volumePercent Integer between 0 and 100
     */
    private fun setVolume(methodCall: MethodCall, result: MethodChannel.Result) {
        val volumePercent = methodCall.arguments as Int
        youtubePlayer?.setVolume(volumePercent)
        result.success(null)
    }

    private fun onStateChange(state: PlayerConstants.PlayerState) {
        Log.d(TAG, "state = $state")
        val customState = when (state) {
            PlayerConstants.PlayerState.VIDEO_CUED -> PlayerState.VIDEO_CUED.value
            PlayerConstants.PlayerState.UNSTARTED -> PlayerState.UNSTARTED.value
            PlayerConstants.PlayerState.ENDED -> PlayerState.ENDED.value
            PlayerConstants.PlayerState.PLAYING -> PlayerState.PLAYING.value
            PlayerConstants.PlayerState.PAUSED -> PlayerState.PAUSED.value
            PlayerConstants.PlayerState.BUFFERING -> PlayerState.BUFFERING.value
            else -> PlayerState.UNKNOWN.value
        }
        methodChannel.invokeMethod("onStateChange", customState)
    }

    private fun onError(error: PlayerConstants.PlayerError) {
        Log.d(TAG, "error = ${error.name}")
        val customError = when (error) {
            PlayerConstants.PlayerError.INVALID_PARAMETER_IN_REQUEST -> PlayerError.INVALID_PARAMETER_IN_REQUEST.value
            PlayerConstants.PlayerError.VIDEO_NOT_PLAYABLE_IN_EMBEDDED_PLAYER -> PlayerError.VIDEO_NOT_PLAYABLE_IN_EMBEDDED_PLAYER.value
            PlayerConstants.PlayerError.HTML_5_PLAYER -> PlayerError.HTML_5_PLAYER.value
            PlayerConstants.PlayerError.VIDEO_NOT_FOUND -> PlayerError.VIDEO_NOT_FOUND.value
            else -> PlayerError.UNKNOWN.value
        }
        methodChannel.invokeMethod("onError", customError)
    }
}