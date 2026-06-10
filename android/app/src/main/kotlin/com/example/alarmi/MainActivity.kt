package com.example.alarmi

import android.app.ActivityManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.RingtoneManager
import android.os.Build
import android.os.Bundle
import android.view.KeyEvent
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val RINGTONE_CHANNEL = "com.example.alarmi/ringtones"
    private val ALARM_CHANNEL = "com.example.alarmi/alarm"
    private val HARDWARE_CHANNEL = "com.example.alarmi/hardware"
    
    private var hardwareChannel: MethodChannel? = null
    private var interceptKeys = false

    private val screenOffReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == Intent.ACTION_SCREEN_OFF && interceptKeys) {
                runOnUiThread {
                    hardwareChannel?.invokeMethod("onKeyEvent", KeyEvent.KEYCODE_POWER)
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        this.setupWindowFlags()
        
        val filter = IntentFilter(Intent.ACTION_SCREEN_OFF)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(screenOffReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(screenOffReceiver, filter)
        }
    }

    override fun onDestroy() {
        try {
            unregisterReceiver(screenOffReceiver)
        } catch (e: Exception) { }
        super.onDestroy()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        this.setIntent(intent)
        this.setupWindowFlags()
    }

    private fun setupWindowFlags() {
        this.window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        this.window.addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED)
        this.window.addFlags(WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON)
        this.window.addFlags(WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD)
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            this.setShowWhenLocked(true)
            this.setTurnScreenOn(true)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        hardwareChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HARDWARE_CHANNEL)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, RINGTONE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getSystemRingtones") {
                val type = call.argument<Int>("type") ?: RingtoneManager.TYPE_ALARM
                result.success(getRingtones(type))
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ALARM_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "bringToForeground" -> {
                    try {
                        val intent = Intent(this@MainActivity, MainActivity::class.java)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
                        intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                        
                        this@MainActivity.startActivity(intent)
                        
                        val activityManager = this@MainActivity.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
                        activityManager.moveTaskToFront(this@MainActivity.taskId, ActivityManager.MOVE_TASK_WITH_HOME)
                        
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("FOREGROUND_ERROR", e.message, null)
                    }
                }
                "setHardwareKeysIntercept" -> {
                    interceptKeys = call.arguments as Boolean
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (interceptKeys && event.action == KeyEvent.ACTION_DOWN) {
            val keyCode = event.keyCode
            if (keyCode == KeyEvent.KEYCODE_VOLUME_UP || 
                keyCode == KeyEvent.KEYCODE_VOLUME_DOWN || 
                keyCode == KeyEvent.KEYCODE_POWER) {
                
                runOnUiThread {
                    hardwareChannel?.invokeMethod("onKeyEvent", keyCode)
                }
                
                if (keyCode != KeyEvent.KEYCODE_POWER) {
                    return true
                }
            }
        }
        return super.dispatchKeyEvent(event)
    }

    private fun getRingtones(type: Int): List<Map<String, String>> {
        val manager = RingtoneManager(this)
        manager.setType(type)
        val cursor = manager.cursor
        val list = mutableListOf<Map<String, String>>()
        try {
            if (cursor != null) {
                while (cursor.moveToNext()) {
                    val title = cursor.getString(1)
                    val uri = manager.getRingtoneUri(cursor.position).toString()
                    list.add(mapOf("title" to title, "uri" to uri))
                }
            }
        } catch (e: Exception) {
            // Log error
        }
        return list
    }
}
