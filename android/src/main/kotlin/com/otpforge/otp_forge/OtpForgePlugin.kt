package com.otpforge.otp_forge

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.util.Log
import androidx.core.content.ContextCompat
import com.google.android.gms.auth.api.phone.SmsRetriever
import com.google.android.gms.common.api.CommonStatusCodes
import com.google.android.gms.common.api.Status
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class OtpForgePlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var smsReceiver: BroadcastReceiver? = null
    private var isReceiverRegistered = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        // Use the exact channel name that the Dart SmsRetrieverService expects
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "otp_forge/sms_retriever")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "startRetriever" -> {
                startSmsRetriever(result)
            }
            "stopRetriever" -> {
                unregisterReceiver()
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun startSmsRetriever(result: Result) {
        try {
            val client = SmsRetriever.getClient(context)
            val task = client.startSmsRetriever()
            
            task.addOnSuccessListener {
                registerReceiver()
                result.success("SMS Retriever started successfully")
            }
            
            task.addOnFailureListener { e ->
                Log.e("OtpForgePlugin", "Failed to start SMS retriever", e)
                result.error("FAILED", "Failed to start SMS retriever", e.message)
            }
        } catch (e: Exception) {
            result.error("ERROR", "Error initializing SMS retriever", e.message)
        }
    }

    private fun registerReceiver() {
        if (isReceiverRegistered) return
        
        smsReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                if (SmsRetriever.SMS_RETRIEVED_ACTION == intent.action) {
                    val extras = intent.extras
                    if (extras != null) {
                        val status = extras.get(SmsRetriever.EXTRA_STATUS) as Status?
                        when (status?.statusCode) {
                            CommonStatusCodes.SUCCESS -> {
                                // Extract the message text
                                val message = extras.getString(SmsRetriever.EXTRA_SMS_MESSAGE)
                                if (message != null) {
                                    // Send the raw message string back to Dart
                                    channel.invokeMethod("onSmsReceived", message)
                                }
                                // The retriever only works once per start, so unregister
                                unregisterReceiver()
                            }
                            CommonStatusCodes.TIMEOUT -> {
                                unregisterReceiver()
                            }
                        }
                    }
                }
            }
        }

        val intentFilter = IntentFilter(SmsRetriever.SMS_RETRIEVED_ACTION)
        
        // ContextCompat.registerReceiver safely handles the EXPORTED flag for Android 13+
        ContextCompat.registerReceiver(
            context,
            smsReceiver,
            intentFilter,
            ContextCompat.RECEIVER_EXPORTED
        )
        
        isReceiverRegistered = true
    }

    private fun unregisterReceiver() {
        if (isReceiverRegistered && smsReceiver != null) {
            try {
                context.unregisterReceiver(smsReceiver)
            } catch (e: Exception) {
                Log.e("OtpForgePlugin", "Error unregistering receiver", e)
            }
            isReceiverRegistered = false
            smsReceiver = null
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        unregisterReceiver()
    }
}
