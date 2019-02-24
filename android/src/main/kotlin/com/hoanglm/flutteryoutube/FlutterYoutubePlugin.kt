package com.hoanglm.flutteryoutube

import android.app.Activity
import android.app.Application
import android.os.Bundle
import androidx.lifecycle.Lifecycle
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.util.concurrent.atomic.AtomicReference

class FlutterYoutubePlugin(registrar: Registrar): Application.ActivityLifecycleCallbacks {
    private val state: AtomicReference<Lifecycle.State> = AtomicReference(Lifecycle.State.INITIALIZED)
    private val registrarActivityHashCode: Int

    init {
        registrarActivityHashCode = registrar.activity().hashCode()
    }

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
        if (activity.hashCode() != registrarActivityHashCode) {
            return
        }
        state.set(Lifecycle.State.CREATED)
    }

    override fun onActivityStarted(activity: Activity) {
        if (activity.hashCode() != registrarActivityHashCode) {
            return
        }
        state.set(Lifecycle.State.STARTED)
    }

    override fun onActivityResumed(activity: Activity) {
        if (activity.hashCode() != registrarActivityHashCode) {
            return
        }
        state.set(Lifecycle.State.RESUMED)
    }

    override fun onActivityPaused(activity: Activity) {
        if (activity.hashCode() != registrarActivityHashCode) {
            return
        }
    }


    override fun onActivityStopped(activity: Activity) {
        if (activity.hashCode() != registrarActivityHashCode) {
            return
        }
    }

    override fun onActivityDestroyed(activity: Activity) {
        if (activity.hashCode() != registrarActivityHashCode) {
            return
        }
        state.set(Lifecycle.State.DESTROYED)
    }

    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle?) {
    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val plugin = FlutterYoutubePlugin(registrar)
            registrar.activity().application.registerActivityLifecycleCallbacks(plugin)
            registrar
                .platformViewRegistry()
                .registerViewFactory(
                    "plugins.hoanglm.com/youtube", YoutubeFactory(registrar, plugin.state)
                )
        }
    }
}
