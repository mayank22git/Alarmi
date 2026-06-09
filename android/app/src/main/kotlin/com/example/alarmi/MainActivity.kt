package com.example.alarmi

import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.alarmi/ringtones"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Show over lock screen
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
            )
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSystemRingtones" -> {
                    val type = call.argument<Int>("type") ?: RingtoneManager.TYPE_ALARM
                    val ringtones = getRingtones(type)
                    result.success(ringtones)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getRingtones(type: Int): List<Map<String, String>> {
        val manager = RingtoneManager(this)
        manager.setType(type)
        val cursor = manager.cursor
        val list = mutableListOf<Map<String, String>>()
        try {
            while (cursor.moveToNext()) {
                val title = cursor.getString(1) // Title is usually at index 1
                val uri = manager.getRingtoneUri(cursor.position).toString()
                list.add(mapOf("title" to title, "uri" to uri))
            }
        } catch (e: Exception) {
            // Log error
        }
        return list
    }
}
