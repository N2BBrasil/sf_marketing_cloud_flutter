package com.cacianokroth.sf_marketing_cloud_flutter

import SFMCConversionData
import SFMCEvent
import SFMCUserAttribute
import SfMarketingCloudConfig
import SfMarketingCloudHostApi
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import com.salesforce.marketingcloud.MCLogListener
import com.salesforce.marketingcloud.MarketingCloudConfig
import com.salesforce.marketingcloud.MarketingCloudSdk
import com.salesforce.marketingcloud.analytics.PiCart
import com.salesforce.marketingcloud.analytics.PiCartItem
import com.salesforce.marketingcloud.analytics.PiOrder
import com.salesforce.marketingcloud.messages.iam.InAppMessage
import com.salesforce.marketingcloud.messages.iam.InAppMessageManager
import com.salesforce.marketingcloud.notifications.NotificationCustomizationOptions
import com.salesforce.marketingcloud.notifications.NotificationManager
import com.salesforce.marketingcloud.sfmcsdk.components.events.EventManager
import com.salesforce.marketingcloud.sfmcsdk.SFMCSdk
import com.salesforce.marketingcloud.sfmcsdk.SFMCSdkModuleConfig
import io.flutter.BuildConfig
import io.flutter.Log

import io.flutter.embedding.engine.plugins.FlutterPlugin
import java.util.Random

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
//        setSenderId(config.senderId)
        setMarketingCloudServerUrl(config.appEndpoint)
        setMid(config.mid)
        setAnalyticsEnabled(true)
        setPiAnalyticsEnabled(true)
        setDelayRegistrationUntilContactKeyIsSet(true)
        setNotificationCustomizationOptions(
          NotificationCustomizationOptions.create { context, notificationMessage ->
            val builder = NotificationManager.getDefaultNotificationBuilder(
              context,
              notificationMessage,
              NotificationManager.createDefaultNotificationChannel(context),
              R.drawable.notification_icon
            )
            builder.setContentIntent(
              NotificationManager.redirectIntentForAnalytics(
                context,
                PendingIntent.getActivity(
                  context,
                  Random().nextInt(),
                  Intent(Intent.ACTION_VIEW, Uri.parse(notificationMessage.url)),
                  PendingIntent.FLAG_IMMUTABLE
                ),
                notificationMessage,
                true,
              )
            )
          }
        )
//        setInboxEnabled(true)
        setUrlHandler { context, url, _ ->
          PendingIntent.getActivity(
            context,
            Random().nextInt(),
            Intent(Intent.ACTION_VIEW, Uri.parse(url)),
            PendingIntent.FLAG_UPDATE_CURRENT
          )
        }
      }.build(context!!)
    }) {
      when (it.status) {
        com.salesforce.marketingcloud.sfmcsdk.InitializationStatus.SUCCESS -> {
          Log.d(TAG, "Marketing Cloud init was successful")
        }
        
        com.salesforce.marketingcloud.sfmcsdk.InitializationStatus.FAILURE -> {
          Log.d(TAG, "Marketing Cloud failed to initialize")
        }
      }
      
      SFMCSdk.requestSdk { sdk ->
        sdk.mp { it ->
          it.pushMessageManager.enablePush()
          it.inAppMessageManager.run {
            setInAppMessageListener(object : InAppMessageManager.EventListener {
              override fun shouldShowMessage(message: InAppMessage): Boolean {
                return true
              }
              
              override fun didShowMessage(message: InAppMessage) {
                Log.v(TAG, "${message.id} was displayed.")
              }
              
              override fun didCloseMessage(message: InAppMessage) {
                Log.v(TAG, "${message.id} was closed.")
              }
            })
          }
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
  
  override fun trackEvent(event: SFMCEvent) {
    val params = event.params?.filterValues { it != null }?.mapKeys { it.key as String }
      ?.mapValues { it.value as Any }
    
    SFMCSdk.track(EventManager.customEvent(event.name, params ?: emptyMap()))
  }
  
  override fun setAttribute(attribute: SFMCUserAttribute) {
    SFMCSdk.requestSdk { sdk ->
      sdk.identity.run {
        setProfileAttribute(attribute.key, attribute.value)
      }
    }
  }
  
  override fun clearAttributes(attributeKeys: List<String>) {
    SFMCSdk.requestSdk { sdk ->
      sdk.identity.run {
        clearProfileAttributes(attributeKeys)
      }
    }
  }
  
  override fun setAttributes(attributes: List<SFMCUserAttribute>) {
    attributes.forEach { setAttribute(it) }
  }
  
  override fun addTags(tags: List<String>) {
    SFMCSdk.requestSdk { sdk ->
      sdk.mp {
        it.registrationManager.edit().run {
          addTags(tags)
          commit()
        }
      }
    }
  }
  
  override fun removeTags(tags: List<String>) {
    SFMCSdk.requestSdk { sdk ->
      sdk.mp {
        it.registrationManager.edit().run {
          removeTags(tags)
          commit()
        }
      }
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
  
  override fun trackConversion(data: SFMCConversionData) {
    SFMCSdk.requestSdk { sdk ->
      sdk.mp {
        val cartItem = PiCartItem(data.item, data.quantity.toInt(), data.value, data.id)
        val cart = PiCart(listOf(cartItem))
        val piOrder = PiOrder(cart, data.order, data.shipping, data.discount)
        
        it.analyticsManager.trackCartConversion(piOrder)
        
      }
    }
  }
  
  override fun trackPageView(path: String) {
    SFMCSdk.requestSdk { sdk ->
      sdk.mp {
        it.analyticsManager.trackPageView(path)
      }
    }
  }
}
