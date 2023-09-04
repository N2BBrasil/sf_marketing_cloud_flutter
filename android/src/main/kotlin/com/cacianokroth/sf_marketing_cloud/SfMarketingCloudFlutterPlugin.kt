package com.cacianokroth.sf_marketing_cloud

import SfMarketingCloudConfig
import SfMarketingCloudHostApi
import android.content.Context
import com.salesforce.marketingcloud.MCLogListener
import com.salesforce.marketingcloud.MarketingCloudConfig
import com.salesforce.marketingcloud.MarketingCloudSdk
import com.salesforce.marketingcloud.sfmcsdk.SFMCSdk
import com.salesforce.marketingcloud.sfmcsdk.SFMCSdkModuleConfig
import io.flutter.BuildConfig
import io.flutter.Log

import io.flutter.embedding.engine.plugins.FlutterPlugin

/** SfMarketingCloudFlutterPlugin */
class SfMarketingCloudFlutterPlugin : FlutterPlugin, SfMarketingCloudHostApi {
  private var context: Context? = null
  
  companion object {
    private val TAG = SfMarketingCloudFlutterPlugin::class.java.simpleName
  }
  
  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    SfMarketingCloudHostApi.setUp(flutterPluginBinding.binaryMessenger, this)
  }
  
  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    SfMarketingCloudHostApi.setUp(binding.binaryMessenger, null)
    context = null
  }
  
  override fun initialize(config: SfMarketingCloudConfig) {
    if (BuildConfig.DEBUG) enableVerboseLogging()
    
    SFMCSdk.configure(context!!, SFMCSdkModuleConfig.build {
      pushModuleConfig = MarketingCloudConfig.builder().apply {
        setApplicationId(config.appId)
        setAccessToken(config.accessToken)
        setSenderId(config.senderId)
        setMarketingCloudServerUrl(config.appEndpoint)
        setMid(config.mid)
        setAnalyticsEnabled(true)
        setPiAnalyticsEnabled(true)
        setDelayRegistrationUntilContactKeyIsSet(true)
        // Other configuration options
      }.build(context!!)
    }) { initStatus ->
      Log.d(TAG, "Marketing Cloud SDK initialization status: $initStatus")
      SFMCSdk.requestSdk { sdk ->
        sdk.mp {
          it.pushMessageManager.enablePush()
        }
      }
    }
  }
  
  override fun setPushToken(token: String) {
    SFMCSdk.requestSdk { sdk ->
      sdk.mp {
        it.pushMessageManager.setPushToken(token)
      }
    }
  }
  
  override fun setContactKey(contactKey: String) {
    SFMCSdk.requestSdk { sdk ->
      sdk.identity.setProfileId(contactKey)
    }
  }
  
  override fun enableVerboseLogging() {
    MarketingCloudSdk.setLogLevel(MCLogListener.VERBOSE)
    MarketingCloudSdk.setLogListener(MCLogListener.AndroidLogListener())
  }
  
  override fun disableVerboseLogging() {
    MarketingCloudSdk.setLogLevel(MCLogListener.ERROR)
    MarketingCloudSdk.setLogListener(null)
  }
}
