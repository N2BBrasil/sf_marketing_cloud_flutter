import Flutter
import UIKit
import SFMCSDK
import MarketingCloudSDK

public class SfMarketingCloudFlutterPlugin: NSObject, FlutterPlugin, SfMarketingCloudHostApi {
  var notificationUserInfo:[AnyHashable:Any]?
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SfMarketingCloudFlutterPlugin()
    SfMarketingCloudHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
  }
  
  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    SfMarketingCloudHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: nil)
  }
  
  func initialize(config: SfMarketingCloudConfig) throws {
    #if DEBUG
    SFMCSdk.setLogger(logLevel: .debug)
    #endif
    
    let mobilePushConfig = PushConfigBuilder(appId: config.appId)
      .setAccessToken(config.accessToken)
      .setMarketingCloudServerUrl(URL(string: config.appEndpoint)!)
      .setMid(config.mid)
      .setDelayRegistrationUntilContactKeyIsSet(true)
      .setAnalyticsEnabled(true)
      .setPIAnalyticsEnabled(true)
      .setInboxEnabled(true)
      .setLocationEnabled(true)
      .build()
    
    let completionHandler: (OperationResult) -> () = { result in
      if(result == .success) {
        NSLog("SFMC: Marketing Cloud init was successful")
        SFMCSdk.mp.setPushEnabled(true)
        SFMCSdk.mp.setEventDelegate(self)
        
        DispatchQueue.main.async {
          if let userInfo = self.notificationUserInfo {
            SFMCSdk.mp.setNotificationUserInfo(userInfo)
          }
        }
      } else {
        NSLog("Marketing Cloud failed to initialize")
      }
    }
    
    SFMCSdk.initializeSdk(ConfigBuilder().setPush(config: mobilePushConfig, onCompletion: completionHandler).build())
  }
  
  public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
      // When the app is terminated/killed state
      //    -> when a push notification is received
      //    -> launch the app from Push notification
      //    -> the SDK would have not initialized yet
      // The notification object should be persisted and set back to the MarketingCloudSDK when ready
      // getNotifUserInfoFromAppDelegate() method sets the notification object to SDK once it is operational.
      
      if launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] != nil {
          let notification = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any]
          self.notificationUserInfo = notification
      }
      
      return true
  }
  
  public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Bool{
      SFMCSdk.mp.setNotificationUserInfo(userInfo)
      
      completionHandler(.newData)
      return true
  }
  
  // MobilePush SDK: REQUIRED IMPLEMENTATION
  public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      NSLog("device token implementation")
      SFMCSdk.mp.setDeviceToken(deviceToken)
  }
  
  // MobilePush SDK: REQUIRED IMPLEMENTATION
  public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
      print(error)
  }
  
  func setPushToken(token: String) throws {
    NSLog("apns token is \(token)")
    SFMCSdk.mp.setDeviceToken(Data(base64Encoded: token)!);
  }
  
  func setContactKey(contactKey: String) throws {
    SFMCSdk.identity.setProfileId(contactKey)
  }
  
  func trackEvent(event: SFMCEvent) throws {
    let params = event.params?.compactMapValues { $0 } as? [String: Any]
    SFMCSdk.track(event: CustomEvent(name: event.name, attributes: params)!)
  }
  
  func setAttribute(attribute: SFMCUserAttribute) throws {
    SFMCSdk.identity.setProfileAttribute(attribute.key, attribute.value)
  }
  
  func clearAttributes(attributeKeys: [String]) throws {
    SFMCSdk.identity.clearProfileAttributes(keys: attributeKeys)
  }
  
  func setAttributes(attributes: [SFMCUserAttribute]) throws {
    SFMCSdk.identity.setProfileAttributes(Dictionary(uniqueKeysWithValues: attributes.map { ($0.key, $0.value) }), [ModuleName.push])
  }
  
  func addTags(tags: [String]) throws {
    _ = SFMCSdk.mp.addTags(tags)
  }
  
  func removeTags(tags: [String]) throws {
    for tag in tags {
      _ = SFMCSdk.mp.removeTag(tag)
    }
  }
  
  func enableVerboseLogging() throws {
    SFMCSdk.setLogger(logLevel: .debug, logOutputter: LogOutputter(), filters: [.module, .identity])
  }
  
  func disableVerboseLogging() throws {
    SFMCSdk.clearLoggerFilters()
    SFMCSdk.setLogger(logLevel: .error)
  }
  
  func trackConversion(data: SFMCConversionData) throws {
    let cartItem = SFMCSdk.mp.cartItemDictionary(price:  NSNumber(value: data.value), quantity: NSNumber(value: data.quantity), item: data.item, uniqueId: data.id)
    let cart = SFMCSdk.mp.cartDictionary(cartItem: [cartItem!])
    let order = SFMCSdk.mp.orderDictionary(orderNumber: data.order, shipping: NSNumber(value: data.shipping), discount: NSNumber(value: data.discount), cart: cart!)
    
    SFMCSdk.mp.trackCartConversion(order!)
  }
  
  func trackPageView(path: String) throws {
    SFMCSdk.mp.trackPageView(url: path, title: nil, item: nil, search: nil)
  }
}

extension SfMarketingCloudFlutterPlugin: UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if (userInfo["_sid"] as? String) == "SFMC" {
            
            // Required: tell the MarketingCloudSDK about the notification. This will collect MobilePush analytics
            // and process the notification on behalf of your application.
            SFMCSdk.mp.setNotificationRequest(response.notification.request)
            
            completionHandler()
        }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Check _sid to "SFMC" to make sure we only handle messages from SFMC
        if (userInfo["_sid"] as? String) == "SFMC" {
            completionHandler(.alert)
        }
    }
    
}

extension SfMarketingCloudFlutterPlugin: InAppMessageEventDelegate {
    public func sfmc_shouldShow(inAppMessage message: [AnyHashable : Any]) -> Bool {
        print("message should show")
        return true
    }
    
    public func sfmc_didShow(inAppMessage message: [AnyHashable : Any]) {
        // message shown
        print("message was shown")
    }
    
    public func sfmc_didClose(inAppMessage message: [AnyHashable : Any]) {
        // message closed
        print("message was closed")
    }
}
