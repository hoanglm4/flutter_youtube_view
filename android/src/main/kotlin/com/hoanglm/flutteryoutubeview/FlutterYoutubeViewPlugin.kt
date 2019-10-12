package com.hoanglm.flutteryoutubeview

import android.app.Activity
import android.app.Application
import android.os.Bundle
import androidx.lifecycle.Lifecycle
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.util.concurrent.atomic.AtomicReference

class FlutterYoutubeViewPlugin(registrar: Registrar): Application.ActivityLifecycleCallbacks {
    private val state: AtomicReference<Lifecycle.Event> = AtomicReference(Lifecycle.Event.ON_CREATE)
    private val registrarActivityHashCode: Int

    init {
        if (registrar.activity() != null) {
            registrarActivityHashCode = registrar.activity().hashCode()
        } else {
            registrarActivityHashCode = 0
        }
    }

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
        if (activity.hashCode() != registrarActivityHashCode) {
            return
        }
        state.set(Lifecycle.Event.ON_CREATE)
    }

    override fun onActivityStarted(activity: Activity) {
        if (activity.hashCode() != registrarActivityHashCode) {
            return
        }
        state.set(Lifecycle.Event.ON_START)
    }

    override fun onActivityResumed(activity: Activity) {
        if (activity.hashCode() != registrarActivityHashCode) {
            return
        }
        state.set(Lifecycle.Event.ON_RESUME)
    }

    override fun onActivityPaused(activity: Activity) {
        if (activity.hashCode() != registrarActivityHashCode) {
            return
        }
        state.set(Lifecycle.Event.ON_PAUSE)
    }


    override fun onActivityStopped(activity: Activity) {
        if (activity.hashCode() != registrarActivityHashCode) {
            return
        }
        state.set(Lifecycle.Event.ON_STOP)
    }

    override fun onActivityDestroyed(activity: Activity) {
        if (activity.hashCode() != registrarActivityHashCode) {
            return
        }
        state.set(Lifecycle.Event.ON_DESTROY)
    }

    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle?) {
    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val plugin = FlutterYoutubeViewPlugin(registrar)
            if (registrar.activity() != null) {
                registrar.activity().application.registerActivityLifecycleCallbacks(plugin)
            }
            registrar
                .platformViewRegistry()
                .registerViewFactory(
                    "plugins.hoanglm.com/youtube", YoutubeFactory(registrar, plugin.state)
                )
        }
    }
}
