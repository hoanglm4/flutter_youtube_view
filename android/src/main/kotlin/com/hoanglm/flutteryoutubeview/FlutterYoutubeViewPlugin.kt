package com.hoanglm.flutteryoutubeview

import android.app.Activity
import android.app.Application
import android.os.Bundle
import androidx.annotation.NonNull
import androidx.lifecycle.Lifecycle
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch


class FlutterYoutubeViewPlugin : FlutterPlugin, ActivityAware, Application.ActivityLifecycleCallbacks {
    private var activityBinding: ActivityPluginBinding? = null
    private val lifecycleChannel = MutableStateFlow(Lifecycle.Event.ON_CREATE)
    private var registrarActivityHashCode: Int? = null

    // post 1.12 android projects
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        binding.platformViewRegistry.registerViewFactory(
                "plugins.hoanglm.com/youtube",
                YoutubeFactory(binding.binaryMessenger, lifecycleChannel)
        )
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        // do nothing
    }

    // This call will be followed by onReattachedToActivityForConfigChanges().
    override fun onDetachedFromActivity() {
        activityBinding?.activity?.application?.unregisterActivityLifecycleCallbacks(this)
        activityBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
            onAttachedToActivity(binding)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        registrarActivityHashCode = binding.activity.hashCode()
        binding.activity.application.registerActivityLifecycleCallbacks(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    // pre-1.12 
    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    companion object {
        @JvmStatic
        fun registerWith(registrar: PluginRegistry.Registrar) {
            if (registrar.activity() == null) {
                // When a background flutter view tries to register the plugin, the registrar has no activity.
                // We stop the registration process as this plugin is foreground only.
                return;
            }
            val plugin = FlutterYoutubeViewPlugin()
            // register activity lifecycle requirements
            plugin.registrarActivityHashCode = registrar.activity().hashCode()
            registrar.activity()?.application?.registerActivityLifecycleCallbacks(plugin)
            // create the youtube view
            registrar
                    .platformViewRegistry()
                    .registerViewFactory(
                            "plugins.hoanglm.com/youtube", YoutubeFactory(registrar.messenger(), plugin.lifecycleChannel)
                    )
        }
    }

    // lifecycle callbacks interface methods
    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
        if (activity.hashCode() != registrarActivityHashCode) {
            return
        }
        GlobalScope.launch {
            lifecycleChannel.value = Lifecycle.Event.ON_CREATE
        }
    }

    override fun onActivityStarted(activity: Activity) {
        if (activity.hashCode() != registrarActivityHashCode) {
            return
        }
        GlobalScope.launch {
            lifecycleChannel.value = Lifecycle.Event.ON_START
        }
    }

    override fun onActivityResumed(activity: Activity) {
        if (activity.hashCode() != registrarActivityHashCode) {
            return
        }
        GlobalScope.launch {
            lifecycleChannel.value = Lifecycle.Event.ON_RESUME
        }
    }

    override fun onActivityPaused(activity: Activity) {
        if (activity.hashCode() != registrarActivityHashCode) {
            return
        }
        GlobalScope.launch {
            lifecycleChannel.value = Lifecycle.Event.ON_PAUSE
        }
    }


    override fun onActivityStopped(activity: Activity) {
        if (activity.hashCode() != registrarActivityHashCode) {
            return
        }
        GlobalScope.launch {
            lifecycleChannel.value = Lifecycle.Event.ON_STOP
        }
    }

    override fun onActivityDestroyed(activity: Activity) {
        if (activity.hashCode() != registrarActivityHashCode) {
            return
        }
        GlobalScope.launch {
            lifecycleChannel.value = Lifecycle.Event.ON_DESTROY
        }
    }

    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
}
