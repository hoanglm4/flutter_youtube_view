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
        registrarActivityHashCode = registrar.activity().hashCode()
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
            if (registrar.activity() == null) {
                // When a background flutter view tries to register the plugin, the registrar has no activity.
                // We stop the registration process as this plugin is foreground only.
                return;
            }
            val plugin = FlutterYoutubeViewPlugin(registrar)
            registrar.activity().application.registerActivityLifecycleCallbacks(plugin)
            registrar
                .platformViewRegistry()
                .registerViewFactory(
                    "plugins.hoanglm.com/youtube", YoutubeFactory(registrar, plugin.state)
                )
        }
    }
}
