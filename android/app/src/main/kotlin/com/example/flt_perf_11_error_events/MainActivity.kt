package com.example.flt_perf_11_error_events

import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import java.util.*
import java.util.logging.StreamHandler

class MainActivity : FlutterActivity() {
    companion object {
        const val TAG = "MainActivity"
    }

    private var eventChannel: EventChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val messenger = flutterEngine!!.dartExecutor.binaryMessenger

        eventChannel = EventChannel(messenger, "app/events")
        eventChannel!!.setStreamHandler(object : StreamHandler(), EventChannel.StreamHandler {
            var canceled = false

            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                Log.d(TAG, "onListen: arguments: $arguments")

                val args = arguments as Map<*, *>

                val errors = args["type"] == "error"
                val max: Int = args["maximum"] as Int

                var count = 0

                while (!canceled && (max == -1 || count++ < max)) {
                    if (errors) {
                        events?.error("errors", "message", null)
                    } else {
                        events?.success(mapOf<String, Any?>(
                                "hello" to "world",
                                "time" to Calendar.getInstance().time.time
                        ))
                    }
                }
            }

            override fun onCancel(arguments: Any?) {
                canceled = true
            }
        })
    }

    override fun onDestroy() {
        super.onDestroy()

        eventChannel?.setStreamHandler(null)
        eventChannel = null
    }
}
