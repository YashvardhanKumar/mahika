package com.mahikav

import android.animation.ObjectAnimator
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.KeyEvent
import android.view.View
import android.view.ViewTreeObserver
import android.view.animation.AnticipateInterpolator
import android.widget.Toast
import androidx.core.animation.doOnEnd
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL_NAME = "volume_double_click"
    private lateinit var channel : MethodChannel
    private var power: Boolean = false
    private var up: Boolean = true
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
    }

    // using platform-specific events
    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if(keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
            Log.d("KeyVolume","Up Volume Pressed");
            up = true;
        }
        if(keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
            power = true;
            KeyEvent.FLAG_TRACKING
            Log.d("KeyVolume","Down Volume Pressed");
        }
        if(up && power) {
            Toast.makeText(this,"Recording",Toast.LENGTH_SHORT).show();
            channel.invokeMethod("volumeBtnPressed", true);
            return false;
        }
        // return true means "prevent default behavior", so volume doesn't change and volume bar doesn't appear
        return true
    }

    override fun onKeyUp(keyCode: Int, event: KeyEvent?): Boolean {
        if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
            power = false;
        } else if(keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
            up = false;
        }
        // return true means "prevent default behavior", so volume doesn't change and volume bar doesn't appear
        return true
    }
}
